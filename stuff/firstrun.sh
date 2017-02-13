#!/bin/bash
#firstrun.sh

echo timer  > /sys/class/leds/nsa320:red:copy/trigger
echo default-on  > /sys/class/leds/nsa320:green:copy/trigger

rm -f /etc/ssh/ssh_host*
ssh-keygen -Aq

systemctl stop ssh.service

ntpdate europe.pool.ntp.org
apt-get -qq update
update-command-not-found &> /dev/null

#install hpnssh
if [ -d /root/hpnssh ]; then
	cd /root/hpnssh
	tar zxf openssh-7.2p2.tar.gz
	cd openssh-7.2p2
	cat ../openssh-7_2_P2-hpn-14.10.diff | patch -p1
	./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-engine --with-pam
	make
	\cp /lib/systemd/system/ssh.service ../ssh.service
	apt-get remove -y openssh-server openssh-client openssh-sftp-server ssh
	
	make host-key && make install
	
	cp ../ssh.service /lib/systemd/system/
	
	systemctl unmask ssh.service
	systemctl enable ssh.service
	systemctl start ssh.service
	systemctl status ssh.service
	systemctl stop ssh.service
fi

#generate 1024MB swap file and add it to fstab
dd if=/dev/zero of=/swapfile bs=1024k count=1k
chown root:root /swapfile
chmod 0600 /swapfile
mkswap /swapfile
cat <<EOT >> /etc/fstab
/swapfile   none   swap   sw   0   0

EOT
swapon /swapfile


#install samba4 from source
#if [ -d /root/samba4 ]; then
#	#do the happy dance and puke. rinse and repeat.
#fi

#apt-get install -y samba

#clean rc.local
sed -ie "/firstrun.sh/d" /etc/rc.local

#reboot
shutdown -r now