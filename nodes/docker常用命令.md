## docker常用命令

### 镜像相关

##### 列出所有镜像

```bash
docker image ls
```

##### 查看当前所有镜像占据的体积

```bash
docker system df
```

##### 列出虚悬镜像

```bash
docker image ls -f dangling=true
```

##### 删除全部的虚悬镜像

```bash
docker image prune
```

##### 列出name的镜像

```bash
docker image ls name
```

