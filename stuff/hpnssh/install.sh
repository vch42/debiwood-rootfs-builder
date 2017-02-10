#!/bin/bash
apt-get update && apt-get upgrade -y && apt-get autoremove -y
apt-get install -y build-essential linux-headers-$(uname -r) zlibc zlib1g zlib1g-dev libssl-dev libpam0g libpam0g-dev wget curl
sleep 5
tar zxvf openssh-7.1p1.tar.gz
cd openssh-7.1p1
sleep 5
cat ../openssh-7_1_P1-hpn-14.9.diff | patch -p1
sleep 5
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-engine --with-pam
sleep 5
make
sleep 5

systemctl stop ssh
killall -9 sshd

cp /lib/systemd/system/ssh.service ../ssh.service
cat ../ssh.service
sleep 10
apt-get remove -y openssh-server openssh-client openssh-sftp-server ssh
sleep 5

make host-key && make install

cp ../ssh.service /lib/systemd/system/

systemctl unmask ssh.service
systemctl enable ssh.service
systemctl start ssh.service
systemctl status ssh.service
sleep 5
