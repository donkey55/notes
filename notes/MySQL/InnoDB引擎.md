# InnoDB引擎

## 逻辑存储结构

![image-20240304154821415](https://s2.loli.net/2024/03/04/sNEfSIYgjzk5btJ.png)

## 内存结构

**Buffer Pool**：缓冲池是主内存中的一个区域，里面可以缓存磁盘上经常操作的真实数据，在执行增删改查操作时，先操作缓冲池中的数据（若缓冲池没有数据，则从磁盘加载并缓存），然后再以一定频率刷新到磁盘，从而减少磁盘IO，加快处理速度。

缓冲池以page页为单位，底层采用链表数据结构管理page。根据状态，讲Page分为三种类型：

free page： 空闲page，未被使用

clean page：被使用的page，但是数据并未被修改过

dirty page：脏页，被使用的page，数据被修改过，其中的数据与磁盘的数据长生了不一致。

**change buffer**：更改缓冲区（针对非唯一二级索引页）。如果这些数据Page没有在buffer Pool中，不会直接操作磁盘，而会将数据变更存在change buffer中，在未来数据被读取时，再将数据合并恢复到Buffer Pool中，再将合并后的数据刷新到磁盘中。

Adaptive Hash index：自适应hash索引，用于优化对Buffer Pool数据的查询。InnoDB存储引擎会监控对表上各索引页的查询，如果观察到hashs索引可以提升速度，则建立hash索引，称之为自适应hash索引。这个过程是系统自动完成的。

**Log Buffer**: 日志缓冲区，用来保存要写入到磁盘中的log日志数据 (redo log 、undo log)，默认大
小为 16MB，日志缓冲区的日志会定期刷新到磁盘中。如果需要更新、插入或删除许多行的事务，增加
日志缓冲区的大小可以节省磁盘1/0
参数:
innodb log buffer size: 缓冲区大小
innodb flush log at trx commit: 日志刷新到磁盘时机，取值：

* 0,每秒将日志写入并刷新磁盘一次
* 1：日志在每次事务提交时写入并刷新到磁盘
* 2：日志在每次事务提交后写入，并每秒刷新到磁盘一次。

## 磁盘结构

![image-20240319171205367](https://s2.loli.net/2024/03/19/Bg6ryKfiRktVbvF.png)

### System tablespace

系统表空间是更改换冲区（Change buffer）的存储区域。如果InnoDB没有打开独立表空间，那么表和索引的表空间也会在这里存储

### File-Per-Table tablespaces

每个表的文件表空间包含单个InnoDB表的数据和索引，并存储在文件系统中的单个数据文件中。

### General Tablespaces

通用表空间，默认没有这个存储区域，需要通过create tablespace 语法创建通用表空间，在创建表时，可以指定该表空间

```mysql
create tablespace ts_1 add datafile 'xxx.ibd' engine = innodb

create table ooo(id int primary key auto_increment, name varchar(10)) engine=innodb tablespace ts_1; 
```

### Temporary Tablespaces

InnoDB使用会话临时表空间和全局临时表空间，存储用户创建的临时表等数据

### Undo Tablespaces

撤销表空间，MySQL实例在初始化时会自动创建两个默认的Undo表空间（初始化大小16M），用于存储Undo log 日志

### Redo Log

Redo Log:重做日志，是用来实现事务的持久性。该日志文件由两部分组成:重做日志缓冲(redo log buffer)以及重做日志文件(redo log),前者是在内存中，后者在磁盘中。当事务提交之后会把所有修改信息都会存到该日志中,用于在刷新脏页到磁盘时,发生错误时,进行数据恢复使用。

以循环方式写入重做日志文件

### Doublewrite Buffer Files

双写缓冲区，innoDB引擎将数据页从Buffer Pool刷新到磁盘前，先将数据页写入双写缓冲区文件中，便于系统异常时恢复数据。

## 后台线程

![image-20240304165340093](https://s2.loli.net/2024/03/04/sY61MguElkvizf3.png)

## 事务原理

原子性、一致性和持久性是由redo log和undo log来保证的

隔离性是由锁机制和mvcc保证的

### redo log

保证持久性

记录的是事务提交时数据页的物理修改，用来实现事务的持久性。

该日志文件由两部分组成：重做日志缓冲以及重做日志文件，前者是在内存中，后者是在磁盘中。当事务提交之后，会把所有修改信息都存到该日志文件中，用于在刷新脏页到磁盘，发生错误时，进行数据恢复使用

> 简单来说，redo log就是在我们对数据进行增删改后，由于会数据内容存储在buffer pool中，并不会立刻刷新到磁盘中，redo log就是会记录修改的信息，然后写入到redo buffer，并立刻刷新到磁盘中，如此在buffer pool中的数据刷新到磁盘出现错误时，可以利用redo log 来恢复。这里用到的思想是 **WAL（Write-Ahead Logging）**
>
> **思考**：如果redo log写入失败怎么办？

### Undo log 

实现原子性

回滚日志。用于记录数据被修改前的信息。作用包含两个：

* 提供回滚
* MVCC（多版本并发控制）

undo log中记录的是逻辑日志，即如果操作的时候为delete记录，那么undo log会记录对应的insert 记录。在执行roll back时，就可以从undo log中的逻辑记录读取相应的内容并进行回滚。

Undo log 销毁：Undo log在事务执行时产生，事务提交时，并不会立刻删除undo log，因为这些日志可能还用于MVVC

undo log 存储：undo log采用段的方式进行管理和记录，存放在前面介绍的roll back segment回滚段中，内部包含1024个undo log segement。

## MVVC

### 基本概念

* 当前读
  * 读取的时记录的最新版本，读取时还要保证其他并发事务不能修改当前记录，会对读取的记录进行加锁。对于我们日常的操作，如：select....for share, select ... for update、insert、delete（排他锁）都是一种当前读。
* 快照读
  * 简单的select（不加锁）就是快照读，快照都，读取的是记录数据的可见版本，有可能是历史数据，不加锁，是非阻塞读。

**mvvc**，多版本并发控制。指维护一个数据的多个版本，使得读写操作没有冲突，快照读为MySQL实现MVCC提供了一个非阻塞读功能。MVCC的具体实现依赖于数据库记录中的三个隐式字段、undo log日志、readview。

### 实现原理

#### 记录中的隐藏字段

DB_TRX_ID:最近修改事务ID，记录插入这条记录或最后一次修改该记录的事务ID

DB_ROLL_PTR：回滚指针，指向这条记录的上一个版本，用于配合undo log，指向上一个版本。

DB_ROW_ID：隐藏主键，如果表结构没有指定主键，将会生成该隐藏字段。

#### undo log 链

可以理解为一个undo log记录上都有一个指针会指向上次修改之前的记录。这样就形成了一个链表

链表头部存储在当前的表记录中（这时候没刷新到磁盘中），即代表着最新的记录，链表尾部存储着最旧的记录。

记录中时包括了上面的隐藏字段的。

#### readivew

readview 是快照读SQL执行时MVVC提取数据的依据，记录并维护系统当前活跃的事务（未提交的）id。

readview 包含了四个核心字段：

- m_ids。当前活跃的事务ID集合

- min_trx_id。最小活跃事务ID

- max_trx_id。预分配事务ID，当前最大事务ID + 1，即下一个即将分配的事务id

- creator_trx_id.ReadVIew创建者的事务ID。

#### 具体分析

在默认的RR级别下，通过undo log链和readview中记录的信息来保证可重复读

RR级别下，在一个事务中，只有在第一次执行快照读时生成ReadView（其实就是生成一个数据结构对象，其中包含了上面讲的一些字段信息，后面根据这个字段信息去undo log里面查找需要的版本），后续复用此readview。

在这个中有一个比较规则，从undo 链表的头部开始查找记录是否能够被当前事务读取。

比较规则比较的是隐藏字段中的DB_TRX_ID 和 当前readview上面的四个核心字段来进行比较。如果符合条件，则执行对应操作：可以读取当前版本记录，或者不可以读取当前版本记录。







