whenever sqlerror continue
set echo off
spool open_sessions.sql

set pagesize 9999
set linesize 1024

column pid format a8
column sid format a8
column ser# format a8
column machine format a30
column username format a20
column osuser format a20
column program format a40
column ACTION format a40

select
       substr(a.spid,1,8) pid,
       substr(b.sid,1,8) sid,
       substr(b.serial#,1,8) ser#,
       b.machine,
       b.username,
       b.osuser,
       b.program,
       b.ACTION
from v$session b, v$process a
where
  b.paddr = a.addr
  and type='USER'
  order by spid;


column sql_text format a80

select
      b.username,
      s.rows_processed,
      s.sql_text
from v$session b, v$sql s
where
  s.sql_id = b.sql_id
  and b.sql_id is not null
  order by b.username;

exit success
