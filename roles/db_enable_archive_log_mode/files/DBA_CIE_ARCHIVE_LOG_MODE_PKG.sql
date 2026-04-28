---------------------------------------------------------------------------
--
-- Name: DBA_CIE_ARCHIVE_LOG_MODE_PKG
--
-- Description:
--  This package contains miscellaneous utilities for locking down
--  the database in regards to STIG.
--
--  This package must be installed into the SYS schema
--
----------------------------------------------------------------------------


--------------------------------------------------------
--  DDL for Package DBA_CIE_ARCHIVE_LOG_MODE_PKG (SYS)
--------------------------------------------------------

PROMPT PACKAGE - SYS.DBA_CIE_ARCHIVE_LOG_MODE_PKG

CREATE OR REPLACE PACKAGE SYS.DBA_CIE_ARCHIVE_LOG_MODE_PKG
AS

   -----------------------------------------------------------------------
   --  Unsets the Flash Recovery Area Parameter
   -----------------------------------------------------------------------
   procedure UNSET_FLASH_RECOVEY_AREA;


   -----------------------------------------------------------------------
   --   Sets the Log Archive_Dest 1 directory path.
   --   This is the path that wil be used for archive log mode
   --   Only gets set if not already set
   -----------------------------------------------------------------------
   procedure SET_ARCHIVE_LOG_DIR (p_Dir_Path in  varchar2);

   
   -----------------------------------------------------------------------
   -- Returns the Archive Log Mode
   -----------------------------------------------------------------------
   procedure GET_ARCHIVE_LOG_MODE;



END;
/



--------------------------------------------------------
--  DDL for Package BODY SYS.DBA_CIE_ARCHIVE_LOG_MODE_PKG
--------------------------------------------------------

PROMPT PACKAGE BODY - SYS.DBA_CIE_ARCHIVE_LOG_MODE_PKG


--------------------------------------------------------
--  DDL for Package Body SYS.DBA_CIE_ARCHIVE_LOG_MODE_PKG
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY SYS.DBA_CIE_ARCHIVE_LOG_MODE_PKG
AS
   
   v_Debug_Flag      varchar2(1) := 'Y';
   v_DB_Bounce_Str   varchar2(100) := 'BOUNCETHEDATABASEPLEASE'; 
 
   ----------------------------------------------------------
   --  Prototype Declaration Area
   ----------------------------------------------------------


   -----------------------------------------------------------------------
   -- Returns the Archive Log Mode
   -----------------------------------------------------------------------
   procedure GET_ARCHIVE_LOG_MODE
   AS

     v_Mode   varchar2(50);

   BEGIN

      SELECT LOG_MODE into v_Mode
      from V$DATABASE;

      DBMS_OUTPUT.PUT_LINE(v_Mode);

   END;


   -----------------------------------------------------------------------
   --  Unsets the Flash Recovery Area Related Parameters
   -----------------------------------------------------------------------
   procedure UNSET_FLASH_RECOVEY_AREA
   AS

      v_Cnt     number;
      v_Sql     varchar2(300);

   BEGIN

      SELECT COUNT(*) into v_Cnt
      FROM V$PARAMETER
      WHERE NAME = 'db_recovery_file_dest';

      if (v_Cnt > 0) then
         v_Sql := 'alter system set db_recovery_file_dest=' || '''' || '''';

         DBMS_OUTPUT.PUT_LINE(v_Sql);

         execute immediate v_Sql;

         v_Sql := 'alter system set db_recovery_file_dest_size=1';

         DBMS_OUTPUT.PUT_LINE(v_Sql);

         execute immediate v_Sql;

      END IF;
                              
   END;


   -----------------------------------------------------------------------
   --   Sets the Log Archive_Dest 1 directory path.
   --   This is the path that wil be used for archive log mode
   --   Only gets set if not already set
   -----------------------------------------------------------------------
   procedure SET_ARCHIVE_LOG_DIR (p_Dir_Path in  varchar2)
   AS

      v_Cnt          number;
      v_Sql          varchar2(300);
      v_Dir          varchar2(300);
      v_Value        varchar2(300);
      v_Parm_Name    varchar2(300);
      v_Parm_Value   varchar2(300);


   BEGIN

      v_Parm_Name  := 'log_archive_dest_1';
      v_Parm_Value := 'LOCATION=' || p_Dir_Path;

      SELECT COUNT(*) into v_Cnt
      FROM V$PARAMETER
      WHERE NAME = v_Parm_Name;

      if (v_Cnt > 0) then

         select VALUE into  v_Value
         from v$PARAMETER
         where name=v_Parm_Name;

         if (v_Value IS NULL) then 
            v_Value := 'XXXX';
         end if;

         if (v_Value != v_Parm_Value) then

            v_Sql := 'alter system set log_archive_dest_1=' || '''' || v_Parm_Value || '''';

            DBMS_OUTPUT.PUT_LINE(v_Sql);

            execute immediate v_Sql;

         end if;

      END IF;
   
   END; 
   

END;
/

