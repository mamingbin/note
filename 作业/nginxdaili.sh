#!/bin/bash

#安装nginx
yum install pcre-devel -y
useradd -r -d /dev/null -s /bin/false nginx
tar xf nginx-1.8.0.tar.gz -C /usr/src/
cd /usr/src/nginx-1.8.0/
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_gzip_static_module  --with-http_stub_status_module 
make && make install

#使用前端nginx代理后面一台web
cat >usr/local/nginx/conf/nginx.conf<<EOT
user  nginx nginx;
worker_processes  4;
error_log  logs/error.log  info;
pid        logs/nginx.pid;

events {
    use epoll;
    worker_connections  65535;
}

http {
    server {
        listen       80;
        server_name  10.1.1.8;
	root /nginxroot/;

        location /web1/ {
		proxy_pass http://10.1.1.9:8000/;	
		}
	}
}
EOT

mkdir /nginxroot/
echo "nginx test page" > /nginxroot/index.html
chown nginx.nginx /nginxroot/ -R

#启动
ulimit -SHn 65535
/usr/local/nginx/sbin/nginx
