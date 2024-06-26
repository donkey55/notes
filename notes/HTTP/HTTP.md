# HTTP

## https

https相比http，为解决http的缺陷，https增加了ssl/tls，实现了以下三个机制：

- 信息加密，加密信息，不被窃听。
  - 使用混合加密的方式来保证
- 校验机制，保证通信内容的不被篡改
  - 使用摘要算法来保证通信内容不被篡改
- 身份证书，校验身份，防止被冒充
  - 服务器的公钥放到证书中，来防止被冒充

#### 混合加密

https采用对称加密和非对称加密的方式来建立通信和传输数据。

非对称加密是指，采用非对称加密来进行交换对称加密的密钥

对称加密是指在传输数据时，使用对称加密的密钥来进行对数据进行加密。

#### 摘要算法+签名

使用摘要算法（Hash算法）来对发送的数据计算一个指纹，然后将数据和指纹一起使用本地私钥加密后发送给对方

对方接收到后，使用公钥解密，得到数据和指纹，然后使用相同的摘要算法对数据进行计算得到指纹，如果和客户端的指纹相同，则表明数据是没有被篡改的。

#### 身份证书，数字证书

由于在上一步中，可能会出现公钥和私钥都被替换的风险，采用数字证书的方式，使用CA的公钥来对证书中的公钥进行校验，来保证这个公钥的正确性

### SSL/TLS

tls和ssl一般不区分具体的使用场景，二者的版本变化为下：

- ssl 1.0
- ssl 2.0
- ssl 3.0
- tls 1.0
- tls 1.1
- tls 1.2
- tls 1.3

tls 1.0 是在ssl的基础上进行了简单的改进

tls 1.1 进行了较大的改进，但目前已经被废弃

tls 1.2 目前的主流版本

由于一些兼容性问题，一些服务器还是会支持使用tls 1.1 or tls 1.0。

### tls 1.2握手过程

### tls 1.3握手过程

HTTP/2

## HTTP缓存

http的缓存技术分为两种：强制缓存和协商缓存

### 强制缓存

强制缓存指的是只要浏览器判断缓存没有过期，则直接使用浏览器的本地缓存，决定是否使用缓存的主动性在于浏览器这边

强制缓存利用**HTTP响应头部**（Response Header）字段实现的，它们都用来表示资源在客户端缓存的有效期：

- Cache-Control，是一个相对时间
- Expires，是一个绝对时间

如果HTTP的响应头部同时有Cache-Control和Expires字段的话，**Cache-Controle的优先级高于Expires**

Cache-control选项更多一些，设置的可以更加精细，推荐使用Cache-control，具体流程如下：

- 浏览器第一次访问服务器资源时，服务器会Response Header上加上Cache-Control字段，并设置过期时间大小
- 浏览器再次请求访问该资源时，会先通过请求资源的时间和Cache-Control中设置的过期时间大小，来计算出该资源是否过期，如果没有在使用，否则重新请求服务器
- 服务器再次收到请求后，会再次更新Response Header中的Cache-Control

### 协商缓存

协商缓存是指，客户端与服务端协商之后，通过协商结果来判断是否使用本地缓存。

协商缓存可以基于两种头部实现。

- `Request Header`中的 `If-Modified-Since`字段与中的 `Last-Modified`字段实现。

  - `Response Header`中的 `Last-Modified`：标示这个响应资源的最后修改时间；

  - `Request Header`中的 `If-Modified-Since`字段：当资源过期了，发现响应头中具有 Last-Modified 声明，则再次发起请求的时候带上 Last-Modified 的时间，服务器收到请求后发现有 If-Modified-Since 则与被请求资源的最后修改时间进行对比（Last-Modified），如果最后修改时间较新（大），说明资源又被改过，则返回最新资源，HTTP 200 OK；如果最后修改时间较旧（小），说明资源无新修改，响应 HTTP 304 走缓存。

- 请求头部中的 `If-None-Match` 字段与响应头部中的 `ETag` 字段，这两个字段的意思是：

  - 响应头部中 `Etag`：唯一标识响应资源；
  - 请求头部中的 `If-None-Match`：当资源过期时，浏览器发现响应头里有 Etag，则再次向服务器发起请求时，会将请求头 If-None-Match 值设置为 Etag 的值。服务器收到请求后进行比对，如果资源没有变化返回 304，如果资源变化了返回 200。

在请求头中，如果同时有`Etag`字段和`Last-Modified`字段，则会优先使用`Etag`字段

> 注意，**协商缓存这两个字段都需要配合强制缓存中 Cache-Control 字段来使用，只有在未能命中强制缓存的时候，才能发起带有协商缓存字段的请求**。

![image-20240330202234492](https://lsp-1259035619.cos.ap-beijing.myqcloud.com/typora/image-20240330202234492.png)

其中304的返回值是代表使用缓存。

## HTTP/1.1 HTTP/2 HTTP/3

### http1.1 

http1.1相比http1.0的改进为http1.1采用了长连接的方式。

基于长连接，http1.1实现了管道网络传输。即客户端可以在一个tcp连接中发送多个请求，无需等待上一次请求回来之后再发送请求。但是服务器必须按照接收请求的顺序对这些管道化请求的响应。

**所以http1.1管道解决了请求头的队头阻塞，但是没有解决响应的队头阻塞**

> 注：http1.1的管道并不是默认开启的，而且浏览器基本没有支持，这个功能是有，但没有被使用

缺点：

- http1.1并没有对头部进行压缩

- 请求只能客户端发送，服务端只能被动响应
- 没有请求的优先级控制

### http2

相比http1.1的改进：

- 头部压缩
- 二进制格式
- 并发传输
- 服务器主动推送资源

#### 头部压缩

HTTP/2 会**压缩头**（Header）如果你同时发出多个请求，他们的头是一样的或是相似的，那么，协议会帮你**消除重复的部分**。

这就是所谓的 `HPACK` 算法：在客户端和服务器同时维护一张头信息表，所有字段都会存入这个表，生成一个索引号，以后就不发送同样字段了，只发送索引号，这样就**提高速度**了。

#### 二进制格式

http/2不像http1.1里面的纯文本形式的报文，而是全面次啊用了二进制格式，头部信息和数据体都是二进制，并且统称为frame，分为头部帧和数据帧。

#### 并发传输

http/2引入了Stream的概念，多个Stream复用在一条TCP连接中。即一个tcp连接中包含多个stream，每一个stream包含一个或者多个Message，每一个Message里面包含多个frame，frame是http/2的最小单位，以二进制压缩格式存放http header和body。

**针对不同的 HTTP 请求用独一无二的 Stream ID 来区分，接收端可以通过 Stream ID 有序组装成 HTTP 消息，不同 Stream 的帧是可以乱序发送的，因此可以并发不同的 Stream ，也就是 HTTP/2 可以并行交错地发送请求和响应**。