## Useful 命令

### acme证书申请

```bash
# acme申请证书
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

