#!/usr/bin/env python3

table_names = [
    'pit_stops',
    'circuits',
    'constructors',
    'races',
    'results',
    'qualifying',
    'seasons',
    'status',
    'drivers',
]

for name in table_names:
    print(f"""
CREATE OR REPLACE TRIGGER {name}_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON {name}
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      '{name}'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      '{name}'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      '{name}'
    );

  END IF;
END;
/
    """)
