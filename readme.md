### 下载 openresty

```shell
wget https://github.com/openresty/openresty/releases/download/v1.25.3.1/openresty-1.25.3.1.tar.gz
wget https://luarocks.org/releases/luarocks-3.11.1.tar.gz
```

### 安装 lua5.1

```shell
sudo apt install lua5.1
```

#### 安装 luarocks(暂未解决下载源的问题)

```shell
./configure \
  --with-lua=$HOME/workspace/openresty-lab/target/luajit \
  --with-lua-include=$HOME/workspace/openresty-lab/target/luajit/include/luajit-2.1 \
  --prefix=$HOME/workspace/openresty-lab/luarocks
make
make install
```

#### luarocks 添加依赖

```shell
# 暂时不用，使用git submodule代替
luarocks install luaunit
```

### 解压编译安装

### 配置 tcp 代理

### 编写双向流量记录文件测试程序.lua

### OPM 安装依赖

```shell
opm get thibaultcha/lua-resty-jit-uuid
```
