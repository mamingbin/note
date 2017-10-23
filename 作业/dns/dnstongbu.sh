#!/bin/bash

\cp /dnspro/named.conf.tongbu /etc/named.conf
named-checkconf && echo "named-checkconf ok"
service named restart
netstat -anpl |grep named

