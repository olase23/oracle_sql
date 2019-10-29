whenever sqlerror continue
set echo off
spool tablespace_info.log

set linesize			120
set pagesize		  4096

set serveroutput 		on

-- show tablespace usage
declare
	tsname varchar(30);
	dummy varchar(30);
	fbytes number;
	sbytes number;
	usage  number;
	fauto  boolean;
	fext   boolean		:= FALSE;
	cy 	integer		:= 0;
	rc	integer		:= 0;
	stmt1	varchar2(2000)	:= 'select tablespace_name from sys.filext$ fe, sys.dba_data_files df where fe.file# = df.file_id and tablespace_name = ''';
	stmt2	varchar2(2000)	:= ''' group by tablespace_name';

	cursor cs is select tablespace_name, sum(bytes)
			from sys.dba_data_files
			group by tablespace_name;

	cursor cf is select sum(bytes)
			from sys.dba_free_space
			where tablespace_name = tsname;

	cursor cx is select table_name
			from all_catalog
			where TABLE_NAME = 'FILEXT$';

begin
	open cx;
		fetch cx into dummy;
		if cx%found then
			fext := TRUE;
		end if;
	close cx;

	dbms_output.put_line('|  Tablespace   | size MB  | used MB  | free MB  |usage %| Hints');
	dbms_output.put_line('|---------------|----------|----------|----------|-------|------');
	open cs;
	loop
		fetch cs into tsname, sbytes;
		exit when cs%notfound;

		dbms_output.put('|'||rpad(tsname,15)||'|'||lpad(sbytes/1024/1024,10));

		open cf;
			fetch cf into fbytes;
			if cf%found then

				if fbytes is null then
					fbytes := 0;
				end if;

				dbms_output.put('|'||lpad((sbytes-fbytes)/1024/1024,10));
				dbms_output.put('|'||lpad(fbytes/1024/1024,10));

				usage := round((1-fbytes/sbytes)*100);
				dbms_output.put('|'||lpad(usage,7)||'|');

				fauto := FALSE;

				if fext then
					cy := dbms_sql.open_cursor;
						dbms_sql.parse(cy, stmt1||tsname||stmt2, DBMS_SQL.V7);
						rc := dbms_sql.execute(cy);
						if rc = 0 then
							dbms_sql.define_column(cy,1,dummy,30);
							rc := dbms_sql.fetch_rows(cy);
							if rc > 0 then
								fauto := TRUE;
							end if;
						end if;
					dbms_sql.close_cursor(cy);
				end if;

				if fauto then
					dbms_output.put(' Autoextended Datafile(s)!');
				else
					if  usage >= 90 then
						dbms_output.put(' Increase the size of Tablespace!');
					end if;
				end if;

			end if;
		close cf;

		dbms_output.put_line('');

	end loop;
	close cs;

end;
/

-- get used data files per tablespace
select tablespace_name  "TableSpace",
	file_name "File-Name",
	STATUS "Status"
	from sys.dba_data_files
	order by tablespace_name;

prompt;
declare
	tsname  varchar2(30);
	filen 	varchar2(257);
	cy 	integer		:= 0;
	rc	integer		:= 0;
	stmt1	varchar2(2000)	:= 'select tablespace_name, file_name from sys.filext$ fe, sys.dba_data_files df where fe.file# = df.file_id order by tablespace_name, file_name';

	cursor cx is select table_name
			from all_catalog
			where TABLE_NAME = 'FILEXT$';
begin
	open cx;
		fetch cx into filen;
		if cx%found then
			cy := dbms_sql.open_cursor;
				dbms_sql.parse(cy, stmt1, DBMS_SQL.V7);
				rc := dbms_sql.execute(cy);
				if rc = 0 then
					dbms_output.put_line('|          Tablespace          | autoextended Databasefiles');
					dbms_output.put_line('|------------------------------|-------------------------------------------');
					dbms_sql.define_column(cy,1,tsname,30);
					dbms_sql.define_column(cy,2,filen,257);
					loop
						if dbms_sql.fetch_rows(cy) > 0 then
							dbms_sql.column_value(cy,1,tsname);
							dbms_sql.column_value(cy,2,filen);
							dbms_output.put_line('|'||rpad(tsname,30)||'|'||filen);
						else
							exit;
						end if;
					end loop;
				end if;
			dbms_sql.close_cursor(cy);
		end if;
	close cx;
end;
/

declare
	aowner  varchar2(30);
	oowner  varchar2(30) := '';
	tname  	varchar2(30);
	usedb	  number;
	quota	  number;
	countt	number;
	counti	number;
	qutxt	  varchar2(30);
	perc    varchar2(30);
	cursor cx is select owner, tablespace_name, sum(bytes)
			from sys.dba_extents
			group by OWNER,TABLESPACE_NAME
			order by OWNER,TABLESPACE_NAME;
	cursor cy is select max_bytes from sys.dba_ts_quotas
			where username = oowner and tablespace_name = tname ;
	cursor ct is select count(*) from all_tables
			where owner = oowner and tablespace_name = tname ;
	cursor ci is select count(*) from all_indexes
			where owner = oowner and tablespace_name = tname ;
begin
	dbms_output.put_line('|    User     | Tablespace  | Tables  | Indexes | used MB |quota MB |usage %');
	dbms_output.put_line('|-------------|-------------|---------|---------|---------|---------|-------');
	open cx;
		loop
		fetch cx into aowner,tname,usedb;
		exit when cx%notfound;
			if aowner = oowner then
				aowner := '';
			else
			  	oowner := aowner;
			end if;
			perc := '';
			open cy;
				fetch cy into quota;
				if cy%found then
					if quota < 0 then
						qutxt := 'unlimited';
					else
						qutxt := ' '||to_char(round(quota/1024/1024,0));
						perc  := ' '||to_char(round(usedb/quota*100,0));
						if usedb/quota*100 > 70 then perc := perc||' !'; end if;
						if usedb/quota*100 > 90 then perc := perc||'!'; end if;
						if usedb/quota*100 > 99 then perc := perc||'!'; end if;
					end if;
				else
					qutxt := 'undefined';
				end if;
			close cy;
			open ct; fetch ct into countt; if ct%notfound then countt := -1; end if; close ct;
			open ci; fetch ci into counti; if ci%notfound then counti := -1; end if; close ci;
			dbms_output.put_line(rpad('|'||aowner,14)||
					     rpad('|'||tname,14)||
				             rpad('| '||countt,10)||
				             rpad('| '||counti,10)||
					     rpad('| '||round(usedb/1024/1024,0),10)||
				             rpad('|'||qutxt,10)||
					     rpad('|'||perc,8));
		end loop;
	close cx;
end;
/

exit success
