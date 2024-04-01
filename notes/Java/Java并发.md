# Java并发

> Java 线程的实现是通过映射到系统的轻量级线程上，轻量级线程有对应系统的内核线程，内核线程的调度由系统调度器来调度的，所以 Java 的线程调度方式取决于系统内核调度器，只不过刚好目前主流操作系统的线程实现都是抢占式的。

Java并发围绕着三个特性入手来保证线程安全：**原子性、可见性和有序性。**

保证线程安全最常见的做法是利用锁机制，来对共享数据做互斥同步。保证在同一个时刻只有一个线程执行某个方法或者代码块。互斥同步最主要的问题是线程的阻塞和唤醒而带来的性能开销。

volatile是轻量级锁，性能自然比普通的锁性能更好。它保证了共享变量在多线程中的可见性、有序性。但是它只能在一些特定的场景下使用。因为无法保证原子性

为了兼顾原子性以及锁带来的性能问题，Java引入了CAS机制，来实现非阻塞同步（乐观锁），并基于CAS，提供了一套原子工具类。

### synchronized

`synchronized`修饰方法时，锁住的是this对象，如果其中有同类的其他实力对象并不能被锁住，此时可以考虑使用类锁，即`synchronized(Xxx.class)`的方式来锁住此类。

`synchronized`的锁升级：

* 无锁
* 偏向锁
* 轻量级锁
* 重量级锁

### Lock和Condition

`synchronized`缺点：无法通过破坏不可抢占条件来避免死锁。synchronized在申请资源时，如果申请不到，线程会直接进入到阻塞状态，那么线程便无法释放线程已经占有的资源

Lock是一个Java接口，允许类在能够自定义锁行为，来实现一些synchronized所无法实现的功能，来适应一些较为复杂的并发环境。

Lock是用来解决互斥问题

Condition用来解决同步问题

Condition也是一个接口，他为Lock提供了一组同步的方法，比如await(),signal()等方法，对应于synchronized关键字所需要的wait，notify等方法。

### ReentrantLock

其实就是一个实现了Lock接口，并支持可重入的锁。

在构造方法中可选是否为公平锁，默认为非公平锁

### ReentrantReadWriteLock

实现了ReadWriteLock，即他是一个可重入的读写锁。

维护了一对读写锁，将读写锁分开，有利于提高并发效率。

所有的读写锁都遵守以下三条基本原则：

- 允许多个线程同时读共享变量；
- 只允许一个线程写共享变量；
- 如果一个写线程正在执行写操作，此时禁止读线程读共享变量。

ReentrantReadWriteLock 虽然遵循着允许多个读操作进行，但只允许一个写操作，但是在读写操作的优先级上有着多种不同的实现方式：

* 写锁释放，但是有写锁和读锁都在等待，应该谁先获得
* 有线程持有读锁，但是此时有写线程在等待，此时如果有新来的读线程，是否允许插队
* 读写锁的升降级：正在持有写锁，是否可以降级到读锁。正在持有读锁，是否能够升级到写锁。

### StampedLock 

支持三种锁方式：**写锁，悲观读锁和乐观读**

> 注意这里，用的是“乐观读”这个词，而不是“乐观读锁”，是要提醒你，**乐观读这个操作是无锁的**，所以相比较 ReadWriteLock 的读锁，乐观读的性能更好一些。

**StampedLock支持多个线程申请乐观读的同时，还允许一个线程申请写锁。**

但是不支持重入

***Todo***

有点难，这个有点太复杂了

### AQS

AbstractQueuedSynchronizer,简称队列同步器，它是并发锁和很多同步工具类的实现基石。

### 偏向锁

偏向锁的思想是偏向于**第一个获取锁对象的线程，这个线程在之后获取该锁就不再需要进行同步操作，甚至连 CAS 操作也不再需要**。

### 轻量级锁

**轻量级锁**是相对于传统的重量级锁而言，它 **使用 CAS 操作来避免重量级锁使用互斥量的开销**。对于绝大部分的锁，在整个同步周期内都是不存在竞争的，因此也就不需要都使用互斥量进行同步，可以先采用 CAS 操作进行同步，如果 CAS 失败了再改用互斥量进行同步。

### 重量级锁

采用互斥变量的方式实现

### 可重入锁

**可重入锁，顾名思义，指的是线程可以重复获取同一把锁**。**即同一个线程在外层方法获取了锁，在进入内层方法会自动获取锁。**

`synchronized`是典型的可重入锁，比如：

```java
synchronized void setA() throws Exception{
    Thread.sleep(1000);
    setB();
}

synchronized void setB() throws Exception{
    setA();
    Thread.sleep(1000);
}
```

