#  MySQL语法

不区分大小写

## DDL

> 数据库操作语句

查询所有数据库

```mysql
SHOW DATEBASES;
```

查询当前数据库

```mysql
SELECT DATABASE();
```

创建数据库

```mysql
create database [if not exists] 数据库名 [default charset 字符集] [collate 排序规则]
# eg:
create database lsp;
create database if not exists lsp;
```

删除数据库

```mysql
drop database [if exists] 数据库名;

# eg
drop database lsp;
```

使用数据库

```mysql
use 数据库名;
```

创建表

```mysql
create table 表名(
	字段1 字段1类型[comment 字段1注释],
    ...
    
)[comment 表注释];

# eg:
create table tb_user(
    id int comment "用户id",
    name varchar(256) comment "用户name") comment 'user';

```



查看当前数据库的所有表

```mysql
show tables;
```

查询表结构

```mysql
desc 表名;
```

表结构的修改

向表中添加字段

```mysql
alter table 表名 add 字段名 类型(长度) [comment 注释];
```

 修改数据类型

```mysql
alter table 表名 modify 字段名 新数据类型(长度); 
```

修改字段名和字段 类型

```mysql
alter table 表名 change 旧字段名 新字段名  类型(长度) [comment 注释] [约束];
```

删除字段

```mysql
alter table 表名 drop 字段名;
```

修改表名

```mysql
alter table 表名 rename to 新表名;
```

删除表

```mysql
drop table [if exists] 表名;
```

删除表病重新创建该表

```mysql
truncate table 表名;
```

## DML

> 数据修改

### 添加数据

给指定字段添加数据

```mysql
insert into 表名 (字段名1, 字段名2, ...) values (值1, 值2, ...);
```

给全部字段添加数据

```mysql
insert into 表名 values (值1, 值2, ...);
```

批量添加数据

```mysql
insert into 表名 (字段名1, 字段名2, ...) values (值1, 值2, ...), (值1, 值2, ...),(值1, 值2, ...);
insert into 表名 values (值1, 值2, ...), (值1, 值2, ...), (值1, 值2, ...);
```

> 插入的字符串和日期类型应该包含在引号中

### 修改数据

```mysql
update 表名 set 字段名1=值1, 字段名2=值2, ...[where 条件];
#eg:
update tb_user set age = 3 where id = 12;
```

> 如果没有条件语句，则会修改整个表的数据！

### 删除数据

```mysql
delete from 表名 [where 条件];
```

> * 如果没有条件语句，则会删除全部数据
> * 不能删除某个字段的值，只能删除某条数据

## DQL

> 查询语句

```mysql
select 
	字段列表
from
	表名列表
where 
	条件列表
group by
	分组字段列表
having
	分组后条件列表
order by
	排序字段列表
limit
	分页参数
```

### 基本查询

查询多个字段

```mysql
select 字段1, 字段2, ... from 表名;
select * from 表名;
```

设置别名

```mysql
select 字段1[as 别名1], 字段2[as 别名2], ... from 表名;
```

> 在设置别名时，可以省略as

```mysql
select id ID from tb_user;
```

去除重复记录

```mysql
select distinct 字段列表 from 表名;
```



条件查询 (where)

聚合函数

分组查询

排序查询

分页查询
