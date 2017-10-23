#!/bin/bash

setenforce 0
iptables -F

yum -y install rsync > /dev/null
yum -y install sersync > /dev/null

tar xf sersync2.5_32bit_binary_stable_final.tar.gz -C /opt/
mv /opt/GNU-Linux-x86/ sersync
mkdir /webser
\cp /sersync/confxml.xml.backup /opt/sersync/confxml.xml

echo "123" > /root/passwd.txt
chmod 600 /root/passwd.txt

/opt/sersync/sersync2 -d -r -o /opt/sersync/confxml.xml

