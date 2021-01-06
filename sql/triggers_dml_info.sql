CREATE OR REPLACE TRIGGER pit_stops_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON pit_stops
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'pit_stops'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'pit_stops'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'pit_stops'
    );

  END IF;
END;
/

CREATE OR REPLACE TRIGGER circuits_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON circuits
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'circuits'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'circuits'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'circuits'
    );

  END IF;
END;
/

CREATE OR REPLACE TRIGGER constructors_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON constructors
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'constructors'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'constructors'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'constructors'
    );

  END IF;
END;
/

CREATE OR REPLACE TRIGGER races_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON races
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'races'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'races'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'races'
    );

  END IF;
END;
/

CREATE OR REPLACE TRIGGER results_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON results
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'results'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'results'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'results'
    );

  END IF;
END;
/

CREATE OR REPLACE TRIGGER qualifying_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON qualifying
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'qualifying'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'qualifying'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'qualifying'
    );

  END IF;
END;
/

CREATE OR REPLACE TRIGGER seasons_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON seasons
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'seasons'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'seasons'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'seasons'
    );

  END IF;
END;
/

CREATE OR REPLACE TRIGGER status_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON status
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'status'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'status'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'status'
    );

  END IF;
END;
/

CREATE OR REPLACE TRIGGER drivers_trigger_dml_info AFTER
  INSERT OR UPDATE OR DELETE ON drivers
BEGIN
  IF inserting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'INSERT',
      'drivers'
    );

  ELSIF updating THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'UPDATE',
      'drivers'
    );

  ELSIF deleting THEN
    INSERT INTO info_dml VALUES (
      sysdate,
      'DELETE',
      'drivers'
    );

  END IF;
END;
/

INSERT INTO pit_stops (
  race_id,
  driver_id,
  stop,
  lap,
  time,
  duration
) VALUES (
  841,
  20,
  10,
  0,
  '',
  ''
);

UPDATE pit_stops
SET
  lap = 30
WHERE
  race_id = 841
  AND driver_id = 20
  AND stop = 10;

SELECT
  *
FROM
  info_dml;

ROLLBACK;

COMMIT;
