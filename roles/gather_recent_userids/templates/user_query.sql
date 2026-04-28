set head off
set feedback off
set feed off
set serveroutput off
set echo off
-- .007 is about 10 minute
SPOOL /tmp/dirty_user_list CREATE
SELECT CONCAT('KEEP_', USERID)
FROM cp_oam.oam_session
WHERE LAST_ACCESS_TIME > sysdate - {{TIME_RANGE}};
SPOOL OUT
