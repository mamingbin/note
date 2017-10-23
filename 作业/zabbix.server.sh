#!/bin/bash
timedatectl set-timezone Asia/Shanghai ; ntpdate -u 172.25.254.254 ;  setenforce 0

#在压缩包所在位置执行脚本
tar xf zabbix-3.2.7.tar.gz -C /usr/local/src/
yum install gcc gcc-c++ mariadb-devel libxml2-devel net-snmp-devel libcurl-devel -y

cd /usr/local/src/zabbix-3.2.7/
./configure --prefix=/usr/local/zabbix --enable-server --with-mysql --with-net-snmp --with-libcurl --with-libxml2 --enable-agent --enable-ipv6
make && make install

cat >/usr/local/zabbix/etc/zabbix_server.conf<<EOT
LogFile=/tmp/zabbix_server.log
DBHost=172.25.1.13
DBName=zabbix
DBUser=zabbix
DBPassword=uplooking
Timeout=4
LogSlowQueries=3000
EOT

#拷贝数据给数据库服务器
# scp -r /usr/local/src/zabbix-3.2.7/database/mysql/* $ip:/root/
