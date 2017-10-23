#!/bin/bash

timedatectl set-timezone Asia/Shanghai ; ntpdate -u 172.25.254.254 ;  setenforce 0
yum -y install mariadb-server mariadb
systemctl start mariadb
netstat -tnpl |grep :3306 && echo "mysql start successful"
systemctl enable mariadb

mysql < zabbix.sql
mysql zabbix < /root/schema.sql 
mysql zabbix < /root/images.sql
mysql zabbix < /root/data.sql 
