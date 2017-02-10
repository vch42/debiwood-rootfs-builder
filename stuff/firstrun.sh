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
	tar zxf openssh-7.1p1.tar.gz
	cd openssh-7.1p1
	cat ../openssh-7_1_P1-hpn-14.9.diff | patch -p1
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

#install samba4
if [ -d /root/samba4 ]; then
	#do the happy dance and puke. rinse and repeat.
fi


#clean rc.local
sed -ie "/firstrun.sh/d" /etc/rc.local

#reboot
shutdown -r now