#!/usr/bin/env python3

from typing import Dict, List

import csv
import argparse
import sys

table_names: Dict[str, str] = {
    'seasons': 'test_seasons',
    'circuits': 'test_circuits',
    'races': 'test_races',
    'drivers': 'test_drivers',
    'constructors': 'test_constructors',
    'status': 'test_status',
    'results': 'test_results',
    'qualifying': 'test_qualifying',
    'pit_stops': 'test_pit_stops',
}

def generate_rows(input_file: str):
    with open(input_file) as f:
        reader = csv.reader(f)
        next(reader) # skip first line

        for row in reader:
            yield row

def format_insert_statement(table: str, fields: Dict[str, str]) -> str:
    keys: List[str] = [k for k in fields]
    values: List[str] = [fields[k] for k in fields]
    delim: str = ', '

    return f"INSERT INTO {table}({delim.join(keys)})\n\tVALUES({delim.join(values)});";

def quote(s: str) -> str:
    return f"'{s}'"

def maybe_null(s: str) -> str:
    if s.startswith('\\N'):
        return "NULL";

    if not s:
        return "NULL";

    return s

def maybe_null_quote(s: str) -> str:
    if s.startswith('\\N'):
        return "NULL";

    if not s:
        return "NULL";

    return f"'{s}'"

def format_date(s: str) -> str:
    return f"TO_DATE('{s}', 'yyyy-mm-dd')"

def read_seasons():
    for row in generate_rows(input_file='./seasons.csv'):
        print(format_insert_statement(table_names['seasons'], {
            'year': row[0],
            'url': quote(row[1]),
        }))

def read_circuits():
    for row in generate_rows(input_file='./circuits.csv'):
        print(format_insert_statement(table_names['circuits'], {
            'circuit_id': row[0],
            'name': quote(row[2]),
            'location': quote(row[3]),
            'country': quote(row[4]),
            'url': quote(row[8]),
        }))

def read_races():
    for row in generate_rows(input_file='./races.csv'):
        print(format_insert_statement(table_names['races'], {
            'race_id': row[0],
            'race_year': row[1],
            'circuit_id': row[3],
            'race_name': quote(row[4]),
            'race_date': format_date(row[5]),
            'url': quote(row[7]),
        }))

def read_drivers():
    def filter_quotes(s: str):
        s = s.replace("'", '`')

    for row in generate_rows(input_file='./drivers.csv'):
        print(format_insert_statement(table_names['drivers'], {
            'driver_id': row[0],
            'driver_number': maybe_null(row[2]),
            'first_name': quote(filter_quotes(row[4])),
            'last_name': quote(row[5]),
            'date_born': format_date(row[6]),
            'nationality': quote(row[7]),
            'url': quote(row[8]),
        }))

def read_constructors():
    for row in generate_rows(input_file='./constructors.csv'):
        print(format_insert_statement(table_names['constructors'], {
            'constructor_id': row[0],
            'name': quote(row[2]),
            'nationality': quote(row[3]),
            'url': quote(row[4]),
        }))

def read_status():
    for row in generate_rows(input_file='./status.csv'):
        print(format_insert_statement(table_names['status'], {
            'status_id': row[0],
            'status': quote(row[1]),
        }))

def read_results():
    for row in generate_rows(input_file='./results.csv'):
        print(format_insert_statement(table_names['results'], {
            'result_id': row[0],
            'race_id': row[1],
            'driver_id': row[2],
            'constructor_id': row[3],
            'grid_position': row[5],
            'position': maybe_null(row[6]),
            'position_text': maybe_null_quote(row[7]),
            'points': row[9],
            'laps': row[10],
            'time': maybe_null_quote(row[11]),
            'status_id': row[17],
        }))

def read_qualifying():
    for row in generate_rows(input_file='./qualifying.csv'):
        print(format_insert_statement(table_names['qualifying'], {
            'qualify_id': row[0],
            'race_id': row[1],
            'driver_id': row[2],
            'constructor_id': row[3],
            'position': row[5],
            'q1': maybe_null_quote(row[6]),
            'q2': maybe_null_quote(row[7]),
            'q3': maybe_null_quote(row[8]),
        }))

def read_pit_stops():
    for row in generate_rows(input_file='./pit_stops.csv'):
        print(format_insert_statement(table_names['pit_stops'], {
            'race_id': row[0],
            'driver_id': row[1],
            'stop': row[2],
            'lap': row[3],
            'time': maybe_null_quote(row[4]),
            'duration': maybe_null_quote(row[5]),
        }))

def format_create_table(name: str, fields: Dict[str, str]) -> str:
    delim: str = ',\n  '
    types: [str] = [f"{k} {fields[k]}" for k in fields]

    return f"CREATE TABLE {name}(\n  {delim.join(types)}\n);"

