#!/bin/bash

#安装软件
setenforce 0
iptables -F
rpm -ivh nginx-1.8.1-1.el7.ngx.x86_64.rpm
rpm -ivh spawn-fcgi-1.6.3-5.el7.x86_64.rpm

yum install php php-mysql mariadb-server -y > /dev/null && echo "all install have done"

#配置虚拟主机
\cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/www.bbs.com.conf
cat >/etc/nginx/conf.d/www.bbs.com.conf<<EOT
server {
       listen 80;
       server_name www.bbs.com;
       root /usr/share/nginx/bbs.com;
       index index.php index.html index.htm;
    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;   
 	    fastcgi_index index.php;
	    fastcgi_param SCRIPT_FILENAME /usr/share/nginx/bbs.com$fastcgi_script_name;
	    include fastcgi_params;
     }
}
EOT

mkdir /usr/share/nginx/bbs.com
systemctl restart nginx.service
netstat -tnpl |grep :80 && echo "nginx up successful"

#配置spawn-fcgi
cat >/etc/sysconfig/spawn-fcgi<<EOT
OPTIONS="-u nginx -g nginx -p 9000 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"
EOT

systemctl start spawn-fcgi
netstat -tnpl |grep :9000  &&  echo "spawn-fcgi up successful"
systemctl enable spawn-fcgi

#编写测试文件
cat >/usr/share/nginx/bbs.com/test.php<<EOT
<?php
  phpinfo();
?>
EOT

systemctl enable mariadb.service
systemctl start mariadb.service
netstat tnpl |grep :3306 && echo "mariadb up successful"

#安装论坛
unzip Discuz_X3.2_SC_UTF8.zip
\cp -r upload/* /usr/share/nginx/bbs.com/
chown nginx. /usr/share/nginx/bbs.com/ -R

#数据库授权
service mariadb start
mysqladmin -u root password "uplooking"
mysql -uroot -puplooking < update.sql

