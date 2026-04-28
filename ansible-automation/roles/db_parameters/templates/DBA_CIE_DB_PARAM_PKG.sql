---------------------------------------------------------------------------
--
-- Name: DBA_DB_PARAM_PKG
--
-- Description:
--  This package contains miscellaneous database procedure utilities.
--  Used for setting database parameters.
--
--  This package must be installed into the SYS schema
--
----------------------------------------------------------------------------


--------------------------------------------------------
--  DDL for Package DBA_DB_PARAM_PKG (SYS)
--------------------------------------------------------

PROMPT PACKAGE - SYS.DBA_DB_PARAM_PKG

CREATE OR REPLACE PACKAGE SYS.DBA_DB_PARAM_PKG
AS

 
   -----------------------------------------------------------------------
   --   Clears the necessary data for the start of a new parameter
   --   setting session.
   -----------------------------------------------------------------------
   procedure CLEAR;
   
   -----------------------------------------------------------------------
   --   Sets the parameter name and value.  The parameter will be 
   --   validated as a part of this action.
   -----------------------------------------------------------------------
   procedure SET (p_Parm_Str  in varchar2);   
   
   -----------------------------------------------------------------------
   --   Change all of the parameters..if the values have actually changed.
   --   However if INSPECT_ONLY is set to TRUE it only checks the parameters
   --   to see if they match the requested value.
   -----------------------------------------------------------------------
   procedure EXECUTE (p_Inspect_Only in varchar2);
   

   -----------------------------------------------------------------------
   --  Identify if the parameter table exists
   -----------------------------------------------------------------------
   procedure TABLE_EXISTS_CHECK;


END;
/



--------------------------------------------------------
--  DDL for Package BODY SYS.DBA_DB_PARAM_PKG
--------------------------------------------------------

PROMPT PACKAGE BODY - SYS.DBA_DB_PARAM_PKG


