# Redis持久化

>  [!TIP]
>
>  **RDB和AOF机制详解**

## RDB持久化

> [!NOTE]
>
> **RDB** 就是Redis DataBase 的缩写，中文名未快照/内存快照。RDB持久化是把当前进程数据生成快照保存在磁盘上的进程，由于是某一时刻的快照，那么快照种的值要早于或者等于内存中的值。

### 触发方式

触发rdb持久化的方式有两种，分别是手动触发和自动触发

#### 手动触发

* save命令：阻塞当前Redis服务器，直到RDB过程完成为止，对于内存比较大的实例会造成长时间阻塞，线上环境不建议使用
* bgsave命令：Redis进程执行fork操作创建子进程，RDB持久化过程由子进程负责，完成后自动结束。阻塞只发生在fork阶段，一般时间较短。

#### 自动触发

会在以下4种情况下自动触发

- redis.conf中配置了 `save m n`，即在m秒内有n次修改时，自动触发bgsave生成rdb文件
- 主从复制时，从节点要从主节点进行全量复制时也会触发bgsave操作，生成当时的快照发送到从节点
- 执行debug reload命令重新加载redis时也会触发bgsave操作
- 默认情况下执行shutdown命令时，如果没有开启aof持久化，那么也会触发bgsave操作

### RDB理解

#### fork子进程后，如果在进行持久化的过程中，数据发生了变化，变化的数据该如何进行处理？

RDB的核心思路是copy-on-write，即利用Linux的fork机制。具体来说，使用fork得到子进程后，此时尽管子进程和父进程的虚拟地址空间不同，但是子进程复制了父进程的页表，即二者其实在使用相同的物理内存页。操作系统会对页加上read only标签，此时子进程读取父进程的页，并不会有任何问题，但如果父进程对某个数据进行修改，此时会触发中断，将原有的页（父进程修改之前的页）复制一份，交给子进程，这样就保证了子进程的数据不会受父进程的影响，父进程也可以继续修改自己的数据，父子读写进程分离。

这样做的原因是为了避免很多不必要的内存复制。回到Redis的RDB机制中，通过采用copy-on-write机制，我们能够保证redis在执行bgsave命令后，所持久化的内容就是执行bgsave命令执行时的快照，而且不影响主进程读写数据。

所以说在bgsave过程中，主进程所修改的数据并不会被持久化，bgsave仅仅保存的当时的内存快照。

如果正在执行bgsave的过程中，出现了系统崩溃，会有两个影响：

* 主进程在这个过程中修改的数据丢失
* 在执行快照期间，redis服务器会先将rdb备份写入到临时文件中，当这次快照保存结束后，才会进行覆盖原有的，这样在系统崩溃时，未完成的rdb备份文件不会被写入磁盘，系统恢复后，rdb文件保存的仍然是最后一次成功执行save or bgsave命令所保存的数据。

所以极端情况下，如果在bgsave过程中，出现了大量读写，此时redis所占用的内存可能是原本的两倍。

#### RDB越频繁越好吗？

看起来似乎是这样，我们越频繁，在系统出现问题时受到的影响越小，但是频繁的全量快照会有以下开销：

- 一方面，频繁将全量数据写入磁盘会给磁盘带来很大压力，多个快照竞争有限的磁盘带宽，前一个快照还没有结束，下一个又开始。
- 一方面，bgsave本身是fork创建的，虽然会阻塞主线程的时间不久，但是如果主线程内存越大，阻塞的时间越久，频繁出现fork，就会频繁阻塞主线程。

### RDB优缺点

#### 优点

- RDB文件是某个时间节点的快照，默认使用LZF算法进行压缩，压缩后的文件体积远远小于内存大小，适用于备份、全量复制等场景；
- Redis加载RDB文件恢复数据要远远快于AOF方式；

#### 缺点

- RDB方式实时性不够，无法做到秒级的持久化；
- 每次调用bgsave都需要fork子进程，fork子进程属于重量级操作，频繁执行成本较高；
- RDB文件是二进制的，没有可读性，AOF文件在了解其结构的情况下可以手动修改或者补全；
- 版本兼容RDB文件问题

针对RDB不适合实时持久化的问题，Redis提供了AOF持久化方式来解决

## AOF持久化

> Redis是“写后”日志，Redis先执行命令，把数据写入内存，然后才记录日志。日志里记录的是Redis收到的每一条命令，这些命令是以文本形式保存。PS: 大多数的数据库采用的是写前日志（WAL），例如MySQL，通过写前日志和两阶段提交，实现数据和逻辑的一致性。

AOF日志采用的写后日志，即先写内存，后写日志。

### 为什么采用写后日志

Redis要求高性能，采用写日志好处：

- 避免额外的检查开销：Redis在向AOF里面记录日志的时候，并不会先去对这些命令进行语法检查。
- 不会阻塞当前的写操作

