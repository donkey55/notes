# Java内存模型

> Java 内存模型（Java Memory Model），简称 **JMM**。Java 内存模型的目标是为了解决由可见性和有序性导致的并发安全问题。Java 内存模型通过 **屏蔽各种硬件和操作系统的内存访问差异，以实现让 Java 程序在各种平台下都能达到一致的内存访问效果**。

JMM 的主要目标是 **定义程序中各个变量的访问规则，即在虚拟机中将变量存储到内存和从内存中取出变量这样的底层细节**。

此处的变量（Variables）与 Java 编程中所说的变量有所区别，它包括了实例字段、静态字段和构成数值对象的元素，但不包括局部变量与方法参数，因为后者是线程私有的，不会被共享，自然就不会存在竞争问题。

JMM 规定了**所有的变量都存储在主内存（Main Memory）中**。

每条线程还有自己的工作内存（Working Memory），**工作内存中保留了该线程使用到的变量的主内存的副本**。工作内存是 JMM 的一个抽象概念，并不真实存在，它涵盖了缓存，写缓冲区，寄存器以及其他的硬件和编译器优化。

线程对变量的操作都必须在工作内存中进行，而不能直接读写主内存中的变量。线程间变量值的传递都需要通过主内存来完成。

> 说明：
>
> 这里说的主内存、工作内存与 Java 内存区域中的堆、栈、方法区等不是同一个层次的内存划分。

### 内存间交互

JMM 定义了 8 个操作来完成主内存和工作内存之间的交互操作。JVM 实现时必须保证下面介绍的每种操作都是 **原子的**

也即下面的八个内存交互指令。

- `lock` (锁定) - 作用于**主内存**的变量，它把一个变量标识为一条线程独占的状态。
- `unlock` (解锁) - 作用于**主内存**的变量，它把一个处于锁定状态的变量释放出来，释放后的变量才可以被其他线程锁定。
- `read` (读取) - 作用于**主内存**的变量，它把一个变量的值从主内存**传输**到线程的工作内存中，以便随后的 `load` 动作使用。
- `write` (写入) - 作用于**主内存**的变量，它把 store 操作从工作内存中得到的变量的值放入主内存的变量中。
- `load` (载入) - 作用于**工作内存**的变量，它把 read 操作从主内存中得到的变量值放入工作内存的变量副本中。
- `use` (使用) - 作用于**工作内存**的变量，它把工作内存中一个变量的值传递给执行引擎，每当虚拟机遇到一个需要使用到变量的值得字节码指令时就会执行这个操作。
- `assign` (赋值) - 作用于**工作内存**的变量，它把一个从执行引擎接收到的值赋给工作内存的变量，每当虚拟机遇到一个给变量赋值的字节码指令时执行这个操作。
- `store` (存储) - 作用于**工作内存**的变量，它把工作内存中一个变量的值传送到主内存中，以便随后 `write` 操作使用。

在这里对应到了在Java并发中[volatile](./Java并发.md#volatile)，这个也就可以解释为什么volatile关键字的为什么可以保证可见性。在读取时，会总是直接去主内存中读取数据，然后copy到工作内存中，而非读取工作内存中的值。在写入时，首先写入到工作内存中，然后会瞬间被刷新到主存中

### Happens-before原则

**Happens-Before** 是指 **前面一个操作的结果对后续操作是可见的**，并不是理解意义上的先发生。

原则比较多，这里描述几个

- **volatile 变量规则** - 对一个 `volatile` 变量的写操作先行发生于后面对这个变量的读操作。
- **线程启动规则** - `Thread` 对象的 `start()` 方法先行发生于此线程的每个一个动作。
- **锁定规则** - 一个 `unLock` 操作先行发生于后面对同一个锁的 `lock` 操作。
- 如果操作 A 先行发生于 操作 B，而操作 B 又 先行发生于 操作 C，则可以得出操作 A 先行发生于 操作 C

### final量的规则

我们知道，final 成员变量必须在声明的时候初始化或者在构造器中初始化，否则就会报编译错误。 final 关键字的可见性是指：被 final 修饰的字段在声明时或者构造器中，一旦初始化完成，那么在其他线程无须同步就能正确看见 final 字段的值。这是因为一旦初始化完成，final 变量的值立刻回写到主内存

### ForkJoinPool

**太复杂了！！！**

***Todo***

