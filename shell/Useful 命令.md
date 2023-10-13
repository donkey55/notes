## Useful 命令

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
lsof | grep "80"
```

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
bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
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

