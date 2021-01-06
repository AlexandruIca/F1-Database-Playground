CREATE TABLE f1_audit (
  ddl_date      DATE,
  ddl_user      VARCHAR2(15),
  obj_created   VARCHAR2(15),
  obj_name      VARCHAR2(15),
  ddl_op        VARCHAR2(15)
);

CREATE OR REPLACE PROCEDURE p_f1_audit_insert IS
BEGIN
  INSERT INTO f1_audit (
    ddl_date,
    ddl_user,
    obj_created,
    obj_name,
    ddl_op
  ) VALUES (
    sysdate,
    sys_context('USERENV', 'CURRENT_USER'),
    ora_dict_obj_type,
    ora_dict_obj_name,
    ora_sysevent
  );

END;
/

CREATE OR REPLACE TRIGGER f1_audit_trigger AFTER DDL ON SCHEMA BEGIN
  p_f1_audit_insert;
END;
/

CREATE TABLE test_table (
  t_id NUMBER
);

SELECT
  *
FROM
  f1_audit;

DROP TABLE test_table;
