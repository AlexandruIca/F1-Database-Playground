CREATE OR REPLACE PROCEDURE p_get_results_for_season (
  v_year seasons.year%TYPE
) IS

  TYPE info IS RECORD (
    driver     VARCHAR2(512),
    team       constructors.name%TYPE,
    started    results.grid_position%TYPE,
    finished   results.position_text%TYPE,
    points     results.points%TYPE,
    status     VARCHAR2(255)
  );

  TYPE type_vec_info IS
    VARRAY(50) OF info;

  TYPE type_map_gp IS
    TABLE OF type_vec_info INDEX BY VARCHAR2(255);

  v_gp      type_map_gp;
  v_index   VARCHAR2(255);

  CURSOR c_results IS
    SELECT
      r.race_name         AS race,
      d.first_name
      || ' '
      || d.last_name AS driver,
      c.name              AS team,
      res.grid_position   AS started,
      decode(res.position, NULL, res.position_text, res.position) AS finished,
      res.points          AS points,
      s.status            AS status
    FROM
      results        res
      JOIN races          r ON ( res.race_id = r.race_id )
      JOIN drivers        d ON ( d.driver_id = res.driver_id )
      JOIN constructors   c ON ( c.constructor_id = res.constructor_id )
      JOIN status         s ON ( s.status_id = res.status_id )
    WHERE
      r.race_year = v_year
    ORDER BY
      1,
      6 DESC;

BEGIN
  FOR i IN c_results LOOP
    IF NOT v_gp.EXISTS(i.race) THEN
      v_gp(i.race) := type_vec_info();
    END IF;

    v_gp(i.race).extend(1);
    v_gp(i.race)(v_gp(i.race).last).driver := i.driver;
    v_gp(i.race)(v_gp(i.race).last).team := i.team;
    v_gp(i.race)(v_gp(i.race).last).started := i.started;
    v_gp(i.race)(v_gp(i.race).last).finished := i.finished;
    v_gp(i.race)(v_gp(i.race).last).points := i.points;
    v_gp(i.race)(v_gp(i.race).last).status := i.status;

  END LOOP;

  v_index := v_gp.first;
  WHILE v_index IS NOT NULL LOOP
    dbms_output.put_line(v_index || ':');
    FOR i IN v_gp(v_index).first..v_gp(v_index).last LOOP
      dbms_output.put_line('  '
                           || i
                           || '. '
                           || v_gp(v_index)(i).driver
                           || '('
                           || v_gp(v_index)(i).team
                           || ')'
                           || ' started: '
                           || v_gp(v_index)(i).started
                           || ', finished: '
                           || v_gp(v_index)(i).finished
                           || ', points: '
                           || v_gp(v_index)(i).points
                           || ', status: '
                           || v_gp(v_index)(i).status);
    END LOOP;

    v_index := v_gp.next(v_index);
  END LOOP;

END;
/

BEGIN
  p_get_results_for_season(2020);
  p_get_results_for_season(2022); --> No results, no exceptions raised
END;
/
