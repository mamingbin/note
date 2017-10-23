#!/bin/bsh

setenforce 0
iptables -F

#安装lanmp
yum -y install httpd php php-mysql mariadb-server mariadb
yum localinstall cacti-0.8.8b-7.el7.noarch.rpm php-snmp-5.4.16-23.el7_0.3.x86_64.rpm

#配置mysql数据库
service mariadb start
mysqladmin -u root password "uplooking"
mysql -uroot -puplooking < grant.sql
mysql -ucactidb -p123456 cacti < /usr/share/doc/cacti-0.8.8b/cacti.sql 
\cp db.php /etc/cacti/db.php
\cp cacti.conf /etc/httpd/conf.d/cacti.conf

#配置php时区
timedatectl set-timezone Asia/Shanghai
sed -i 's/Europe\/Riga/Asia\/Shanghai/' /etc/php.ini
#变更任务计划
cat >/etc/cron.d/cacti<<EOT
*/5 * * * *     cacti   /usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1
EOT

service httpd restart
service snmpd start
netstat -anpl |grep :161

#配置cacti监控本地
\cp snmpd.conf /etc/snmp/snmpd.conf
service snmpd restart
