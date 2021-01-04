CREATE TYPE sortable_t IS object(
    driver VARCHAR2(1024),
    points NUMBER(11, 2)
);

CREATE TYPE sortable_table_t IS TABLE OF sortable_t;

CREATE OR REPLACE PROCEDURE p_get_driver_standings_for_season (
  v_year seasons.year%TYPE
) IS

  TYPE type_map_drivers IS
    TABLE OF NUMBER(11, 2) INDEX BY VARCHAR2(1024);

  v_drivers   type_map_drivers;
  v_index     VARCHAR2(1024);
  v_sorted    sortable_table_t := sortable_table_t();

  CURSOR c_results IS
    SELECT
      d.first_name
      || ' '
      || d.last_name
      || '('
      || c.name
      || ')' AS driver,
      res.points AS points
    FROM
      results        res
      JOIN races          r ON ( r.race_id = res.race_id )
      JOIN drivers        d ON ( d.driver_id = res.driver_id )
      JOIN constructors   c ON ( c.constructor_id = res.constructor_id )
      JOIN seasons        s ON ( s.year = EXTRACT(YEAR FROM r.race_date) )
    WHERE
      r.race_year = v_year
    ORDER BY
      res.points DESC;

BEGIN
  FOR i IN c_results LOOP
    IF v_drivers.EXISTS(i.driver) THEN
      v_drivers(i.driver) := v_drivers(i.driver) + i.points;
    ELSE
      v_drivers(i.driver) := i.points;
    END IF;
  END LOOP;

  v_index := v_drivers.first;
  WHILE v_index IS NOT NULL LOOP
    v_sorted.extend(1);
    v_sorted(v_sorted.last) := NEW sortable_t(v_index, v_drivers(v_index));

    v_index := v_drivers.next(v_index);
  END LOOP;

  -- Sort results stored in v_drivers
  SELECT
    CAST(MULTISET(
      SELECT
        *
      FROM
        TABLE(v_sorted)
      ORDER BY
        2 DESC
    ) AS sortable_table_t)
  INTO v_sorted
  FROM
    dual;

  FOR j IN v_sorted.first..v_sorted.last LOOP
    dbms_output.put_line(v_sorted(j).driver
                        || ': '
                        || v_sorted(j).points
                        || CASE v_sorted(j).points WHEN 1 THEN ' point' ELSE ' points' END);
  END LOOP;

-- Only exception that can occur is when there are no results for the given season
EXCEPTION
  WHEN others THEN
    RAISE_APPLICATION_ERROR(exception_seq.nextval, 'No data found for season "' || v_year || '"');
END;
/

BEGIN
  p_get_driver_standings_for_season(2020);
  p_get_driver_standings_for_season(1949); --> "No data found for season ..."
END;
/