--------------------------------------------------------
--  DDL for Package Body DBA_ADMIN_PKG
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY SYS.DBA_DB_PARAM_PKG
AS
   
   v_Debug_Flag   varchar2(1) := 'N';
   
   ----------------------------------------------------------
   --  Prototype Declaration Area
   ----------------------------------------------------------
   
   -----------------------------------------------------------------------
   --   Validates the parameter name
   -----------------------------------------------------------------------
   function VALIDATE (p_Parm_Name  in varchar2)
     return varchar2;     
   
   -----------------------------------------------------------------------
   --   Given the parameter string consisting of the parameter and value
   --   it returns the parameter and value
   -----------------------------------------------------------------------   
   procedure GET_NAME_AND_VALUE (p_Parm_Str  in varchar2,
                                 p_Parm_Name out varchar2,
                                 p_Parm_Value out varchar2);
      
   -----------------------------------------------------------------------
   --   Execute the system commands to set the parameter values.   Only
   --   those parameters whose value has changed from the existing value
   --   will be set to the new value.
   ----------------------------------------------------------------------- 
   procedure SET_PARMS;
   
   -----------------------------------------------------------------------
   --   Identifies if the parameter is a modifiable parameter.   If Yes
   --   it means the database does not have to be booted for the new
   --   value to take affect.
   ----------------------------------------------------------------------- 
   function IS_PARM_MODIFIABLE (p_Parm_Name  in varchar2)
     return varchar2;
   
   -----------------------------------------------------------------------
   --   Clears the necessary data for the start of a new parameter
   --   setting session.
   -----------------------------------------------------------------------
   procedure CLEAR
   AS
   
   BEGIN
   
      DELETE FROM {{schema_name}}.DBA_DB_PARAM_SET;
      COMMIT; 
   
   END;
   
   
   -----------------------------------------------------------------------
   --   Ensures/validates the parameter name is a valid parameter
   -----------------------------------------------------------------------
   function VALIDATE (p_Parm_Name  in varchar2)
     return varchar2
   AS 
      v_Cnt    number;
      v_Valid  varchar2(1);
   
   BEGIN
   
      select count(*) into v_Cnt
      from v$parameter
      where name=p_Parm_Name;

      v_Valid := 'Y';
      if (v_Cnt = 0) then
         v_Valid := 'N';
      end if; 

      if (v_Debug_Flag = 'Y') then
         dbms_output.put_line ('VALIDATE. Parm: ' ||  p_Parm_Name || ' Valid Cd: ' || v_Valid);  
      end if;         

      return v_Valid;        
   
   END;
   
 
   -----------------------------------------------------------------------
   --   Identifies if the parameter is a modifiable parameter.   If Yes
   --   it means the database does not have to be booted for the new
   --   value to take affect.
   ----------------------------------------------------------------------- 
   function IS_PARM_MODIFIABLE (p_Parm_Name  in varchar2)
     return varchar2
   AS 
      v_Str   varchar2(100);
   
   BEGIN
   
      select ISSYS_MODIFIABLE into v_Str
      from v$parameter
      where name=p_Parm_Name; 
      
      if (v_Str = 'IMMEDIATE') then
         v_Str := 'Y';
      else
         v_Str := 'N';
      end if;
      
      if (v_Debug_Flag = 'Y') then
         dbms_output.put_line ('IS_PARM_MODIFIABLE. Parm: ' ||  p_Parm_Name || ' Modifiable Cd: ' || v_Str); 
      end if;
                 
      return v_Str;        
   
   END;
   
   -----------------------------------------------------------------------
   --   Identifies if the passed in parameter value differs from the 
   --   existing value
   -----------------------------------------------------------------------   
   function IS_CHANGED (p_Parm_Name  in varchar2, p_Parm_Value in varchar2)
     return varchar2
   AS 
      v_Str     varchar2(1);
      v_Diff    number;
      v_Value   varchar2(4000);
   
   BEGIN
   
      select VALUE into v_Value
      from v$parameter
      where name=p_Parm_Name; 
      
      if (v_Value != p_Parm_Value) then
      
   ----------------------------------------------------------------------
   --  If the parameter is log_buffer the value can differ from the 
   --  specified value up to 1024 due to page sizing.
   ----------------------------------------------------------------------
         if (p_Parm_Name = 'log_buffer') then
            v_Diff := p_Parm_Value - v_Value;
            
            if (v_Diff < 0) then
               v_Diff := v_Diff * -1;
            end if;
            
            if (v_Diff <= 1024) then
               v_Str := 'N';
            else
               v_Str := 'Y';
            end if;
         else
            v_Str := 'Y';
         end if;
      else
         v_Str := 'N';
      end if;
      
      if (v_Debug_Flag = 'Y') then
         dbms_output.put_line ('IS_CHANGED. Parm: ' ||  p_Parm_Name || ' Changed Cd: ' || v_Str); 
      end if;
                 
      return v_Str;        
   
   END;
   
   
   ------------------------------------------------------------------------------
   --   Given the input string which has the format parameterName=paramterValue
   --   return the parameter name and value
   ------------------------------------------------------------------------------   
   procedure GET_NAME_AND_VALUE (p_Parm_Str  in varchar2,
                                 p_Parm_Name out varchar2,
                                 p_Parm_Value out varchar2)
   AS
   
      v_Len           number;
      v_Index         number;
      
   BEGIN
   
     if (v_Debug_Flag = 'Y') then
        dbms_output.put_line ('GET_NAME_AND_VALUE. Input:  ' || p_Parm_Str);
     end if;
   
     v_Len := length(p_Parm_Str);
     v_Index := instr(p_Parm_Str, ':');
     v_Index := v_Index - 1;
     
     p_Parm_Name := substr(p_Parm_Str, 0, v_Index);
     v_Index := v_Index + 2;
     p_Parm_Value := substr(p_Parm_Str, v_Index, v_Len);
     
     -- Ensure the Parameter name has no leading or trailing whitespace (spaces)
     -- Ensure the Parameter value has no leading whitespace (spaces)
     p_Parm_Name  := TRIM(p_Parm_Name);
     p_Parm_Value := TRIM(LEADING ' ' FROM p_Parm_Value);
     
     if (v_Debug_Flag = 'Y') then
        dbms_output.put_line ('GET_NAME_AND_VALUE. Name:  ' || p_Parm_Name);
        dbms_output.put_line ('GET_NAME_AND_VALUE. Value: ' || p_Parm_Value);
     end if;
   
   
   END;
      
   
   -----------------------------------------------------------------------
   --   Sets the parameter name and value.  The parameter will be 
   --   validated as a part of this action.
   -----------------------------------------------------------------------
   procedure SET (p_Parm_Str  in varchar2)
   AS
     v_Valid             number;
     v_Changed           varchar2(1);
     v_Valid_Str         varchar2(1);
     v_Parm_Name         varchar2(80);
     v_Parm_Value        varchar2(4000);
     v_Modifiable_Str    varchar2(1);
   
   BEGIN
   
      GET_NAME_AND_VALUE (p_Parm_Str,
                          v_Parm_Name,
                          v_Parm_Value);
   
      v_Valid_Str := VALIDATE (v_Parm_Name);
      
      v_Modifiable_Str := 'N';
      v_Changed := 'N';
      if (v_Valid_Str = 'Y') then
         v_Modifiable_Str := IS_PARM_MODIFIABLE (v_Parm_Name);
         v_Changed        := IS_CHANGED (v_Parm_Name, v_Parm_Value);
                           
      end if;
      
      INSERT INTO {{schema_name}}.DBA_DB_PARAM_SET 
         (NAME, VALUE, VALID, VALUE_CHANGED, IS_MODIFIABLE, ROW_SEC_LBL_ID, CREATION_CAL_DT_TM, CREATOR_ID)
      VALUES 
         (v_Parm_Name, v_Parm_Value, v_Valid_Str, v_Changed, v_Modifiable_Str, 1000, SYSDATE, 'SYS');
      COMMIT;
             
   END;
   
   
   -----------------------------------------------------------------------
   --   Change all of the parameters..if the values have actually changed
   -----------------------------------------------------------------------
   procedure EXECUTE (p_Inspect_Only in varchar2)
   AS
   
      v_Change_Cnt           number;
      v_Reboot_Cnt           number;
      v_Invalid_Cnt          number;
      v_Inspect_Only         varchar2(10) := upper(p_Inspect_Only);
      v_Non_Modifiable_Cnt   number;
   
   
   BEGIN
   
      v_Reboot_Cnt := 0;
      select count(*) into v_Invalid_Cnt
      from {{schema_name}}.DBA_DB_PARAM_SET
      where VALID='N';      
      
      select count(*) into v_Change_Cnt
      from {{schema_name}}.DBA_DB_PARAM_SET
      where VALUE_CHANGED='Y';
      
      select count(*) into v_Reboot_Cnt
      from {{schema_name}}.DBA_DB_PARAM_SET
      where VALUE_CHANGED='Y'
      and   IS_MODIFIABLE='N';          
           
      if (v_Invalid_Cnt = 0) then
      
         if (v_Change_Cnt = 0) then
            dbms_output.put_line ('~~NO_CHANGE~~');
         else
            if (v_Inspect_Only  = 'TRUE') then
               SET_PARMS;
            end if;               

            if (v_Reboot_Cnt > 0) then
               dbms_output.put_line ('~~REBOOT_REQUIRED~~');              
            end if;
            
            for cur_row in (select NAME from {{schema_name}}.DBA_DB_PARAM_SET where VALUE_CHANGED='Y') loop
               dbms_output.put_line ('~~CHANGED_PARM~~' || ' Name: ' || cur_row.NAME);
            end loop;
            
         end if;                
      
      else
         for cur_row in (select NAME from {{schema_name}}.DBA_DB_PARAM_SET where VALID='N') loop
            dbms_output.put_line ('~~INVALID_PARM~~' || ' Name: ' || cur_row.NAME);
         end loop;
      end if;                                       
   
   END;
   
   
   -----------------------------------------------------------------------
   --   Execute the system commands to set the parameter values.   Only
   --   those parameters whose value has changed from the existing value
   --   will be set to the new value.
   -----------------------------------------------------------------------
   procedure SET_PARMS
   AS
      v_Sql  varchar2(10000);   
   
   BEGIN
   
      for cur_row in (select name, value, IS_MODIFIABLE 
                      from {{schema_name}}.DBA_DB_PARAM_SET
                      where VALUE_CHANGED='Y') loop
                      
         if (cur_row.IS_MODIFIABLE = 'Y') then
            v_Sql := 'ALTER SYSTEM SET ' || cur_row.name || '=' || cur_row.value;
            if (v_Debug_Flag = 'Y') then
               dbms_output.put_line (v_Sql);
            end if;
            execute immediate v_Sql;
         else
            v_Sql := 'ALTER SYSTEM SET ' || cur_row.name || '=' || cur_row.value || ' SCOPE=SPFILE';
            
            if (v_Debug_Flag = 'Y') then
               dbms_output.put_line (v_Sql);
            end if;
            execute immediate v_Sql;
         end if;            
                                                    
      end loop;
      
   END;
   

   PROCEDURE TABLE_EXISTS_CHECK

   AS

     v_Cnt  number;
     v_Sql  varchar2(500);

   BEGIN

      select count(*) into v_Cnt
      from DBA_TABLES 
      where owner='{{schema_name}}'
      and   table_name='DBA_DB_PARAM_SET';

      if (v_Cnt = 1) then
         dbms_output.put_line('DBA_DB_PARAM_SET__ALREADY_EXISTS');
      else
         dbms_output.put_line('DBA_DB_PARAM_SET__DOES_NOT_EXIST');
      end if;

   END;

END;
/

