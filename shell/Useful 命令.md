# Useful 命令

## Linux

### acme证书申请

```bash
# acme申请证书， 默认使用的是80端口进行验证，需要保证80端口不被nginx等进程所占用
acme.sh --issue -d ${domain} --standalone -k ec-256 --server letsencrypt
# acme安装证书
# domain即为域名
# /xx/xx/domain.crt 为安装后证书所在文件路径，路径和证书名均可自定义，
# .key同上
acme.sh --installcert -d ${domain} --fullchainpath /xx/xx/${domain}.crt --keypath /xx/xx/${domain}.key --ecc >/dev/null
```

### 查看端口

```bash
# 输出当前占用80端口的进程
lsof -i:80
netstat -tunlp | grep 80
```

`lsof`:

* lsof -i:8080：查看8080端口占用
* lsof abc.txt：显示开启文件abc.txt的进程
* lsof -c abc：显示abc进程现在打开的文件
* lsof -c -p 1234：列出进程号为1234的进程所打开的文件
* lsof -g gid：显示归属gid的进程情况
* lsof +d /usr/local/：显示目录下被进程开启的文件
* lsof +D /usr/local/：同上，但是会搜索目录下的目录，时间较长
* lsof -d 4：显示使用fd为4的进程
* lsof -i -U：显示所有打开的端口和UNIX domain文件


`netstat` ：

* -t 仅显示tcp相关选项
* -u 仅显示udp相关选项
* -n 拒绝显示别名，能显示数字的全部转化为数字
* -l 仅列出在Listen的服务状态
* -p 显示简历相关链接的程序名

### 添加用户

```bash
# 添加用户
useradd lsp # 不方便，还需要手动添加密码

adduser lsp # 会要求输入一定的信息包括密码，并会指定shell和bash，用起来非常舒服，建议这个

# 添加sudo权限

usermod -G sudo lsp

# 切换用户
su -l lsp
su lsp
# 可以切换为全新环境
su - lsp
```



### 取消sudo的输入密码限制

```
visudo

lsp ALL=(ALL) NOPASSWD: ALL
```

### docker run halo
```bash
 docker run -it -d --name halo -p 8090:8090 -v ~/.halo:/root/.halo --restart=always halohub/halo:1.5.4

```



### 脚本1

```bash
wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh

```
### 脚本2

```bash
bash <(curl -s -L https://git.io/v2ray.sh)
```

### 流媒体解锁

```bash
bash <(curl -L -s check.unlock.media)
```

### 三网回程测试

```shell
curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
```

### speedtest测速

```bash
curl -fsSL git.io/speedtest-cli.sh | sudo bash

speedtest
```

### airUniver

```bash
wget https://raw.githubusercontent.com/crossfw/Air-Universe-install/master/AirU.sh && bash AirU.sh
```

### Tuic

```shell
wget https://raw.githubusercontent.com/koopkl/auto-tuic/main/auto-tuic.sh && bash auto-tuic.sh
```



### warp

```bash
bash <(curl -fsSL git.io/warp.sh) d

# 这个可能更好用
wget -N https://raw.githubusercontent.com/fscarmen/warp/main/warp-go.sh && bash warp-go.sh
# v6小鸡，选2，似乎选6会有问题

```

### ssh-copy-id

windows

```bash
type ~/.ssh/id_rsa.pub | ssh username@ipaddress "cat >> .ssh/authorized_keys" 
```

linux

```bash
ssh-copy-id -i root@yourip
```


## 环境

### Pip配置镜像与代理

单次配置代理

```
pip install package --proxy=127.0.0.1:7890
```

在C:\User\用户目录下，新建pip文件夹，然后在该文件夹下新建`pip.ini`文件。填写如下内容：

```ini
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
proxy     = http://127.0.0.1:7890
[install]
trusted-host=pypi.tuna.tsinghua.edu.cn
```

如果是虚拟环境下，可以进行在`你的虚拟环境文件夹/pip.ini`中填入上面内容。

如果是linux系统，则应该为`pip.conf`

### npm配置镜像与代理

#### 命令配置

查看当前npm的配置

```shell
npm config list
```

配置镜像源（这里是淘宝镜像源）

```shell
npm config set registry https://registry.npm.taobao.org/
```

配置代理

7890对应端口

```shell
npm config set proxy http://127.0.0.1:7890
```

清除配置

```shell
npm config delete proxy
```

#### 配置文件配置

linux npm全局配置文件一般在一般存储在`~/.npmrc`

windows的全局配置文件一般存储在`C:\User\username\.npmrc`

配置内容如下示例：

```shell
registry=https://registry.npm.taobao.org/
proxy=http://127.0.0.1:7890
```



### ssh密钥生成

```shell
ssh-keygen -t rsa
```

### git

有些时候gitignore不生效，主要原因是gitignore只能够忽略尚未track的文件，对于已经track的文件不太行，这里可以采用以下办法进行处理

```shell
#首先删除本地缓存
git rm -r --cached .
# 重新加入文件
git add .
git commit -m "更新gitigonre"
```