def generate_schema():
    results: [str] = []

    results = [
        format_create_table(table_names['seasons'], {
            'year': 'NUMBER(11) NOT NULL',
            'url': 'VARCHAR2(255) NOT NULL',
            'CONSTRAINT seasons_uk': 'UNIQUE (url)',
            'CONSTRAINT seasons_pk': 'PRIMARY KEY (year)',
        }),
        format_create_table(table_names['circuits'], {
            'circuit_id': 'NUMBER(11) NOT NULL',
            'name': 'VARCHAR2(255) NOT NULL',
            'location': 'VARCHAR2(255) DEFAULT NULL',
            'country': 'VARCHAR2(255) DEFAULT NULL',
            'url': 'VARCHAR2(255) NOT NULL',
            'CONSTRAINT circuits_uk': 'UNIQUE (url)',
            'CONSTRAINT circuits_pk': 'PRIMARY KEY (circuit_id)',
        }),
        format_create_table(table_names['races'], {
            'race_id': 'NUMBER(11) NOT NULL',
            'race_year': 'NUMBER(11) NOT NULL',
            'circuit_id': 'NUMBER(11) NOT NULL',
            'race_name': 'VARCHAR2(255) NOT NULL',
            'race_date': 'DATE NOT NULL',
            'url': 'VARCHAR2(255) DEFAULT NULL',
            'CONSTRAINT races_uk': 'UNIQUE (url)',
            'CONSTRAINT races_pk': 'PRIMARY KEY (race_id)',
        }),
        format_create_table(table_names['drivers'], {
            'driver_id': 'NUMBER(11) NOT NULL',
            'driver_number': 'NUMBER(11)',
            'first_name': 'VARCHAR2(255) NOT NULL',
            'last_name': 'VARCHAR2(255) NOT NULL',
            'date_born': 'DATE DEFAULT NULL',
            'nationality': 'VARCHAR2(255) DEFAULT NULL',
            'url': 'VARCHAR2(255) DEFAULT NULL',
            'CONSTRAINT drivers_uk': 'UNIQUE (url)',
            'CONSTRAINT drivers_pk': 'UNIQUE (driver_id)',
        }),
        format_create_table(table_names['constructors'], {
            'constructor_id': 'NUMBER(11) NOT NULL',
            'name': 'VARCHAR2(255) NOT NULL',
            'nationality': 'VARCHAR2(255) DEFAULT NULL',
            'url': 'VARCHAR2(255) NOT NULL',
            'CONSTRAINT constructors_uk': 'UNIQUE (url)',
            'CONSTRAINT constructors_pk': 'UNIQUE (constructor_id)',
        }),
        format_create_table(table_names['status'], {
            'status_id': 'NUMBER(11) NOT NULL',
            'status': 'VARCHAR2(255) NOT NULL',
            'CONSTRAINT status_pk': 'PRIMARY KEY (status_id)',
        }),
        format_create_table(table_names['results'], {
            'result_id': 'NUMBER(11) NOT NULL',
            'race_id': 'NUMBER(11) NOT NULL',
            'driver_id': 'NUMBER(11) NOT NULL',
            'constructor_id': 'NUMBER(11) NOT NULL',
            'grid_position': 'NUMBER(11) NOT NULL',
            'position': 'NUMBER(11) DEFAULT NULL',
            'position_text': 'VARCHAR2(255) DEFAULT NULL',
            'points': 'NUMBER(4, 2) DEFAULT 0',
            'laps': 'NUMBER(11) DEFAULT 0',
            'time': 'VARCHAR2(255) DEFAULT NULL',
            'status_id': 'NUMBER(11) NOT NULL',
            'status_id': 'NUMBER(11) NOT NULL',
            'CONSTRAINT results_pk': 'PRIMARY KEY (result_id)',
        }),
        format_create_table(table_names['qualifying'], {
            'qualify_id': 'NUMBER(11) NOT NULL',
            'race_id': 'NUMBER(11) NOT NULL',
            'driver_id': 'NUMBER(11) NOT NULL',
            'constructor_id': 'NUMBER(11) NOT NULL',
            'position': 'NUMBER(11) DEFAULT NULL',
            'q1': 'VARCHAR2(255) DEFAULT NULL',
            'q2': 'VARCHAR2(255) DEFAULT NULL',
            'q3': 'VARCHAR2(255) DEFAULT NULL',
            'CONSTRAINT qualifying_pk': 'PRIMARY KEY (qualify_id)',
        }),
        format_create_table(table_names['pit_stops'], {
            'race_id': 'NUMBER(11) NOT NULL',
            'driver_id': 'NUMBER(11) NOT NULL',
            'stop': 'NUMBER(11) NOT NULL',
            'lap': 'NUMBER(11) DEFAULT NULL',
            'time': 'VARCHAR2(255) DEFAULT NULL',
            'duration': 'VARCHAR2(255) DEFAULT NULL',
            'CONSTRAINT pit_stops_pk': 'PRIMARY KEY (race_id, driver_id, stop)',
        }),
    ]

    print('\n\n'.join(results))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Transform .csv data into .sql files')
    parser.add_argument('--seasons', action='store_true')
    parser.add_argument('--circuits', action='store_true')
    parser.add_argument('--races', action='store_true')
    parser.add_argument('--drivers', action='store_true')
    parser.add_argument('--constructors', action='store_true')
    parser.add_argument('--status', action='store_true')
    parser.add_argument('--results', action='store_true')
    parser.add_argument('--qualifying', action='store_true')
    parser.add_argument('--pits', action='store_true')
    parser.add_argument('--deploy', action='store_true', help="Use 'production' table names")
    parser.add_argument('--schema', action='store_true', help="Generate SQL code to create the tables")

    args = parser.parse_args()

    if args.deploy:
        for key in table_names:
            table_names[key] = key

    actions = [
        (args.seasons, read_seasons),
        (args.circuits, read_circuits),
        (args.races, read_races),
        (args.drivers, read_drivers),
        (args.constructors, read_constructors),
        (args.status, read_status),
        (args.results, read_results),
        (args.qualifying, read_qualifying),
        (args.pits, read_pit_stops),
        (args.schema, generate_schema),
    ]

    for arg, action in actions:
        if arg:
            action()
            break
    else:
        parser.print_help(sys.stderr)