还有`ReentrantLock`，`ReentrantReadWriteLock`

### 公平锁和非公平锁

* 公平锁。多线程你找申请锁的顺序来获取锁。
* 非公平锁。多线程不按照申请锁的顺序来获取锁。

`synchronized` 只支持非公平锁。

`ReentrantLock` 、`ReentrantReadWriteLock`，默认是非公平锁，但支持公平锁

### 独享锁与共享锁

独享锁与共享锁是一种广义上的说法，从实际用途上来看，也常被称为互斥锁与读写锁。

- **独享锁** - 独享锁是指 **锁一次只能被一个线程所持有**。
- **共享锁** - 共享锁是指 **锁可被多个线程所持有**。

独享锁与共享锁在 Java 中的典型实现：

- **`synchronized` 、`ReentrantLock` 只支持独享锁**。
- **`ReentrantReadWriteLock` 其写锁是独享锁，其读锁是共享锁**。读锁是共享锁使得并发读是非常高效的，读写，写读 ，写写的过程是互斥的

### 乐观锁和悲观锁

乐观锁与悲观锁不是指具体的什么类型的锁，而是**处理并发同步的策略**。

- **悲观锁** - 悲观锁对于并发采取悲观的态度，认为：**不加锁的并发操作一定会出问题**。**悲观锁适合写操作频繁的场景**。
- **乐观锁** - 乐观锁对于并发采取乐观的态度，认为：**不加锁的并发操作也没什么问题。对于同一个数据的并发操作，是不会发生修改的**。在更新数据的时候，会采用不断尝试更新的方式更新数据。**乐观锁适合读多写少的场景**。

乐观锁：先进行操作，如果没有其他线程争用共享数据，那么操作便成功了，如果有其他线程争用共享数据，那么就采取弥补措施，如不断的重试，直到成功为止。此时并不会阻塞线程，这种策略也叫非阻塞同步。典型的 `自旋锁`，CAS机制

悲观锁：悲观锁总是认为，只要不去做正确的同步措施，那么肯定会出现问题。无论共享数据是否真的会出现竞争，它都要进行加锁。典型的`synchronized`

### 显示锁和内置锁

内置锁：锁的申请和释放都是由JVM所控制。`synchronized`，`volatile`

显示锁：锁的申请和释放都可以由程序所控制。`ReentrantLock`，`ReentrantReadWriteLock`

区别：

- 主动获取锁和释放锁
  - `synchronized` 不能主动获取锁和释放锁。获取锁和释放锁都是 JVM 控制的。
  - `ReentrantLock` 可以主动获取锁和释放锁。（如果忘记释放锁，就可能产生死锁）。
- 响应中断
  - `synchronized` 不能响应中断。
  - `ReentrantLock` 可以响应中断。
- 超时机制
  - `synchronized` 没有超时机制。
  - `ReentrantLock` 有超时机制。`ReentrantLock` 可以设置超时时间，超时后自动释放锁，避免一直等待。
- 支持公平锁
  - `synchronized` 只支持非公平锁。
  - `ReentrantLock` 支持非公平锁和公平锁。
- 是否支持共享
  - 被 `synchronized` 修饰的方法或代码块，只能被一个线程访问（独享）。如果这个线程被阻塞，其他线程也只能等待
  - `ReentrantLock` 可以基于 `Condition` 灵活的控制同步条件。
- 是否支持读写分离
  - `synchronized` 不支持读写锁分离；
  - `ReentrantReadWriteLock` 支持读写锁，从而使阻塞读写的操作分开，有效提高并发性

### 锁消除和锁粗化

#### 锁消除

JIT编译器在动态编译同步代码块时，借助了一种被称为逃逸分析的技术，来判断同步块使用的锁对象是否只能够被一个线程访问，而没有发布到其他线程。

#### 锁粗化

JIT编译器动态编译时，如果发现几个相邻的同步块使用的是同一个锁实例，那么JIT编译器会把这几个同步块合并为一个大的同步块，从而避免一个线程反复申请、释放同一个锁带来的性能消耗。

### 自旋锁

互斥同步进入阻塞状态的开销比较大，应该尽量避免。而在很多情况下共享数据被上锁的时间往往只会持续很短的一段时间。自旋锁的思想是让一个线程在请求不到一个共享数据的锁时，执行忙循环（自旋）一段时间，如果这段时间内可以获取锁，那么就可以避免进入阻塞状态。

自旋锁和互斥锁最大的区别是：在一个线程得不到自旋锁时，线程并不会被阻塞，但是互斥锁会进入等待。

