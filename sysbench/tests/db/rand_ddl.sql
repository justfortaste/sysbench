CREATE DATABASE IF NOT EXISTS test;
USE test;

DROP PROCEDURE IF EXISTS  add_col;
delimiter //
CREATE PROCEDURE  add_col (IN tabname varchar(64), IN colname varchar(64), IN col_type varchar(100))
BEGIN
    DECLARE have_col int;
    select count(*) into have_col from  information_schema.columns where TABLE_NAME=tabname and COLUMN_NAME=colname;

    if have_col=0 then
          SET @sqlcmd = CONCAT('ALTER TABLE ', tabname, ' ADD ',  colname, ' ', col_type);
          PREPARE stmt FROM @sqlcmd;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;

   end if;
END;
//
delimiter ;

DROP PROCEDURE IF EXISTS  drop_col;
delimiter //
CREATE PROCEDURE  drop_col (IN tabname varchar(64), IN colname varchar(64))
BEGIN

    DECLARE have_col int;

    select count(*) into have_col from  information_schema.columns where TABLE_NAME=tabname and COLUMN_NAME=colname;

    if have_col > 0 then
          SET @sqlcmd = CONCAT('ALTER TABLE ', tabname, ' drop ',  colname);
          PREPARE stmt FROM @sqlcmd;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;

   end if;
END;
//
delimiter ;


DROP PROCEDURE IF EXISTS  add_index;
delimiter //
CREATE PROCEDURE  add_index (IN dbname varchar(64), IN tabname varchar(64), IN indexname varchar(64), IN colname varchar(64))
BEGIN
    DECLARE have_col int;
    DECLARE have_index int;

    set @read_tname=concat(dbname, '/', tabname);
    select count(*) into have_col from  information_schema.columns where TABLE_NAME=tabname and COLUMN_NAME=colname;
    select count(*) into have_index  from information_schema.INNODB_SYS_TABLES t, information_schema.INNODB_SYS_INDEXES i where t.name=@read_tname and  t.table_id=i.table_id and i.name=indexname;

    if  (have_col > 0 and have_index = 0)  then
          SET @sqlcmd = CONCAT('ALTER TABLE ', tabname, ' add index ', indexname, '  (', colname,')');
          PREPARE stmt FROM @sqlcmd;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;
   end if;
END;
//
delimiter ;


DROP PROCEDURE IF EXISTS  add_index2;
delimiter //
CREATE PROCEDURE  add_index2 (IN dbname varchar(64), IN tabname varchar(64), IN indexname varchar(64), IN colname1 varchar(64), IN colname2 varchar(64))
BEGIN
    DECLARE have_col1 int;
    DECLARE have_col2 int;
    DECLARE have_index int;

    set @read_tname=concat(dbname, '/', tabname);
    select count(*) into have_col1 from  information_schema.columns where TABLE_NAME=tabname and COLUMN_NAME=colname1;
    select count(*) into have_col2 from  information_schema.columns where TABLE_NAME=tabname and COLUMN_NAME=colname2;
    select count(*) into have_index  from information_schema.INNODB_SYS_TABLES t, information_schema.INNODB_SYS_INDEXES i where t.name=@read_tname and  t.table_id=i.table_id and i.name=indexname;

    if  (have_col1 > 0  and have_col2 > 0 and have_index = 0)  then
          SET @sqlcmd = CONCAT('ALTER TABLE ', tabname, ' add index ', indexname, '  (', colname1,',',colname2,')');
          PREPARE stmt FROM @sqlcmd;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;

   end if;
END;
//

delimiter ;




DROP PROCEDURE IF EXISTS  drop_index;
delimiter //
CREATE PROCEDURE  drop_index (IN dbname varchar(64), IN tabname varchar(64), IN indexname varchar(64))
BEGIN
    DECLARE have_index int;
    set @read_tname=concat(dbname, '/', tabname);
    select count(*) into have_index  from information_schema.INNODB_SYS_TABLES t, information_schema.INNODB_SYS_INDEXES i where t.name=@read_tname and  t.table_id=i.table_id and i.name=indexname;

    if  (have_index > 0)  then
          SET @sqlcmd = CONCAT('ALTER TABLE ', tabname, ' drop index ', indexname);
          PREPARE stmt FROM @sqlcmd;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;
   end if;
END;
//
delimiter ;


show create table sbtest1\G
call add_col('sbtest1', 'c1');
call add_col('sbtest1', 'c1');
show create table sbtest1\G
call drop_col('sbtest1', 'c1');
call drop_col('sbtest1', 'c1');
show create table sbtest1\G


call add_col('sbtest1', 'c1');
call add_col('sbtest1', 'c2');
show create table sbtest1\G


show create table sbtest1\G
call add_index('test','sbtest1', 'idx1','c1');
call add_index('test','sbtest1', 'idx1','c1');
show create table sbtest1\G
call add_index2('test','sbtest1', 'idx2','c1','c2');
call add_index2('test','sbtest1', 'idx2','c1','c2');
show create table sbtest1\G

call drop_index('test','sbtest1', 'idx1');
call drop_index('test','sbtest1', 'idx1');
show create table sbtest1\G
call drop_index('test','sbtest1', 'idx2');
call drop_index('test','sbtest1', 'idx2');
show create table sbtest1\G


