

--
-- DBA_DB_PARAM_SET (Table)
--
CREATE TABLE {{schema_name}}.DBA_DB_PARAM_SET (
  DBA_DB_PARAM_SET_OID            VARCHAR2(32) DEFAULT SYS_GUID(),
  NAME                            VARCHAR2(80),
  VALUE                           VARCHAR2(4000),
  VALID                           VARCHAR2(1),
  VALUE_CHANGED                   VARCHAR2(1),
  IS_MODIFIABLE                   VARCHAR2(1),
  ROW_SEC_LBL_ID                  NUMBER,
  CREATION_CAL_DT_TM              DATE,
  CREATOR_ID                      VARCHAR2(35),
CONSTRAINT DBA_DB_PARAM_SET_PK PRIMARY KEY (DBA_DB_PARAM_SET_OID) ENABLE
) TABLESPACE {{schema_name}}_TS01;

--
-- NULL CONSTRAINTS
--
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (DBA_DB_PARAM_SET_OID        NOT NULL ENABLE);
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (NAME                        NOT NULL ENABLE);
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (VALUE                       NOT NULL ENABLE);
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (VALID                       NOT NULL ENABLE);
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (VALUE_CHANGED               NOT NULL ENABLE);
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (IS_MODIFIABLE               NOT NULL ENABLE);
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (ROW_SEC_LBL_ID              NOT NULL ENABLE);
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (CREATION_CAL_DT_TM          NOT NULL ENABLE);
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET MODIFY (CREATOR_ID                  NOT NULL ENABLE);


--
-- COMMENTS
--
COMMENT ON TABLE {{schema_name}}.DBA_DB_PARAM_SET IS
	'Holds the Database Parameter values changed by a configuration change';

COMMENT ON COLUMN {{schema_name}}.DBA_DB_PARAM_SET.DBA_DB_PARAM_SET_OID IS
	'PRIMARY KEY GLOBAL IDENTIFIER';
    
COMMENT ON COLUMN {{schema_name}}.DBA_DB_PARAM_SET.NAME IS
	'Data parameter name';  

COMMENT ON COLUMN {{schema_name}}.DBA_DB_PARAM_SET.VALUE IS
	'Database parameter value';  

COMMENT ON COLUMN {{schema_name}}.DBA_DB_PARAM_SET.VALUE_CHANGED IS
	'Identifies if the database parameter value has changed from the existing value';      

COMMENT ON COLUMN {{schema_name}}.DBA_DB_PARAM_SET.IS_MODIFIABLE IS
	'Identifies if the data parameter requires a database reboot in order for the change to take affect';

COMMENT ON COLUMN {{schema_name}}.DBA_DB_PARAM_SET.ROW_SEC_LBL_ID IS
	'Row Security Label Identifier';

COMMENT ON COLUMN {{schema_name}}.DBA_DB_PARAM_SET.CREATION_CAL_DT_TM IS
	'The date of which the record was created.';

COMMENT ON COLUMN {{schema_name}}.DBA_DB_PARAM_SET.CREATOR_ID IS
	'The user that created the record.';


--
-- Create Check Constraints
--
ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET ADD CONSTRAINT DBA_DB_PARAM_SET_CK01 CHECK (ROW_SEC_LBL_ID <> 0) ENABLE;


ALTER TABLE {{schema_name}}.DBA_DB_PARAM_SET ENABLE ROW MOVEMENT;
   