### AOF实现

AOF日志记录Redis的每一个写命令，步骤分为：命令追加（append）、文件写入（write）和文件同步（sync）

- **命令追加** 当AOF持久化功能打开了，服务器在执行完一个写命令之后，会以协议格式将被执行的写命令追加早服务器的aof_buf缓冲区。

- **文件写入和同步** 关于何时将aof_buf缓冲区的内容写入到aof文件中。

  - 这里redis提供了三种写回策略（类似MySQL的redo log 和 binlog的回写策略）
  - Always。同步写回，每次写命令执行完，立马同步地将日志写回到磁盘中
  - Everysec，每秒写回，每一个写命令执行结束后，只是先把日志写到aof文件的内存缓冲区，每隔1s将缓冲区中的内容写入到磁盘中
  - No。由操作系统控制写回：每一个写命令执行完，只是先把日志写道aof文件的内存缓冲区，由操作系统决定何时将缓冲区内容写回到磁盘。

  > [!NOTE]
  >
  > 注意这里所说的缓冲区和磁盘分别对应着，操作系统的内核的page cache，磁盘即对应着真正的磁盘，**这里的缓冲并非是redis的缓冲**

### AOF重写机制

> [!IMPORTANT]
>
> 由于AOF会记录每一个写命令到AOF文件中，随着时间越来越长，AOF文件会变得越来越大。如果不加以控制，会对Redis服务器，甚至对操作系统造成影响，而且AOF文件越大，数据的恢复也越慢，**为此，redis提供了AOF文件重写机制**

Redis通过创建一个新的AOF文件来替换现有的AOF文件，新旧两个AOF文件保存的数据相同，但是新AOF文件没有了冗余的命令。

#### AOF重写会阻塞？

AOF重写过程是由后台进程bgrewriteaof来完成的。主线程fork出后台的bgrewriteaof子进程，fork会把主线程的内存拷贝一份给bgrewriteaof子进程，这里面就包含了数据库的最新数据。然后，bgrewriteaof子进程就可以在不影响主线程的情况下，逐一把拷贝的数据写成操作，记入重写日志。

fork进程过程中是会阻塞主线程。

#### AOF日志何时重写？

有两个配置项控制AOF重写的触发：

`auto-aofrewrite-min-size`：表示允许AOF重写时文件的最小大小，默认为64MB

`auto-aof-rewrite-percentage`: 这个值的计算方式是：当前aof文件大小和上一次重写后aof文件大小的差值，再除以上一次重写后aof文件大小。也就是当前aof文件比上一次重写后aof文件的增量大小，和上一次重写后aof文件大小的比值。

#### 重写日志时，有新数据的写入操作？

AOF重写实现机制和RDB一致，都是fork主进程，获取全部的键值内容，然后写入到文件中，这样一个逻辑。

在aof重写日志文件时，fork后，子进程和父进程共享同样的物理空间页面，父进程在重写日志过程中如果有写入操作，此时会进行两个操作：

- 将执行后的写命令追加到aof的缓冲区
- 将执行后的写命令追加到aof的重写缓冲区

当子进程完成aof重写工作后，会通知主进程。主进程收到后，会将aof重写缓冲区的所有内容全部追加到新的aof文件中，使得新旧两个aof文件锁保存的数据库状态一致。新的aof文件进行改名为，覆盖现有的aof文件。

### RDB和AOF混合模式

> Redis 4.0 中提出了一个混合使用AOF日志和内存快照的方法。简单来说，内存快照以一定的频率执行，在两次快照之间，使用AOF日志记录这期间的所有命令操作

这样一来快照不用很频繁的执行，避免了fork对主线程的影响。而且AOF日志也只记录两次快照间的操作，也就是说AOF不需要记录所有操作，因此，就不会出现AOF文件过大的情况。

混合模式工作在**AOF日志重写过程**。

在开启了混合持久化时，在AOF重写日志时， `fork`出来的重写子进程会先将与主线程共享的内存数据以RDB方式写入到AOF文件，然后主线程处理的操作命令会被记录在重写缓冲区中，重写缓冲区的增量命令会以AOF方式写入到AOF文件中，写入完成后通知主进程将新的含有RDB格式和AOF文件替换旧的AOF文件。

这样的好处在于，重启 Redis 加载数据的时候，由于前半部分是 RDB 内容，这样**加载的时候速度会很快**。

加载完 RDB 的内容后，才会加载后半部分的 AOF 内容，这里的内容是 Redis 后台子进程重写 AOF 期间，主线程处理的操作命令，可以使得**数据更少的丢失**。

### 数据恢复

在redis启动时，会判断是否开了aof，如果开了aof，那么就会优先加载aof文件

如果aof文件不存在，那么redis就会去加载rdb文件，如果rdb也不存在，那么redis就直接启动。

为什么先加载aof？因为aof所保存的数据最为完整。