相同点时：在任意时刻，两个锁都最多只有一个保持者

### 锁优化

尽可能的缩小加锁的范围，用来提高并发吞吐

区分读写场景以及资源的访问冲突，考虑使用乐观锁or悲观锁

### volatile

`volatile`是轻量级的 `synchronized`,它再多处理器开发中保证了共享变量的可见性

被`volatile`修饰的变量，具备以下特点：

* 线程可见性。一个线程修改了某个共享变量，另外一个线程能够读到这个修改的值
  * 这里可以理解为，多线程环境一个，一个对象的在多个线程中使用，一个线程改变的值可能在其自己的线程缓存中，而没有真正写入到主存中，从而导致其他的线程看不到其修改的值，而`volatile`可以保证这种情况不会发生。
  * 具体原理为:针对写操作，他会强制将对缓存的修改立即写入到内存中，而且会导致其他cpu（其他线程）中对应的缓存无效
* 禁止指令重排序。（happen-before语义）
  * 即在指令重排序时，不会把其前面的指令放到后面，也不会把后面的指令放到前面。
* 不保证原子性。

`volatile`可见性和`happen-before`语义的实现在底层依赖于*内存屏障*来完成

**内存屏障**是一组处理器指令，用于实现对内存操作的顺序限制。（感觉类似于流水线中的指令冲突）

这里需要使用的是`LoadLoad` `LoadStore` `StoreLoad` `StoreStore`

volatile使用场景：

* 对变量的写操作不依赖当前值
* 该变量没有包含在具有其他变量的不变式当中。

为保证原子性的话可以考虑使用原子类。

#### volatile 的使用场景

在不符合以下两点的场景中，仍然要通过加锁来保证原子性：

- 运算结果并不依赖变量的当前值，或者能够确保只有单一的线程修改变量的值。
- 变量不需要与其他状态变量共同参与不变约束。

最常用的场景为：一次写入，到处读取

最经典的应用：

```java
class Singleton {
    private volatile static Singleton instance = null;

    private Singleton() {}

    public static Singleton getInstance() {
        if(instance==null) {
            synchronized (Singleton.class) {
                if(instance==null)
                    instance = new Singleton();
            }
        }
        return instance;
    }
}
```

### CAS

`CAS`全称为`Compare And Swap`，比较并交换。CAS有三个操作数：内存值M，期望值E和更新值U，当且仅当内存值和期望值相同时，将M改为U，否则什么都不做

CAS适用于线程冲突较少的情况。典型的场景时：

* 原子类
* 自旋锁

原子类的底层采用`Unsafe`类提供的CAS操作来实现。`Unsafe` 的 CAS 依赖的是 JVM 针对不同的操作系统实现的硬件指令 `Atomic::cmpxchg`。`Atomic::cmpxchg` 的实现使用了汇编的 CAS 操作，并使用 CPU 提供的 `lock` 信号保证其原子性

#### CAS存在的问题

* ABA问题
  * **如果一个变量初次读取的时候是 A 值，它的值被改成了 B，后来又被改回为 A，那 CAS 操作就会误认为它从来没有被改变过**。
  * J.U.C 包提供了一个带有标记的**原子引用类 `AtomicStampedReference` 来解决这个问题**，它可以通过控制变量值的版本来保证 CAS 的正确性。大部分情况下 ABA 问题不会影响程序并发的正确性，如果需要解决 ABA 问题，改用**传统的互斥同步可能会比原子类更高效**
* 只能保证一个共享变量的原子性
  * 当对一个共享变量执行操作时，我们可以使用循环 CAS 的方式来保证原子操作，但是对多个共享变量操作时，循环 CAS 就无法保证操作的原子性，这个时候就可以用锁。
  * 从 Java 1.5 开始 JDK 提供了 `AtomicReference` 类来保证引用对象之间的原子性，你可以把多个变量放在一个对象里来进行 CAS 操作

### ThreadLocal 

`ThreadLocal` 是一个存储线程本地副本的工具类。**为共享变量在每个线程中都创建了一个本地副本**，这个副本只能被当前线程访问，其他线程无法访问，那么自然是线程安全的。

下面是一个例子，

```Java
public class ThreadLocalDemo {

    private static ThreadLocal<Integer> threadLocal = new ThreadLocal<Integer>() {
        @Override
        protected Integer initialValue() {
            return 0;
        }
    };

    public static void main(String[] args) {
        ExecutorService executorService = Executors.newFixedThreadPool(10);
        for (int i = 0; i < 10; i++) {
            executorService.execute(new MyThread());
        }
        executorService.shutdown();
    }

    static class MyThread implements Runnable {

        @Override
        public void run() {
            int count = threadLocal.get();
            for (int i = 0; i < 10; i++) {
                try {
                    count++;
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            threadLocal.set(count);
            threadLocal.remove();
            System.out.println(Thread.currentThread().getName() + " : " + count);
        }

    }
}
```



