#!/bin/bash

\cp /dnspro/name.conf.acl /etc/named.conf
named-checkconf && echo "named-checkconf ok"
service named restart
