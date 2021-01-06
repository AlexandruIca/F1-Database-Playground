CREATE OR REPLACE FUNCTION f_get_wdc_place (
  v_driver_id   drivers.driver_id%TYPE,
  v_season      seasons.year%TYPE
) RETURN NUMBER IS
  v_place NUMBER := 0;
BEGIN
  SELECT
    place
  INTO v_place
  FROM
    (
      SELECT
        res.driver_id AS driver,
        SUM(res.points) AS points,
        ROW_NUMBER() OVER(
          ORDER BY
            SUM(res.points) DESC
        ) AS place
      FROM
        results   res
        JOIN races     r ON ( r.race_id = res.race_id )
        JOIN seasons   s ON ( s.year = EXTRACT(YEAR FROM r.race_date) )
      WHERE
        s.year = v_season
      GROUP BY
        res.driver_id
    ) aux
  WHERE
    aux.driver = v_driver_id;

  RETURN v_place;
EXCEPTION
  WHEN no_data_found THEN
    raise_application_error(exception_seq.nextval, 'There is no driver with id='
                                                   || v_driver_id
                                                   || ' that participated in season '
                                                   || v_season);
  WHEN too_many_rows THEN
    raise_application_error(exception_seq.nextval, 'Fetching driver standings yielded more than one row for id='
                                                   || v_driver_id
                                                   || ', season='
                                                   || v_season);
END;
/

CREATE OR REPLACE PROCEDURE p_get_driver_stats (
  v_first_name   drivers.first_name%TYPE,
  v_last_name    drivers.last_name%TYPE
) IS

  v_driver_id drivers.driver_id%TYPE;

  CURSOR c_results (
    v_id drivers.driver_id%TYPE
  ) IS
  SELECT
    c.name AS team,
    EXTRACT(YEAR FROM r.race_date) AS season,
    SUM(res.points) AS points
  FROM
    results        res
    JOIN constructors   c ON ( c.constructor_id = res.constructor_id )
    JOIN races          r ON ( r.race_id = res.race_id )
  WHERE
    res.driver_id = v_id
  GROUP BY
    c.name,
    EXTRACT(YEAR FROM r.race_date)
  ORDER BY
    2;

BEGIN
  BEGIN
    SELECT
      driver_id
    INTO v_driver_id
    FROM
      drivers
    WHERE
      lower(first_name) = lower(v_first_name)
      AND lower(last_name) = lower(v_last_name);

  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(exception_seq.nextval, 'There is no driver named "'
                                                     || v_first_name
                                                     || ' '
                                                     || v_last_name
                                                     || '"');
    -- this one never happends with the current data, but putting it here just in case
    WHEN too_many_rows THEN
      raise_application_error(exception_seq.nextval, 'Weird, there are many drivers named "'
                                                     || v_first_name
                                                     || ' '
                                                     || v_last_name
                                                     || '"');
  END;

  FOR i IN c_results(v_driver_id) LOOP
    dbms_output.put_line(v_first_name
                         || ' '
                         || v_last_name
                         || '('
                         || i.team
                         || '), season: '
                         || i.season
                         || ', points: '
                         || i.points
                         || ', WDC place: '
                         || f_get_wdc_place(v_driver_id, i.season));
  END LOOP;

END;
/

BEGIN
  p_get_driver_stats('Lewis', 'Hamilton');
  p_get_driver_stats('A', 'B'); --> no driver found
END;
/
