# Java IO

## IO类分类

### 传输方式上：

字节流和字符流

#### 字节流

输入流和输出流

InputStream   OutputStream

#### 字符流

Reader

Writer

### 数据操作上

数据操作上可以分为以下几类：

- 文件
  - FileInputStream
  - FileOutputStream
  - FileReader
  - FileWriter
- 数组
  - ByteArrayInputStream
  - ByteArrayOutputStream
  - CharArrayReader
  - CharArrayWriter
- 管道
  - PipedInputStream
  - PipedOutputStream
  - PipedReader
  - PipedWriter
- 基本数据类型
  - DataInputStream
  - DataOutputStream
- 缓冲操作
  - BufferedInputStream
  - BufferedOutputStream
  - BufferedReader
  - BufferWriter
- 打印
  - PrintStream
  - PrintWriter
- 对象序列化和反序列化
  - ObjectInputStream
  - ObjectOutputStream
- 转换
  - InputStreamReader
  - OutputStreamWriter

## 装饰器模式

装饰器模式是指装饰者和其他组件都继承了组件，具体组件的方法实现不需要依赖于其他对象，装饰者组合了一个组件，这样它可以装饰其他装饰者或者具体的组件。

即装饰者继承于我们的基础组件类，然后有一些具体组件继承于装饰者类。这些继承自装饰者的具体组件相当于对原有的组件进行一个扩展。他们既会拥有被装饰者的功能，又会对被装饰者的功能进行一个增强。

Java IO的装饰器模式主要体现：

如 `FilterInputStream`的子类 `BufferedInputStream` ,如果我们想要一个InputStream想要拥有buffer功能，只需要在创建BufferedInputStream时传入需要增加的InputStream即可

```Java
FileInputStream fileInputStream = new FileINputStream(filepath);
BufferedInputStream bufferedStream = new BufferedInputStream(fileInputStream);
```

## BIO

### 几个重要概念

`阻塞IO` 和 `非阻塞IO`

这两个概念时`程序级别`的。主要描述的是程序请求操作系统后，如果IO资源没有准备好，那么程序该如何处理的问题。

`同步IO`和`非同步IO`

这两个概念是操作系统级别的。主要描述的是操作系统在收到程序请求IO后，如果IO资源没有准备好，该如何如何响应程序的问题。**同步IO是用户程序不获取，那么就不会通知应用程序**，异步IO是内核处理完成后，**通过事件的方式告知应用程序**

> 注意：下面会介绍几种IO：
>
> - **同步IO**
>
>   - **阻塞IO（BIO）**
>
>   - **非阻塞IO** (**NIO**)
>
>   - **I/O多路复用** (也是一种NIO)
>
> - **异步IO**
>
> NIO包括了两种方式：一种为普通的非阻塞IO和IO多路复用
>
> 这里二者最大的区别是：非阻塞IO传统的理解为，我们会不断的轮询当前是否有已经就绪的事件，有的话我便进行处理。**这里的非阻塞只线程没有因为没有数据就停止运行，而是cpu在运行着，只是在不停的轮询**。
>
> 对于这种特点其实非阻塞IO和IO多路复用都有这个特点，二者不同的是，非阻塞IO的传统实现是：一个主线程负责了网络IO的连接建立、读和写，数据的处理交由给业务线程处理的方式，而IO多路复用这里，主线程只负责接收连接，对连接的读写由读写线程（线程池）完成，对数据的处理交付给业务线程（线程池）完成。这样就实现了一个IO多路复用。



传统的BIO的通信方式大部分为阻塞模式：

- 客户端向服务器端发送请求后，客户端会一致等待，直到服务器端返回结果
- 服务器端同样的，当在处理某个客户端A发来的请求时，另一个客户端B发来的请求会等待，直到服务器端的这个处理线程完成上一个处理。

### 多线程——伪异步方式

- 服务器端收到客户端X的请求后，（读取到所有请求数据后）将这个请求送入一个独立线程进行处理，然后主线程继续接受客户端Y的请求。
- 客户端一侧，也可以使用一个子线程和服务器端进行通信。这样客户端主线程的其他工作就不受影响了，当服务器端有响应信息的时候再由这个子线程通过 监听模式/观察模式(等其他设计模式)通知主线程。

