---
title: "Datalog"
author: "Alexandru Ică"
toc: true
output:
    pdf-document:
        template: csv_to_sql_template.tex
---
\newpage

# Ce este datalog?
Datalog este un limbaj de programare declarativ bazat pe `Prolog`. În spiritul modelului relațional,
relațiile pot fi reprezentate prin predicate:
```prolog
age(sally, 21).
age(john, 34).
```
Regulile descriu modul în care predicate noi pot fi deduse din predicate cunoscute:
```prolog
subordinate(A, B) :- has_manager(A, B).
subordinate(A, B) :- has_manager(A, C), has_manager(C, B).
```
Mai sus este definită o regulă care reprezintă relația de subordonat(de exemplu din departamentele unei
firme):
```
A este subordonatul lui B daca:
    - A are ca manager pe B
    SAU
    - A are ca manager pe C, care la rândul lui are ca manager pe B
```
După cum se poate vedea, relația este definită recursiv. Dacă avem setul de predicate:
```prolog
has_manager(eliza, mark).
has_manager(steven, mark).
has_manager(john, eliza).
```
Atunci putem să interogăm "baza de date":
```prolog
?- subordinate(eliza, mark).
 true
?- subordinate(eliza, john).
 false
?- subordinate(john, mark).
 true
?- subordinate(X, mark).
 X=eliza
 X=steven
 X=john
?- subordinate(X, Y).
 X=eliza, Y=mark
 X=steven, Y=mark
 X=john, Y=eliza
 X=john, Y=mark
```
Token-urile cu litere mici reprezintă atomi(datele efective), iar cele care încep cu literă mare reprezintă
variabile, care sunt substituite ulterior de atomi. Reprezentarea unei astfel de relații nu este chiar
trivială în SQL. Eu am ales să prezint datalog nu neapărat ca o alternativă pentru SQL, ci pur și simplu
pentru a arăta și alte modalități de a interoga baze de date. În datalog se pot exprima relații complexe
mult mai ușor decât în SQL. Acest lucru nu aduce numai avantaje: fiind atât de ușor să modelăm relații
complexe, este ușor ca performanța unui query să scadă, sunt slabe șanse ca un query să poată fi optimizat
precum unul de SQL.

# În practică
Voi prezenta în continuare exemple pe sintaxa bazei de date [Datomic](https://www.datomic.com/), pentru
simplul fapt că documentația este foarte bună. De menționat este și baza de date
[Crux](https://opencrux.com/main/index.html) care este Open-Source și este aproape identică sintactic
cu Datomic. Ambele sunt concepute pentru `JVM`, în special limbajul de programare `Clojure`.

# Simplă interogare
Predicatele din prolog sunt reprezentate ca liste:
```prolog
epxerience(mariah, 26).
epxerience(fred, 3).
epxerience(julia, 3).

does(mariah, science).
does(fred, football).
does(julia, art).
```
Devine:
```clojure
[
 [mariah :experience 26]
 [fred :experience 3]
 [julia :experience 3]
 [mariah :does science]
 [fred :does football]
 [julia :does art]
]
```
Interogările sunt la rândul lor reprezentate prin liste. Putem efectua o interogare simplă:
```clojure
[:find ?p
 :where
 [?p :experience 3]]
```
Care va întoarce:
```clojure
[[fred], [julia]]
```
La o interogare se face pattern-matching pe liste în funcție de constantele din query. '`?`' reprezintă
'unul sau zero'. Se va găsi match pentru `fred` și `julia` și se va înlocui variabila `?p` pentru fiecare
rezultat.

# Unificare
Predicatul `where` poate accepta mai multe liste:
```clojure
[:find ?p ?what
 :where
 [?p :experience 3]
 [?p :does ?what]]
```
Se întoarce:
```clojure
[[fred football], [julia art]]
```
Pur și simplu se face match pe rând la liste. Pentru ca o listă să fie întoarsă trebuie ca match-ul să fi
reușit pe toate filtrele din `:where`.

# Parametri
O interogare poate fi parametrizată(putem asocia cu procedurile din PL/SQL):
```clojure
[:find ?exp
 :in $ ?name
 :where [?name :experience ?exp]]
```
Semnul `$` reprezintă parametrul prin care se furnizează baza de date(parametru implicit, îl putem ignora).
'`?name`' este parametrul care ne interesează. Apelând interogarea cu valoarea `mariah` pentru `?name` vom
obține:
```clojure
[26]
```

## Collection Binding
Se referă la a face binding unui parametru pentru fiecare element dintr-o listă. Mai concret:
```clojure
[:find ?what
 :in $ [?name ...]
 :where [?name :does ?what]]
```
Pentru input-ul:
```clojure
[mariah fred]
```
Va răspunde la întrebarea "Ce face fie mariah fie fred?":
```clojure
[[science] [football]]
```

\newpage

# Clauze 'not'
Urmatoarea interogare:
```clojure
[:find ?exp
 :where [?name :experience ?exp]
        (not [?name :does football])]
```
Va răspunde la întrebarea "Ce experiență au cei care nu joacă fotbal?":
```
[[26] [3]]
```
Există mai multe clauze, printre care și `or` și `or-join`(care specifică ce variabile trebuiesc substituite
astfel încât clauza să poată rula).

# Condiții pentru variabile
Putem pune și condiții pentru variabile, de exemplu:
```clojure
[:find ?name
 :where [?name :experience ?exp]
        [(> ?exp 3)]]
```
Care va răspunde la întrebarea "Ce nume au cei cu mai mult de 3 ani experiență?":
```clojure
[[mariah]]
```

# Concluzie
Cu datalog se pot face lucruri mult mai interesante decât ce am prezentat eu aici, eu am vrut doar să prezint
și altceva decât "lumea" SQL, ceva "mai de nișă", dar care, sper eu, este măcar interesant, și stârnește
puțină curiozitate referitor la modalități de a interoga baze de date, diferite de SQL.
