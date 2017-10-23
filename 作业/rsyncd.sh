#!/bin/bash

mkdir /web
chown nobody.nobody /web

cat >/etc/rsyncd.conf<<END
uid=nobody
gip=nobody
use chroot=yes
address=0.0.0.0
port 873
log file=/var/log/rsyncd.log
pid file=/var/run/rsyncd.pid
lock file=/var/run/rsyncd.lock
hosts allow=*
[web]
        path=/web
        comment= web share with rsync
        read only=no
        auth users=user01 user02
        secrets file=/etc/rsyncd_user.db
END

cat >/etc/rsyncd_user.db<<END
user01:123
user02:456
END

chmod 600 /etc/rsyncd_user.db
service rsyncd start
chkconfig rsync on