## NIO

I/O与NIO最重要的区别是数据打包和传输的方式，I/O以流的方式处理数据，而NIO以块的方式处理数据。

面向流的IO一次处理一个字节数据：一个输入流产生一个字节数据，一个输出流消费一个字节数据。

面向块的IO一次处理一个数据块，按块处理数据比按流处理数据要快的多。但是面向块的IO缺少一些面向流的IO所具有的优雅性和简单性。

I/O 包和 NIO 已经很好地集成了，java.io.* 已经以 NIO 为基础重新实现了，所以现在它可以利用 NIO 的一些特性。

### 通道与缓冲区

#### 通道

通道channel是对原IO包中的流的模拟，可以通过它读取和写入数据。

通道和流的不同之处在于，流只能在一个方向上移动，而通道是双向的，可以用于读、写或者同时用于读写。

通道包括以下类型：

- FileChannel
- DatagramChannel：通过UDP读写网络中数据
- SocketChannel：通过TCP读写网络中数据
- ServerSocketChannel：可以监听新进来的TCP连接，对每一个新进来的连接都会创建一个SocketChannel

#### 缓冲区

发送给一个通道的所有数据都必须首先放到缓冲区中，同样地，从通道中读取的任何数据都要先读到缓冲区中。也就是说，不会直接对通道进行读写数据，而是要先经过缓冲区。

缓冲区包括以下类型:

- ByteBuffer
- CharBuffer
- ShortBuffer
- IntBuffer
- LongBuffer
- FloatBuffer
- DoubleBuffer

#### 选择器

NIO 实现了 IO 多路复用中的 Reactor 模型，一个线程 Thread 使用一个选择器 Selector 通过轮询的方式去监听多个通道 Channel 上的事件，从而让一个线程就可以处理多个事件。

应该注意的是，只有套接字 Channel 才能配置为非阻塞，而 FileChannel 不能，为 FileChannel 配置非阻塞也没有意义。

使用方式

1. 创建选择器

   ```java
   Selector selector = Selector.open();
   ```

2. 将通道注册到选择器上

   ```java
   ServerSocketChannel ssChannel = ServerSocketChannel.open();
   ssChannel.configureBlocking(false);
   ssChannel.register(selector, SelectionKey.OP_ACCEPT);
   ```

   其中通道必须配置为非阻塞模式，否则使用选择器便没有任何意义，因为如果通道在某个事件上被阻塞，那么服务器就不用响应其他事件，必须等待这个事件处理完毕才能区处理其他事件。

   在注册的时候，还要指定注册的具体事件：

   - SelectionKey.OP_CONNECT
   - SelectionKey.OP_ACCEPT
   - SelectionKey.OP_READ
   - SelectionKey.OP_WRITE

3. 监听事件

   ```java
   int num = selector.select();
   ```

4. 获取到达的事件

   ```java
   Set<SelectionKey> keys = selector.selectedKeys();
   Iterator<SelectionKey> keyIterator = keys.iterator();
   while (keyIterator.hasNext()) {
       SelectionKey key = keyIterator.next();
       if (key.isAcceptable()) {
           // ...
       } else if (key.isReadable()) {
           // ...
       }
       keyIterator.remove();
   }
   ```

5. 事件循环

   一次select调用不能处理完所有的事件，并且服务器端有可能需要一直监听事件，所以需要放到死循环里面。

   ```java
   while (true) {
       int num = selector.select();
       Set<SelectionKey> keys = selector.selectedKeys();
       Iterator<SelectionKey> keyIterator = keys.iterator();
       while (keyIterator.hasNext()) {
           SelectionKey key = keyIterator.next();
           if (key.isAcceptable()) {
               // ...
           } else if (key.isReadable()) {
               // ...
           }
           keyIterator.remove();
       }
   }
   ```

   

## Reactor模型和Proactor模型

### Reactor模型

