#!/bin/bash

setenforce 0
iptables -F

rpm -ivh zabbix-agent-3.2.7-1.el7.x86_64.rpm
yum -y install net-snmp net-snmp-utils

cat >/etc/zabbix/zabbix_agentd.conf<<EOT
Server=172.25.1.11
ServerActive=172.25.1.11
Hostname=servera.pod13.example.com
UnsafeUserParameters=1
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOT

systemctl start zabbix-agent
systemctl enable zabbix-agent
