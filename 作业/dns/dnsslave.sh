#!/bin/bash

setenforce 0
iptables -F

\cp /dnsproc/dx.cfg /etc/
\cp /dnsproc/wt.cfg /etc/
\cp /dnsproc/zhdx.cfg /etc/
\cp /dnsproc/zhlt.cfg /etc/
\cp /dnsproc/named.conf /etc/named.conf

named-checkconf && echo "named-checkconf ok"
service named restart
netstat -anpl|grep named
