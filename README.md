# oracle_sql

Different small PL/SQL helper scripts for Oracle databases.

### show_table_locks.sql
Shows the current locked tables with some additional informations like: user, host, sid, lock type, ...   
<br>
```
sqlplus system/xxxx@//127.0.0.1:1521/xe @show_table_locks.sql
```
<br>
It generates an output file named show_table_locks.lst in the same directory.
<br>

### open_sessions.sql
Shows current open sessions. Additional it show the cureent executed SQL.

<br>
```
sqlplus system/xxxx@//127.0.0.1:1521/xe @open_sessions.sql
```
<br>

### tablespace_info.sql
Shows all table spaces, data files and their current usage.

<br>
```
sqlplus system/xxxx@//127.0.0.1:1521/xe @open_sessions.sql
```
<br>
