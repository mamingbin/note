#!/bin/bash
#格式化磁盘
dd if=/dev/zero of=/dev/sda bs=500 count=1

fdisk
n
p
+4G
a
1
w

partx -a /dev/sda
mkfs.ext4 /dev/sda1
mkdir /mnt/usb
mount /dev/sda1 /mnt/usb

#安装系统文件
rm -rf /etc/yum.repo.d/*
cat > /etc/yum.repo.d/redhat.repo<<EOT
[redhat]
baseurl=http://172.25.254.254/content/rhel6u5/dvd
gpgcheck=0
EOT

yum -y install filesystem --installroot=/mnt/usb/

#安装应用程序与bash shell
yum -y install bash coreutils findutils grep vim-enhanced rpm yum passwd net-tools util-linux lvm2 openssh-clients bind-utils --installroot=/mnt/usb/

#安装内核
cp -a /boot/vmlinuz-2.6.32-431.el6.x86_64 /mnt/usb/boot/
cp -a /boot/initramfs-2.6.32-431.el6.x86_64.img /mnt/usb/boot/
cp -arv /lib/modules/2.6.32-431.el6.x86_64/ /mnt/usb/lib/modules/

#安装grub软件
rpm -ivh http://172.25.254.254/content/rhel6.5/x86_64/dvd/Packages/grub-0.97-83.el6.x86_64.rpm --root=/mnt/usb/ --nodeps --force 

grub-install  --root-directory=/mnt/usb/ /dev/sda --recheck

#配置grub.conf
cp /boot/grub/grub.conf  /mnt/usb/boot/grub/

cat > /mnt/usb/boot/grub/grub.conf<<EOT
default=0
timeout=5
splashimage=/boot/grub/splash.xpm.gz
hiddenmenu
title My usb system from hugo
        root (hd0,0)
        kernel /boot/vmlinuz-2.6.32-431.el6.x86_64 ro root=UUID=b9159dca-252a-4919-bee1-5743d2d1bbd7 selinux=0 
        initrd /boot/initramfs-2.6.32-431.el6.x86_64.img
EOT

cp /boot/grub/splash.xpm.gz /mnt/usb/boot/grub/

#完善配置文件
cp /etc/skel/.bash* /mnt/usb/root/

cat > /mnt/usb/etc/sysconfig/network<<EOT
NETWORKING=yes
HOSTNAME=myusb.hugo.org
EOT

cp /etc/sysconfig/network-scripts/ifcfg-eth0 /mnt/usb/etc/sysconfig/network-scripts/

cat > /mnt/usb/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOT
DEVICE="eth0"
BOOTPROTO="static"
ONBOOT="yes"
IPADDR=192.168.0.8
NETMASK=255.255.255.0
GATEWAY=192.168.0.10
EOT

cat > /mnt/usb/etc/fstab <<EOT
UUID="b9159dca-252a-4919-bee1-5743d2d1bbd7" /  ext4 defaults 0 0
proc                    /proc                   proc    defaults        0 0
sysfs                   /sys                    sysfs   defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
EOT

#设置密码
grub-md5-crypt
redhat\n
redhat\n

sed -i 's/^root/root:$1$HORgV/$uu5Ipz.4aRdZKCszBDput0:15937:0:99999:7:::' /mnt/usb/etc/shadow

umount /mnt/usb

