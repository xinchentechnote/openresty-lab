cd openresty-1.25.3.1
./configure --prefix=$HOME/workspace/openresty-lab/target \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-pcre-jit \
    --with-debug \
    --with-no-pool-patch \
    --with-luajit-xcflags="-g" \
    --with-cc-opt="-O0 -g" \
    --with-ld-opt="-g"
make
sudo make install
cd -