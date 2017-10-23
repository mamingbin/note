#!/bin/bash

\cp /dnspro/name.conf.kuozhan /etc/named.conf
named-checkconf && echo "named-checkconf ok"
service named restart
