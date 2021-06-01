CREATE OR REPLACE TRIGGER ADMIN.TRG_AUDIT_DDL BEFORE DDL ON SCHEMA
DECLARE
  v_exists NUMBER;
BEGIN
  IF (ora_dict_obj_owner IN ('WKF','WKFD','COR','CORD','ADMIN','DTS','DTSD')) THEN
    SELECT COUNT(1) INTO v_exists FROM dtsd.audit_object_changes
     WHERE object_owner = ora_dict_obj_owner 
       AND object_type = ora_dict_obj_type 
       AND object_name = ora_dict_obj_name 
       AND dbms_lob.compare(object_ddl, wkfd.get_ddl(ora_dict_obj_owner,ora_dict_obj_type,ora_dict_obj_name)) = 0
       AND recovery_version = 1;
    
    IF (v_exists = 0) THEN
      UPDATE dtsd.audit_object_changes 
         SET recovery_version = 0
       WHERE object_owner = ora_dict_obj_owner 
         AND object_type = ora_dict_obj_type 
         AND object_name = ora_dict_obj_name;
         
      INSERT INTO dtsd.audit_object_changes
      VALUES
        (ora_dict_obj_owner,
         ora_dict_obj_type,
         ora_dict_obj_name,
         wkfd.get_ddl(ora_dict_obj_owner,ora_dict_obj_type,ora_dict_obj_name),
         ora_sysevent,
         current_date,
         sys_context('USERENV', 'CURRENT_USER'),
         sys_context('USERENV', 'OS_USER'),
         sys_context('USERENV', 'HOST')|| '|'||sys_context('USERENV', 'TERMINAL'),
         dtsd.audit_ddl_seq.nextval,
         1
         );
    END IF;
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    INSERT INTO dtsd.audit_object_changes
        VALUES
          (ora_dict_obj_owner,
           ora_dict_obj_type,
           ora_dict_obj_name,
           'ERROR',
           ora_sysevent,
           current_date,
           sys_context('USERENV', 'CURRENT_USER'),
           sys_context('USERENV', 'OS_USER'),
           sys_context('USERENV', 'HOST')|| '|'||sys_context('USERENV', 'TERMINAL'),
           1,
           dtsd.audit_ddl_seq.nextval
           );
END;
/
