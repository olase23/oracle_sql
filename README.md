# oracle_sql

Different small oracle sql scripts. 

## show_table_locks.sql 
Shows the current table locks.   
<br>
output:
<br>
|                  Host                    |  on schema   | lock type |            table name          | locked since | lock mode |      user      |   program   |   pid   | sid | serial | held | blocks  
|------------------------------------------|--------------|-----------|--------------------------------|--------------|-----------|----------------|-------------|---------|-----|--------|------|---------
| linux.suse                               | HR           | TM        | EMPLOYEES                      | 0m           | 3         | testuser       | SQL Develop | 6959    | 35  | 45     | 0    | 0
| linux.suse                               | HR           | TX        | (Rollback=_SYSSMU6_725569783$) | 0m           | 6         | testuser       | SQL Develop | 6959    | 35  | 45     | 0    | 0

<br>
