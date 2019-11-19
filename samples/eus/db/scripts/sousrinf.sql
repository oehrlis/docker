rem ---------------------------------------------------------------------------
rem  Trivadis AG, Baden-Dättwil/Basel/Bern/Lausanne/Zürich
rem               Düsseldorf/Frankfurt/Freiburg i.Br./Hamburg/München/Stuttgart
rem               Wien
rem               Switzerland/Germany/Austria Internet: http://www.trivadis.com
rem ---------------------------------------------------------------------------
rem $Id: sousrinf.sql 29 2008-11-20 10:51:46Z cha $
rem ---------------------------------------------------------------------------
rem  Group/Privileges.: User
rem  Script Name......: sousrinf.sql
rem  Developer........: Sven Vetter (SvV)
rem  Date.............: 15.08.2002
rem  Version..........: Oracle Database 11g
rem  Description......: Shows information about the connected user
rem  Usage............: 
rem  Input parameters.: 
rem  Output...........: 
rem  Called by........:
rem  Requirements.....: 
rem  Remarks..........: 
rem
rem ---------------------------------------------------------------------------
rem Changes:
rem DD.MM.YYYY Developer Change
rem ---------------------------------------------------------------------------
rem 09.09.2003 AnK       OK for 10.1
rem 20.11.2008 ChA       Fixed header + OK for 11g + Replaced/removed deprecated 
rem                      USERENV parameters + Added instance name + Replaced
rem                      HOST with SERVER_HOST
rem ---------------------------------------------------------------------------

set echo off
SET serveroutput on size 10000
DECLARE
  vSessionRec  v$session%ROWTYPE;
BEGIN
  SELECT * INTO vSessionRec 
    FROM v$session 
    WHERE audsid=USERENV('sessionid') AND type='USER' AND rownum<2;
    
  dbms_output.put_line('Database Information');
  dbms_output.put_line('--------------------');
  dbms_output.put_line('- DB_NAME               : '||sys_context('userenv','DB_NAME'));
  dbms_output.put_line('- DB_DOMAIN             : '||sys_context('userenv','DB_DOMAIN'));
  dbms_output.put_line('- INSTANCE              : '||sys_context('userenv','INSTANCE'));
  dbms_output.put_line('- INSTANCE_NAME         : '||sys_context('userenv','INSTANCE_NAME'));
  dbms_output.put_line('- SERVER_HOST           : '||sys_context('userenv','SERVER_HOST'));
  dbms_output.put_line('-');

  dbms_output.put_line('Authentification Information');
  dbms_output.put_line('----------------------------');
  dbms_output.put_line('- SESSION_USER          : '||sys_context('userenv','SESSION_USER'));
  dbms_output.put_line('- PROXY_USER            : '||sys_context('userenv','PROXY_USER'));
  dbms_output.put_line('- AUTHENTICATION_METHOD : '||sys_context('userenv','AUTHENTICATION_METHOD'));
  dbms_output.put_line('- IDENTIFICATION_TYPE   : '||sys_context('userenv','IDENTIFICATION_TYPE'));
  dbms_output.put_line('- NETWORK_PROTOCOL      : '||sys_context('userenv','NETWORK_PROTOCOL'));
  dbms_output.put_line('- OS_USER               : '||sys_context('userenv','OS_USER'));
  dbms_output.put_line('- AUTHENTICATED_IDENTITY: '||sys_context('userenv','AUTHENTICATED_IDENTITY'));
  dbms_output.put_line('- ENTERPRISE_IDENTITY   : '||sys_context('userenv','ENTERPRISE_IDENTITY'));
  dbms_output.put_line('-');

  dbms_output.put_line('Other Information');
  dbms_output.put_line('-----------------');
  dbms_output.put_line('- ISDBA                 : '||sys_context('userenv','ISDBA'));
  dbms_output.put_line('- CLIENT_INFO           : '||sys_context('userenv','CLIENT_INFO'));
  dbms_output.put_line('- PROGRAM               : '||vSessionRec.program);
  dbms_output.put_line('- MODULE                : '||vSessionRec.module);
  dbms_output.put_line('- IP_ADDRESS            : '||sys_context('userenv','IP_ADDRESS'));
  dbms_output.put_line('- SID                   : '||vSessionRec.sid);
  dbms_output.put_line('- SERIAL#               : '||vSessionRec.serial#);
  dbms_output.put_line('- SERVER                : '||vSessionRec.server);
  dbms_output.put_line('- TERMINAL              : '||sys_context('userenv','TERMINAL'));

 

END;
/
