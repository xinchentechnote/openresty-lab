#!/bin/bash
# openrestyctl

case "$1" in
    start)
        sudo $OPENRESTY_HOME/nginx/sbin/nginx
        ;;
    stop)
        sudo $OPENRESTY_HOME/nginx/sbin/nginx -s stop
        ;;
    reload)
        sudo $OPENRESTY_HOME/nginx/sbin/nginx -s reload
        ;;
    test)
        sudo $OPENRESTY_HOME/nginx/sbin/nginx -t
        ;;
    *)
        echo "Usage: $0 {start|stop|reload|test}"
        exit 1
        ;;
esac
