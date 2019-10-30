whenever sqlerror continue
set echo off
spool show_table_locks.lst

set linesize 1000
set serveroutput on

declare
  host    VARCHAR2(64);
  sid     number;
  serial  number;
  schema  VARCHAR2(30);
  ltype   VARCHAR2(2);
  held    number(4);
  lmode   number(4);
  request number(4);
  ctime   number(28);
  blocks  number(4);
  name    VARCHAR2(128);
  osuser  VARCHAR2(30);
  program VARCHAR2(48);
  pid     VARCHAR2(24);

  cursor  cs_locks is
    select
      s.sid SID,
      s.serial#,
      s.schemaname,
      s.machine,
      s.OSUSER,
      s.PROGRAM,
      s.PROCESS,
      l.type,
      o.object_name,
      l.lmode,
      l.request,
      l.block,
      l.ctime / 60
    from
      v$lock l,
      v$session s,
      v$process p,
      sys.dba_objects o
    where
      s.sid = l.sid and
      o.object_id = l.id1 and
      s.username <> ' ' and
      s.paddr = p.addr
    union
    select
      s.sid,
      s.serial#,
      s.schemaname,
      s.machine,
      s.OSUSER,
      s.PROGRAM,
      s.PROCESS,
      l.type,
      '(Rollback='||rtrim(r.name)||')' object_name,
      l.lmode,
      l.request,
      l.block,
      l.ctime / 60
    from
       v$lock l,
       v$session s,
       v$process p,
       v$rollname r
    where
       s.sid = l.sid and
       l.type = 'TX' and
       l.lmode = 6 and
       trunc(l.id1/65536) = r.usn and
       s.username <> ' ' and
       s.paddr = p.addr;
    begin
       dbms_output.put_line('|                  Host                    |  on schema   | lock type |            table name          | locked since | lock mode |      user      |   program   |   pid   | sid | serial | held | blocks  ');
       dbms_output.put_line('|------------------------------------------|--------------|-----------|--------------------------------|--------------|-----------|----------------|-------------|---------|-----|--------|------|---------');

  open cs_locks;
  loop
    fetch cs_locks into sid, serial, schema, host, osuser, program, pid, ltype, name, lmode, request, blocks, ctime;
    exit when cs_locks%notfound;

    if ltype = 'TM' or ltype = 'TX' then
       dbms_output.put('| '||rpad(host,40)||' | '
        ||rpad(schema,12)||' | '
        ||rpad(ltype,9)||' | '
        ||rpad(name,30)||' | '
        ||rpad(to_char(ctime)||'m',12)||' | '
        ||rpad(lmode,9)||' | '
        ||rpad(osuser,14)||' | '
        ||rpad(program,11)||' | '
        ||rpad(pid,7)||' | '
        ||rpad(sid,5)||' | '
        ||rpad(serial,6)||' | '
        ||rpad(request,4)||' | '
        ||blocks);
       dbms_output.put_line('');
    end if;
  end loop;
  close cs_locks;
end;
/

exit success

