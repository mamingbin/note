#!/bin/bash

setenforce 0
iptables -F

tar xf jdk-7u15-linux-x64.tar.gz -C /opt/
mv /opt/jdk1.7.0_15/ /opt/java

#安装tomcat
mkdir /usr/local/tomcat # 创建tomcat的程序文件存放位置
tar -xf apache-tomcat-8.0.24.tar.gz  -C /usr/local/tomcat 
export JAVA_HOME=/opt/java/ # 启动之前必须通过JAVA_HOME变量告知jdk所在路径

#用jsvs的方式启动服务
groupadd -g 888 tomcat
useradd -g 888 -u 888 tomcat -s /sbin/nologin
tar xf /usr/local/tomcat/apache-tomcat-8.0.24/bin/commons-daemon-native.tar.gz -C /usr/local/tomcat/apache-tomcat-8.0.24/bin/
cd /usr/local/tomcat/apache-tomcat-8.0.24/bin/commons-daemon-1.0.15-native-src/unix
#显示当前所在路径
pwd
yum -y install gcc >/dev/null && echo "gcc install successful"
./configure --with-java=/opt/java >/dev/null
if [ echo $? -eq 0 ]
then
	echo "configure successful"
else
	echo "configure failed"
fi
make
cp jsvc /usr/local/tomcat/apache-tomcat-8.0.24/bin/

#优化tomcat命令
cd -
\cp tomcat /etc/init.d/tomcat  # 将修改后的jsvc启动脚本复制到/etc/init.d目录下
chkconfig --add tomcat
chkconfig tomcat on
#启动tomcat
chown tomcat. -R /usr/local/tomcat/apache-tomcat-8.0.24/
service tomcat start
netstat -tnpl |grep :80
#实际网站代码必须放在ROOT目录下面
mkdir /usr/local/tomcat/apache-tomcat-8.0.24/jsp.com/ROOT
echo hello >/usr/local/tomcat/apache-tomcat-8.0.24/jsp.com/ROOT/index.jsp
