create or replace function wkfd.get_ddl (
  p_owner        IN VARCHAR,
  p_object_type  IN VARCHAR,
  p_object_name  IN VARCHAR
  ) 
  RETURN CLOB IS o_ddl CLOB;
BEGIN
  SELECT dbms_metadata.get_ddl(p_object_type, p_object_name, p_owner) INTO o_ddl FROM dual;
  RETURN o_ddl;
END;
/
