# Nginx

## Nginx基础配置

### worker_process

>  nginx对应的进程，一般和物理CPU核对应，可以写`auto`

### events

#### worker_connections

>  一个worker可以创建多少个连接

### http

#### include

> 可以引入别的配置文件，后面跟配置文件路径

### sendfile 

> sendfile		on;
>
> 零拷贝

### server

#### listen

> 监听端口

#### server_name

> 域名或主机名

**匹配规则**

* 完整匹配

  * `server_name example1.com example2.com`

    可以匹配example1和example2

* 通配符

  * 正则匹配

## 反向代理

### 概念

用户->nginx服务器->应用服务器

用户无法直接访问应用服务器，流量都通过nginx服务器进行转发，nginx服务器此时即为代理服务器

正向代理的作用是**客户主动代理**

反向代理是**服务器端主动代理**

所以代理服务器又可以称为网关，也可以称为中转（自己搭代理是同一个道理）

nginx这种单向称为**隧道式**

**lvs**的**DR模型**，请求经过代理服务器转发到应用服务器后，但应用服务器的返回不会再经过代理服务器

### 负载均衡

多个功能服务器组成集群，将请求均匀到集群的服务器中。

负载均衡有不同的算法

### 实现

location下，`root`和`proxy_pass`二选一

基本proxy_pass 使用

```nginx
server {
    listen 80;
    server_name localhost;
    location / {
        proxy_pass http://baidu.com;
    }
}
```

> `proxy_pass` 不支持https转发

简单的负载均衡如下

#### 轮询算法

```nginx
upstream httpds {
    server baidu.com;
    server qq.com;
}
server {
    listen 80;
    server_name localhost;
    location / {
        proxy_pass http://httpds;
    }
}
```

#### 带权重算法

即按照比例进行分配（也是轮询）

```nginx
upstream httpds {
    server baidu.com weight=8;
    server qq.com weight=2;
}
server {
    listen 80;
    server_name localhost;
    location / {
        proxy_pass http://httpds;
    }
}
```

可以使用down来让服务器下线,backup用来备份

```nginx
upstream httpds {
    server baidu.com weight=8 down;
    server qq.com weight=2;
    server weixin.com weight=2 backup;
}
```

当qq.com无法用的时候，会转发到weixin.com

> down, weight不常用

## nginx 动静分离

动态请求和静态资源分离，将静态资源放在nginx中直接访问

也即之前开发时前端页面全部放到nginx服务器上

本质进行路径（location）转发，将访问静态资源（css,js,html）的路径全部放到nginx路径下

可以使用正则进行location路径进行匹配

## Nginx URLRewrite

```nginx
location / {
    rewrite ^/2.html$  /index.jsp?pageNum=2  break;
    proxy_pass http://baidu.com;
}
```

```bash
rewrite <regex>   <replacement>   [flag];

flag:
last # 本条规则匹配完成后，继续向下匹配新的location URI规则
break # 本条规则匹配完成即终止，不再匹配后面的任何规则
redirect # 返回302临时重定向，浏览器地址会显示跳转后的URL地址
permanent # 返回301永久重定向，浏览器地址栏会显示跳转后的URL地址
```

## nginx防盗链

只允许图片在自己站点被看到，不允许其他站点引用。

使用浏览器二次请求资源自动添加referer属性来让限制图片的外部引用。 

```nginx
location / {
	valid_referers [none] lsp.lsp123,top;
    if ($invalid_referer) {
        return 403;
    }
}
# 添加none后，请求若没有refer时可以直接访问
 
```



