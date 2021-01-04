---
title: "Conversie de la Fișiere CSV la Script-uri SQL"
author: "Alexandru Ică"
toc: true
output:
    pdf-document:
        template: csv_to_sql_template.tex
---
\newpage

# Motivație
Pentru a crea o bază de date cu scop educațional(de exemplu pentru proiect) ar fi ideal să avem o cantitate
mare de date pentru a putea experimenta.
Cum a introduce date manual este un proces foarte laborios, o propunere ar fi să preluăm date găsite
pe internet, fiind foarte multe exemple care sunt gratis/open source, special făcute pentru a fi
folosite de cât mai multă lume.

Există și 'database dumps' care sunt script-uri SQL cu care se poate crea baza de date integral, problema
este însă că
[dialecturile de SQL de obicei nu sunt compatibile între ele 100%](http://troels.arvin.dk/db/rdbms/),
ori că tabelele au prea multe atribute care nu ne interesează. De aceea eu propun preluarea datelor într-un
format independent de o bază de date(de exemplu: XML, JSON, CSV, etc.) și convertirea lor ulterioară în
script-uri SQL. Eu am ales formatul CSV deoarece este foarte ușor de parsat, fiind conceput special pentru
a organiza un volum mare de date.

# Obținerea Datelor și Structura unui Document CSV
Eu am ales ca exemplu baza de date de [aici](https://ergast.com/mrd/db/), mai exact fișierul `drivers.csv`.
Datele reprezintă piloți din F1. Dacă deschidem fișierul observăm că arată cam așa:
```
driverId,driverRef,number,code,forename,surname,dob,nationality,url
1,"hamilton",44,"HAM","Lewis","Hamilton",...
```
Este irelevant ce semnifică efectiv datele, ideea este că pe prima linie se află o listă de cuvinte
separate prin '`,` ', pe care le putem considera ca fiind numele coloanelor din tabelul pe care vrem să îl
creăm. Următoarele linii conțin datele care corespund cu coloanele, `1` este valoarea pentru `driverId`,
`"hamilton"` este valoarea pentru `driverRef`, ș.a.m.d.

# Prelucrarea Datelor
Pentru a transforma datele într-un script SQL putem folosi orice limbaj de programare care poate citi
fișiere. Eu am ales python deoarece are în librăria standard un modul care ajută la citirea fișierelor csv,
pentru că este ușor de folosit și pentru că astfel de task-uri se potrivesc perfect pentru acest limbaj.

## Parsare
Pentru acest document vreau să nu includ prima linie deoarece vreau ca numele coloanelor să păstreze
convenția `snake_case` și pentru că nu vreau să iau în considerare coloanele `driverRef` și `code`.
Putem crea o funcție ajutătoare:
```py
import csv

def generate_rows(input_file: str):
    with open(input_file) as f:
        reader = csv.reader(f)
        next(reader) # fără prima linie

        for row in reader:
            yield row
```
Care începe să parseze fișierul dat ca parametru prin `input_file` pornind de la a doua linie și întoarce
fiecare linie. '`row`' este o listă de șiruri de caractere, reprezentând datele de la fiecare linie.
O putem apela astfel:
```py
for row in generate_rows('./drivers.csv'):
    # prelucrează `row`
```

## Generarea Codului Pentru Inserare
Putem să generăm direct pentru fiecare linie codul SQL, de exemplu:
```py
print(f"INSERT INTO drivers(\
            driver_id, driver_number, first_name, last_name, date_born, nationality, url\
        ) VALUES (\
            {row[0]}, {row[2]}, '{row[4]}', '{row[5]}',\
            TO_DATE('{row[6]}', 'yyyy-mm-dd'),\
            '{row[7]}', '{row[8]}'\
        );")
```
însă această metodă nu este deloc flexibilă, iar codul este destul de "urât". Dacă vrem să parsăm mai multe
fișiere ne trebuie o metodă mai generală. Pentru a ușura puțin munca, eu propun să reținem într-un dicționar
numele coloanelor pentru tabel, dându-le valori fiecăreia, izolând totul într-o funcție:
```py
from typing import List, Dict

def format_insert_statement(table: str, fields: Dict[str, str]) -> str:
    keys: List[str] = [k for k in fields]
    values: List[str] = [fields[k] for k in fields]
    delim: str = ', '

    return f"INSERT INTO {table}({delim.join(keys)})
                VALUES({delim.join(values)});"

# Helper care întoarce șirul `s` în apostrof
def quote(s: str) -> str:
    return f"'{s}'"

# Helper care transformă un șir de genul "2020-10-05"
# într-o dată compatibilă cu Oracle
def format_date(date: str) -> str:
    return f"TO_DATE('{date}', 'yyyy-mm-dd')"

for row in generate_rows('./drivers.csv'):
    print(format_insert_statement(table='drivers' fields={
        'driver_id': row[0],
        'driver_number': row[2],
        'first_name': quote(row[4]),
        'last_name': quote(row[5]),
        'date_born': format_date(row[6]),
        'nationality': quote(row[7]),
        'url': quote(row[8]),
    }))
```
Acum avem o metodă care poate fi refolosită și pentru alte fișiere. În plus, dacă vrem să modificăm
structura `INSERT`-ului, putem face asta într-un singur loc.

## Cazuri Particulare
De menționat este că în fișierul csv pot apărea nume ca `O'Reilly` de exemplu, care pot "strica" puțin codul
generat. De asemenea se poate ca elementele de tip `NULL` să fie reprezentate diferit. Aceste cazuri
depind foarte mult de setul de date. Pentru primul caz se poate face ușor o funcție care înlocuiește
apostroful cu altceva:
```py
def filter_quote(s: str) -> str:
    return s.replace("'", "`")
```
\newpage
# Crearea Tabelelor
`INSERT` are nevoie de tabele deja create; putem genera ușor și intuitiv codul pentru a crea tabelele:
```py
def schema(table: str, fields: Dict[str, str]):
    delim: str = ',\n'
    types: [str] = [f"{k} {fields[k]}" for k in fields]

    return f"CREATE TABLE {table}(\n  {delim.join(types)}\n);"

schema(table='drivers', fields={
    'driver_id': 'NUMBER(11) NOT NULL',
    'driver_number': 'NUMBER(11)',
    'first_name': 'VARCHAR2(255) NOT NULL',
    'last_name': 'VARCHAR2(255) NOT NULL',
    'date_born': 'DATE DEFAULT NULL',
    'nationality': 'VARCHAR2(255) DEFAULT NULL',
    'CONSTRAINT drivers_pk': 'PRIMARY KEY (driver_id)',
    'CONSTRAINT drivers_uk': 'UNIQUE (url)',
})
```
Putem folosi aceste funcții pentru a parsa oricâte documente pentru oricâte tabele. Putem să ne folosim de
modulul `argparse` din python pentru a face un mic CLI care să genereze codul SQL:
```py
import argparse
import sys

parser = argparse.ArgumentParser(description='...')
parser.add_argument('--drivers', action='store_true')
parser.add_argument('--schema', action='store_true')

args = parser.parse_args()

if args.schema:
    schema(...)
elif args.drivers:
    for row in generate_rows(...):
        # ...
else:
    parser.print_help(sys.stderr)
```
În Linux, este foarte simplu să salvăm output-ul într-un fișier `.sql`:
```sh
$ python3 my_program.py --drivers > output.sql
```

# Concluzie
Am prezentat, după părerea mea, un mod simplu și extensibil de a prelua documente CSV și a le transforma în
cod SQL pentru a putea crea ușor o bază de date suficient de complexă pentru a putea experimenta. Codul nu
este neapărat "bullet-proof" dar ideea este că se pot crea baze de date foarte ușor odată ce facem rost de
un document structurat(în cazul de față: CSV).
