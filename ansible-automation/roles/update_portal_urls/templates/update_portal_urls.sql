#!/bin/bash

#------------------------------------------------------------------------
#Northrop Grumman
#
# Name: portal_settings.sh
#
# Description:
#  This script is used to update the values in database table
#  cp_gapcie_ptportal.ptserverconfig with the following fields:
#     Primary Web Server URL
#     Display Files URL
#     Soap Server URL
#
#  The script takes the following inputs:
#     Input Argument 1.  Primary Web Server URL
#     Input Argument 2.  Display Files URL
#     Input Argument 3.  Soap Server URL
#
#  This script must be run as the ora_rmt user.
#--------------------------------------------------------------------------

#---------------------------------------------------------------------
#   Validate the script input argument
#---------------------------------------------------------------------
if [ $# -ne 3 ]; then
   echo "Script being Terminated. Expecting the following arguments: "
   echo " Primary Web Server URL "
   echo " Display Files URL "
   echo " Soap Server URL "
   exit;
fi

export WEB_URL=$1
export DISPLAY_URL=$2
export SOAP_URL=$3
export ORACLE_BASE=/opt/oracle/app
export ORACLE_HOME=$ORACLE_BASE/ora_rmt/product/11.2.0.4i
export ORACLE_SID=vciedb
export PATH=$ORACLE_HOME/bin:.:$PATH


#--------------------------------------------------------------------
#  Update CP_GAPCIE_PTPORTAL.PTSERVERCONFIG with the correct values
#--------------------------------------------------------------------
${ORACLE_HOME}/bin/sqlplus -s <<EOF
/ as sysdba

set echo off;
set term off;
set serveroutput on;
set timing on;

declare

begin

   update cp_gapcie_ptportal.ptserverconfig set value='$WEB_URL' where settingid=2;
   update cp_gapcie_ptportal.ptserverconfig set value='$DISPLAY_URL' where settingid=3;
   update cp_gapcie_ptportal.ptserverconfig set value='$SOAP_URL' where settingid=63;

   commit;

end;
/

exit;
EOF


