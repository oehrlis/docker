----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: tvd_hr_main.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2018.10.24
--  Revision..:  
--  Purpose...: Main script to create the TVD_HR schema
--  Notes.....:  
--  Reference.: SYS (or grant manually to a DBA)
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- Simple example how to get path (@@) of the current script.
rem This script will set "cur_path" variable, so we can use &cur_path later.
  
set termout off
spool _cur_path.remove
@@notfound
spool off;
  
var cur_path varchar2(100);
declare
  v varchar2(100);
  m varchar2(100):='SP2-0310: unable to open file "';
begin v :=rtrim(ltrim( 
                        q'[
                            @_cur_path.remove
                        ]',' '||chr(10)),' '||chr(10));
  v:=substr(v,instr(v,m)+length(m));
  v:=substr(v,1,instr(v,'notfound.')-1);
  :cur_path:=v;
end;
/
set scan off;
ho (rm _cur_path.remove 2>&1  | echo .)
ho (del _cur_path.remove 2>&1 | echo .)
col cur_path new_val cur_path noprint;
select :cur_path cur_path from dual;
set scan on;
set termout on;

@&cur_path/sql/tvd_hr_main.sql tvd_hr users temp /tmp

exit
-- EOF ---------------------------------------------------------------------