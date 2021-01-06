CREATE OR REPLACE TRIGGER pit_stops_dml_row_trigger BEFORE
  INSERT OR UPDATE ON pit_stops
  FOR EACH ROW
DECLARE
  v_race_id     races.race_id%TYPE;
  v_driver_id   drivers.driver_id%TYPE;
  v_temp_id     pit_stops.lap%TYPE;
  v_message     VARCHAR2(10);
BEGIN
  IF inserting THEN
    v_message := 'insert';
  ELSIF updating THEN
    v_message := 'update';
  END IF;

  BEGIN
    SELECT
      race_id
    INTO v_race_id
    FROM
      races
    WHERE
      race_id = :new.race_id;

  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(exception_seq.nextval, 'Cannot '
                                                     || v_message
                                                     || ' the pit stop, the race_id must already exist! There is no race with id='
                                                     || :new.race_id);
  END;

  BEGIN
    SELECT
      driver_id
    INTO v_driver_id
    FROM
      drivers
    WHERE
      driver_id = :new.driver_id;

  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(exception_seq.nextval, 'Cannot '
                                                     || v_message
                                                     || ' the pit stop, the driver_id must already exist! There is no driver with id='
                                                     || :new.driver_id);
  END;

  IF inserting THEN
    SELECT
      COUNT(*)
    INTO v_temp_id
    FROM
      pit_stops
    WHERE
      race_id = :new.race_id
      AND driver_id = :new.driver_id
      AND stop = :new.stop;

    IF v_temp_id > 0 THEN
      raise_application_error(exception_seq.nextval, 'Cannot insert the pit stop, primary key already exists!, driver_id='
                                                     || :new.driver_id
                                                     || ', race_id='
                                                     || :new.race_id
                                                     || ', stop='
                                                     || :new.stop);

    END IF;

  END IF;

END;
/

-- race_id must already exist

INSERT INTO pit_stops (
  race_id,
  driver_id,
  stop,
  lap,
  time,
  duration
) VALUES (
  0,
  0,
  0,
  0,
  '',
  ''
);

UPDATE pit_stops
SET
  race_id = 0
WHERE
  race_id = 841;

-- driver_id must already exist

INSERT INTO pit_stops (
  race_id,
  driver_id,
  stop,
  lap,
  time,
  duration
) VALUES (
  841,
  0,
  0,
  0,
  '',
  ''
);

UPDATE test_pit_stops
SET
  driver_id = 0
WHERE
  race_id = 841;

-- primary key already exists

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
  1,
  0,
  '',
  ''
);

-- correct

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
  pit_stops
ORDER BY
  race_id;

ROLLBACK;

COMMIT;