这里用`ThreadLocal`对象来包装一个整型共享变量。这里线程池中的线程都会访问`threadLocal`对象，并从中获取其值，因为并没有加锁，考虑到不同线程的执行先后问题，最终结果可能不会全都为10，但是由于`ThreadLocal`的包装，过早执行完的线程在将值存储到`threadLocal`对象中时，并不会对其他线程从`threadLocal`中get时的结果。所以此代码最终结果输出全为10。

原理为：每一个`Thread`中都会有一个`ThreadLocalMap`的对象，这是一个`ThreadLocal`类的内部类，在执行`threadLocal`的`set`函数时，会将此`ThreadLocal`对象作为`key`，被`set`的值作为`value`存入到本线程的`ThreadLocalMap`对象中。从而在每一个`Thread`中使用`ThreadLocal`的`get`方法时只会从本`Thread`中的`ThreadLocalMap`中`get`，而不会和其他线程竞争。

值得注意的是，上面的代码初始化的时候使用了 **匿名内部类的方式重写了ThreadLocal中的`initialValue`**方法，这个方法会在当前`Thread`的`ThreadLocalMap`对象中找不到和此`ThreadLocal`相等的`key`时被调用，其返回值作为`get`的返回值，并向`ThreadLocalMap`中插入此`key`和`value`

### Java原子类

原子变量类 **比锁的粒度更细，更轻量级**，并且对于在多处理器系统上实现高性能的并发代码来说是非常关键的。原子变量将发生竞争的范围缩小到单个变量上。

可以分为四类

## Java线程池

### Executor框架

> Executor 框架是一个根据一组执行策略调用，调度，执行和控制的异步任务的框架，目的是提供一种将”任务提交”与”任务如何运行”分离开来的机制。

Executor 框架核心 API 如下：

- `Executor` - 运行任务的简单接口。

- `ExecutorService` 扩展了Executor接口。扩展能力：
  - 支持有返回值的线程；
  - 支持管理线程的生命周期。
  
- `ScheduledExecutorService` - 扩展了 `ExecutorService` 接口。扩展能力：支持定期执行任务。

- `AbstractExecutorService` - `ExecutorService` 接口的默认实现。

- `ThreadPoolExecutor` - Executor 框架最核心的类，它继承了 `AbstractExecutorService` 类。

- `ScheduledThreadPoolExecutor` - `ScheduledExecutorService` 接口的实现，一个可定时调度任务的线程池。

- `Executors` - 可以通过调用 `Executors` 的静态工厂方法来创建线程池并返回一个 `ExecutorService` 对象。

Executors其中包含很多方法来创建各种线程池和对象

最核心的类为`ThreadPoolExecutors` 

线程池有五个状态：

* RUNNING。接收新任务，也可以处理阻塞队列中的任务
* SHUTDOWN。不接受新任务，但是可以处理阻塞队列中的任务。RUNNING状态调用shutdown方法会进入此状态。finalize方法在执行过程中也会调用shutdown方法进入到此状态
* STOP。停止状态，不接受新任务，也不会处理队列中的任务，在状态1or状态2调用stop方法时，会中断正在处理任务的线程，并进入到此状态
* TIDYING。整理状态。所有任务都已经终止，且workcount为0。进入此状态后，会调用terminated方法进入到TERMINATED状态
* TERMINATED。已经终止状态。进入 `TERMINATED` 的条件如下：
  - 线程池不是 `RUNNING` 状态；
  - 线程池状态不是 `TIDYING` 状态或 `TERMINATED` 状态；
  - 如果线程池状态是 `SHUTDOWN` 并且 `workerQueue` 为空；
  - `workerCount` 为 0；
  - 设置 `TIDYING` 状态成功。
  - 

![线程池状态转换图](https://raw.githubusercontent.com/dunwu/images/master/cs/java/javacore/concurrent/java-thread-pool_2.png)

尽量不要使用无界限任务队列，在高负载情况下容易出现爆内存，`Executors`中很多方法都默认采用无界任务队列。

尽量不要使用Executors自带的方法创建线程池：

- CachedThreadPool，最大线程数是无界的
- FixedThreadPool，阻塞队列是无界的
- SingleThreadPool，阻塞队列是无界的
- ScheduledThreadPool，最大线程数是无界的

### `ThreadPoolExecutors` 解析

#### 核心参数

