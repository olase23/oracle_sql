# oracle_sql

Different small PL/SQL helper scripts for Oracle databases. 

### show_table_locks.sql 
Shows the current locked tables with some additional informations like: user, host, sid, lock type, ...   
<br>
sqlplus system/xxxx@//127.0.0.1:1521/xe @show_table_locks.sql
<br>
It generates an output file named show_table_locks.lst in the same directory.
