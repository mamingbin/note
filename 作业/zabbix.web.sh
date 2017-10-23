#!/bin/bash

setenforce 0
iptables -F

timedatectl set-timezone Asia/Shanghai ; ntpdate -u 172.25.254.254 ;  setenforce 0 
yum -y install httpd php php-mysql
yum -y localinstall php-mbstring-5.4.16-23.el7_0.3.x86_64.rpm php-bcmath-5.4.16-23.el7_0.3.x86_64.rpm
yum localinstall zabbix-web-3.2.7-1.el7.noarch.rpm zabbix-web-mysql-3.2.7-1.el7.noarch.rpm

sed -i 's/Europe\/Riga/Asia\/Shanghai/' /etc/httpd/conf.d/zabbix.conf

cd /usr/local/zabbix/sbin/
./zabbix_server 
netstat -tnlp |grep zabbix

systemctl restart httpd
netstat -tnpl |grep :80 && echo "httpd start successful"
