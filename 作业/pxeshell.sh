#!/bin/bash
#以下操作都在serverg上部署
#关闭防火墙
setenforce 0
iptables -F

#配置网络
i#sed -i 's/ONBOOT=/ONBOOT=no/' /etc/sysconfig/network-scripts/ifcfg-eth0
#systemctl restart network
#rm -fr /etc/sysconfig/network-scripts/ifcfg-eth1 
#cat >/etc/sysconfig/network-scripts/ifcfg-eth1 <<end
#DEVICE=eth1
#BOOTPROTO=static
#ONBOOT=yes
#TYPE=Ethernet
#USERCTL=yes
#IPV6INIT=no
#IPADDR=192.168.0.10
#NETMASK=255.255.255.0
#GATEWAY=192.168.0.10
#end
echo "配置网络完成"

#下载iso ，发布iso，配置yum源
mount -t nfs 172.25.254.250:/content /mnt/
flag=`echo $?`
echo $flag
if [ $flag -ne 0 ] && echo "挂载失败，退出" && exit
mkdir /yum
mount -o loop /mnt/rhel7.1/x86_64/isos/rhel-server-7.1-x86_64-dvd.iso  /yum/
cd /etc/yum.repos.d/
find . -regex '.*\.repo$' -exec mv {} {}.back \;
cat > /etc/yum.repos.d/base.repo <<end
[base]
baseurl=file:///yum
gpgcheck=0
end
yum clean all
yum makecache
echo "配置yum源完成"

#搭建DHCP
yum -y install dhcp
\cp /usr/share/doc/dhcp-4.2.5/dhcpd.conf.example  /etc/dhcp/dhcpd.conf
rm -fr /etc/dhcp/dhcpd.conf
cat > /etc/dhcp/dhcpd.conf <<end
allow booting;
allow bootp;

option domain-name "pod12.example.com";
option domain-name-servers 172.25.254.254;
default-lease-time 600;
max-lease-time 7200;

log-facility local7;

subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.100 192.168.0.150;
  option domain-name-servers 172.25.254.254;
  option domain-name "pod12.example.com";
  option routers 192.168.0.10;
  option broadcast-address 192.168.0.255;
  default-lease-time 600;
  max-lease-time 7200;
  next-server 192.168.0.16;
  filename "pxelinux.0";
}
end
systemctl start dhcpd
echo "搭建DHCP完成"


#安装配置TFTP
yum -y install tftp-server
yum -y install syslinux
cp /usr/share/syslinux/pxelinux.0  /var/lib/tftpboot/
mkdir /var/lib/tftpboot/pxelinux.cfg
cd /var/lib/tftpboot/pxelinux.cfg
touch default
cat > default <<end
default vesamenu.c3
timeout 60
display boot.msg
menu background splash.jpg
menu title Welcome to Global Learning Services Setup!

label local
        menu label Boot from ^local drive
        menu default
        localhost 0xffff

label install
        menu label Install rhel7
        kernel vmlinuz
        append initrd=initrd.img ks=http://192.168.0.16/myks.cfg
end
echo "安装配置TFTP完成"

#生成引导相关文件
cd /mnt/rhel7.1/x86_64/dvd/isolinux
cp splash.png vesamenu.c32 vmlinuz initrd.img /var/lib/tftpboot/
sed -i 's/.*disable.*/disable=no/' /etc/xinetd.d/tftp
systemctl start xinetd

echo "生成引导相关文件成功"

#安装httpd服务，发布ks与iso镜像

yum -y install httpd

#生成ks文件
cat > /var/www/html/rhel7u1ks.cfg <<EOF
#version=RHEL7
# System authorization information
auth --enableshadow --passalgo=sha512
# Reboot after installation 
reboot
# Use network installation
url --url="http://192.168.0.16/rhel7u1/"
# Use graphical install
#graphical 
text
# Firewall configuration
firewall --enabled --service=ssh
firstboot --disable 
ignoredisk --only-use=vda
# Keyboard layouts
# old format: keyboard us
# new format:
keyboard --vckeymap=us --xlayouts='us'
# System language 
lang en_US.UTF-8
# Network information
network  --bootproto=dhcp
network  --hostname=localhost.localdomain
#repo --name="Server-ResilientStorage" --baseurl=http://download.eng.bos.redhat.com/rel-eng/latest-RHEL-7/compose/Server/x86_64/os//addons/ResilientStorage
# Root password
rootpw --iscrypted nope 
# SELinux configuration
selinux --disabled
# System services
services --disabled="kdump,rhsmcertd" --enabled="network,sshd,rsyslog,ovirt-guest-agent,chronyd"
# System timezone
timezone Asia/Shanghai --isUtc
# System bootloader configuration
bootloader --append="console=tty0 crashkernel=auto" --location=mbr --timeout=1 --boot-drive=vda 

# Clear the Master Boot Record
zerombr # 清空MBR
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part / --fstype="xfs" --ondisk=vda --size=6144
%post
echo "redhat" | passwd --stdin root
useradd carol
echo "redhat" | passwd --stdin carol
# workaround anaconda requirements
%end

%packages
@core
%end
EOF
echo "生成ks文件成功"

ln -s /yum/ /var/www/html/rhel7u1

ervice httpd start
systemctl enable xinetd
systemctl enable httpd
systemctl enable dhcpd

echo "安装成功"
