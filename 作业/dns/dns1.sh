#!/bin/bash

setenforce 0
iptables -F

yum -y install bind &>dull && echo "bind is already installed"

\cp /dnspro/named.conf /etc/named.conf
\cp /dnspro/abc.com.* /var/named/
chgrp named abc.com.*
named-checkconf && echo "name-checkconf ok"
named-checkzone  abc.com /var/named/abc.com.dx.zone && echo "named-checkzone dx ok"
named-checkzone  abc.com /var/named/abc.com.wt.zone && echo "named-checkzone wt ok"
named-checkzone  abc.com /var/named/abc.com.other.zone && echo named-checkzone other ok""

service named restart
#chkconfig named on
