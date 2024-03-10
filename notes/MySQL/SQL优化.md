# SQL语句优化

## 插入数据优化

* 批量插入，insert
* 手动事务提交
* 主键顺序插入

大批量插入数据，通过load指令将本地文件一次性加入到数据库中。

本地文件可以是csv,excel,sql文件等

## 主键优化

表数据都是根据主键顺序组织存放的，这种存储方式的表成为索引组织表（index organized table IOT）

插入时，如果主键不是按照顺序插入的，可能会出现**页分裂**。需要向一个数据page中插入时，空间不足，需要申请新的数据page，并进行数据的copy和移动，带来不必要的存储和性能开销。

### 主键的设计原则

* 在满足业务需求的情况下，尽量降低主键的长度。
* 插入时，尽量选择顺序插入，选择使用自增主键
* 尽量不要使用其他uuid做主键或者其他自然主键，如身份证号
* 业务操作时，尽量避免对主键修改

## OrderBy优化

排序有两种方式

* Using filesort：通过表的索引或者全表扫描，读取满足条件的数据行，然后在排序缓冲区sort buffer中完成排序操作，所有不是通过索引直接返回排序结果的排序都叫做filesort排序

* Using index：通过有序索引顺序扫描返回有序数据，这种情况即为using index，不需要额外排序，操作效率高。

order by的字段的顺序会影响使用索引的情况（最左前缀匹配）

```mysql
create index index_user on user(age asc, name desc);
```

可以在创建索引时指定排序方式。

如果没有使用覆盖索引，那么会使用filesort的方式

## Group By优化

创建索引优化性能。注意：

* 如果使用联合索引，需要满足最左前缀匹配，这个的字段可以出现在where子句中也可以出现在group by的字段中

## limit优化

在大数据场景下，如果不建立索引，limit的起始位置越靠后，所需要的时间就越久。

此时可以考虑连表查询，利用聚合索引，只获取id，然后拿到id后再去查表得到数据的具体内容

## count优化

count某个字段，如果字段值为null，则不会被count，否则被count记录（count++）

按照效率排序：

count(字段) < count(主键id) < count(1) ≈ count(*) 

## Update优化

行锁概念

执行update时，符合where条件的行会被锁住，其他行仍然还可以进行操作

如果where查询的字段没有索引，那么会直接进行表锁，而非行锁

```mysql
update course set name = 'lsp' where id=1;
```

```mysql
update course set name = 'lsp' where id='psl';
```

上面两个语句，第一个语句为行锁，第二个语句则会表锁

