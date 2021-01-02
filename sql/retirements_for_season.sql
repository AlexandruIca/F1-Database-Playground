CREATE OR REPLACE PROCEDURE p_get_retirements_for_season (
  v_year seasons.year%TYPE
) IS

  TYPE type_map_races IS
    TABLE OF VARCHAR2(512) INDEX BY VARCHAR2(256);

  v_races    type_map_races;
  v_index    VARCHAR2(256);
  v_season   NUMBER(11);
  v_count    NUMBER := 0;

  CURSOR c_iter_grands_prix IS
    SELECT
      r.race_name AS race,
      d.first_name
      || ' '
      || d.last_name
      || '('
      || s.status
      || ')' AS driver
    FROM
      results   res
      JOIN races     r ON ( res.race_id = r.race_id )
      JOIN drivers   d ON ( res.driver_id = d.driver_id )
      JOIN status    s ON ( res.status_id = s.status_id )
    WHERE
      r.race_year = v_year
      AND res.position IS NULL
      AND res.position_text = 'R'
    ORDER BY
      r.race_date;

BEGIN
  BEGIN
    SELECT
      year
    INTO v_season
    FROM
      seasons
    WHERE
      year = v_year;

  EXCEPTION
    WHEN no_data_found THEN
      dbms_output.put_line('No "'
                           || v_year
                           || '" season!');
      RETURN;
    WHEN OTHERS THEN
      raise_application_error(exception_seq.nextval, 'Unknown error occured when fetching info from "seasons"');
  END;

  FOR i IN c_iter_grands_prix LOOP
    IF v_races.EXISTS(i.race) THEN
      v_races(i.race) := v_races(i.race)
                       || chr(10)
                       || '  '
                       || i.driver;
    ELSE
      v_races(i.race) := i.driver;
    END IF;
  END LOOP;

  v_index := v_races.first;
  WHILE v_index IS NOT NULL LOOP
    dbms_output.put_line(v_index
                         || ':'
                         || chr(10)
                         || '  '
                         || v_races(v_index));

    v_count := v_count + 1;
    v_index := v_races.next(v_index);
  END LOOP;

  IF v_count = 0 THEN
    dbms_output.put_line('No retirements in season ' || v_year);
  END IF;

END;
/

BEGIN
  p_get_retirements_for_season(2020);
  dbms_output.put_line('-----------------------');
  p_get_retirements_for_season(1980);
  dbms_output.put_line('-----------------------');
  p_get_retirements_for_season(2021); --> No retirements in season 2021
  dbms_output.put_line('-----------------------');
  p_get_retirements_for_season(2022); --> No "2022" season
END;
/
