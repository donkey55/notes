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

### 条件查询 (where)

语法

```mssql
select 字段列表 from 表名 where 条件列表;
```

条件

| 比较运算符          | 功能                                                         |
| ------------------- | ------------------------------------------------------------ |
| `>`                 | 大于                                                         |
| `>=`                | 大于等于                                                     |
| `<`                 | 小于                                                         |
| `<=`                | 小于等于                                                     |
| `=`                 | 等于                                                         |
| `<>`或`!=`          | 不等于                                                       |
| between..... and... | 在某个范围之内（含最小值、最大值）`select * from emp where age between 15 and 20;` |
| in()                | 在in之后的列表中的值，多选一                                 |
| like 占位符         | 模糊匹配（_匹配单个字符，%匹配任意数量字符）`select * from emp where name like '__'` 查询name为两个字的员工 |
| is null             | 是NULL                                                       |

| 逻辑运算符 | 功能                 |
| ---------- | -------------------- |
| and 或 &&  | 多个条件同时成立     |
| or 或 \|\| | 多个条件任意一个成立 |
| not 或 !   | 非                   |

### 聚合函数

  作用于某一列数据，将其作为整体进行纵向计算。

| 函数  | 作用     |
| ----- | -------- |
| count | 统计数量 |
| max   | 最大值   |
| min   | 最小值   |
| avg   | 平均值   |
| sum   | 求和     |

用法

```mysql
select 聚合函数(字段列表) from 表名;
```

> 所有null值不参与计算

### 分组查询

语法

```mysql
select 字段列表 from 表名 [where 条件] group by 分组字段名 [having 分组后过滤条件];
```

其中where 和 having区别：

* 执行时机不同：where是分组之前进行过滤，不满足where条件，不参与分组；而having是分组之后对结果进行过滤。
* 判断条件不同：where不能对聚合函数进行判断，而having可以

执行顺序：where > 聚合函数 > having

**分组之后，查询的字段一般为聚合函数和分组字段，查询其他字段无任何意义。**

### 排序查询

语法

```mysql
select 字段列表 from 表明 order by  字段1 排序方式1, 字段2 排序方式2;
```

排序方式：

* ASC：升序
* DESC：降序

如果是多字段排序，当第一个字段值相同时，才会根据第二个字段进行排序

### 分页查询

语法

```mysql
select 字段列表 from 表名 limit 起始索引, 查询记录数;
```

* 起始索引从0开始，起始索引=（查询页码-1）* 每页显示记录数
* 分页查询是数据库的方言，不同的数据库有不同的实现，mysql中是limit
* 如果查询的是第一页的内容，起始索引可以省略，直接简写为limit 10

## DCL

数据控制语言，用来控制数据库用户、控制数据库的访问权限。

查询用户

```mysql
use mysql;
select * from user;
```

创建用户

```mysql
create user '用户名'@'主机名' identified by '密码'
```

修改用户密码

```mysql
alter user '用户名'@'主机名' identified with mysql_native_password by '新密码';
```

删除用户

```mysql
drop user '用户名'@'主机名';
```

### 权限控制

略