![image-20240326013526474](https://lsp-1259035619.cos.ap-beijing.myqcloud.com/typora/image-20240326013526474.png)

从图中可以看出，在Reactor模型中，主要有四个角色：客户端连接，Reactor，Acceptor和Handler。这里Acceptor会不断地接收客户端的连接，然后将接收到的连接交由Reactor进行分发，最后有具体的Handler进行处理。改进后的Reactor模型相对于传统的IO模型主要有如下优点：

- 从模型上来讲，如果仅仅还是只使用一个线程池来处理客户端连接的网络读写，以及业务计算，那么Reactor模型与传统IO模型在效率上并没有什么提升。但是Reactor模型是以事件进行驱动的，其能够将接收客户端连接，+ 网络读和网络写，以及业务计算进行拆分，从而极大的提升处理效率；
- Reactor模型是异步非阻塞模型，工作线程在没有网络事件时可以处理其他的任务，而不用像传统IO那样必须阻塞等待。

### 业务处理和IO分离

上面的模型中，网络读写和业务操作都在同一个线程中，下面是一种采用线程池的方式处理业务操作的模型，如下:

![image-20240326013918331](https://lsp-1259035619.cos.ap-beijing.myqcloud.com/typora/image-20240326013918331.png)

上述模型具有以上特点：

- 一个线程进行客户端连接的接收以及网络读写事件的处理
- 在接收到客户端连接之后，将该连接交由线程池进行数据的编解码以及业务计算。

### 并发读写

网络读写在高并发情况下会称为系统的一个瓶颈，因而针对此缺点，设计了如下模型，使用线程池进行网络读写，而仅仅使用一个线程专门接收客户端连接

![image-20240326015714733](https://lsp-1259035619.cos.ap-beijing.myqcloud.com/typora/image-20240326015714733.png)

上面的mainReactor用来处理连接，acceptor将连接给subReactor进行网络端的读写，这里采用的线程池来进行读写。对于业务操作也用一个线程池来进行。

## 重要概念理解

### channel

通道，被建立的一个应用程序和操作系统交互事件，传递内容的渠道，一个通道有一个专属的文件描述符。既然是和操作系统进行内容的传递，那么说明应用程序可以通过通道读取数据，也可以通过通道向操作系统写数据。

![image-20240326135745345](https://lsp-1259035619.cos.ap-beijing.myqcloud.com/typora/image-20240326135745345.png)

只有继承了`SelectableChannel`类的子类才能够被`Selector`注册。

- ServerSocketChannel: 应用服务器程序的监听通道。只有通过这个通道，应用程序才能向操作系统注册支持多路复用IO的端口监听。同时它支持UDP协议和TCP协议
- SocketChannel：TCP Socket 套接字的监听通道，一个Socket套接字对应了一个客户端IP：端口 到 服务器IP：端口的通信连接
- DatagramChannel：UDP数据报文的监听通道

### buffer

数据缓存区：在Java NIO框架中，为了保证每个通道的数据读写速度Java NIO框架为每一种需要支持数据读写的通道集成了Buffer的支持

在下文JAVA NIO框架的代码实例中，我们将进行Buffer缓存区操作的演示

### Selector

翻译为选择器，但根据功能可以称之为 轮询代理器，事件订阅器，channel容器管理机

事件订阅和Channel管理

应用程序将向Selector对象注册需要它关注的Channel，以及具体的某一个Channel对哪些IO事件感兴趣。

> 在上面的ServerSocketChannel调用register方法，传入了我们的selector对象，其实内部是在调用selector的register将此channel注册到selector中，并将其注册的`SelectionKey`返回给channel，同时selector内部也会维持一个数组来保持着目前在这个selector所注册的channel对应的`SelectionKey`，接下来在调用selector.select()方法时，它会一直阻塞直到有至少一个事件到达，然通过selector.selectedKeys()会让我们得到已经到达的事件。

拥有seletor之后，应用进程不再需要阻塞or非阻塞的模式直接询问操作系统"是否有事件发生"，而是由selector待其进行询问
