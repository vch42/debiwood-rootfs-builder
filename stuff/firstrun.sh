#!/bin/bash
#firstrun.sh
exec 2> /var/log/firstrun.log  # send stderr to a log file
exec 1>&2                      # send stdout to the same log file
set -x                         # tell sh to display commands before execution

sleep 60;
echo timer  > /sys/class/leds/nsa320:red:copy/trigger
echo default-on  > /sys/class/leds/nsa320:green:copy/trigger
echo ide-disk1  > /sys/class/leds/nsa320:red:hdd1/trigger
echo ide-disk2  > /sys/class/leds/nsa320:red:hdd2/trigger
echo usb-host  > /sys/class/leds/nsa320:green:usb/trigger


#If move to raid array is requested, do it first, reboot from array and continue.
move_to_raid=false ; #flag
if $move_to_raid; then
    for n in {0..10} ; do
        mdadm --stop /dev/md$n
        mdadm --remove /dev/md$n
    done
    sleep 5;
    for n in {1..10} ; do
        mdadm --zero-superblock /dev/sda$n
    done
    sleep 5;
    for n in {1..10} ; do
		parted -s /dev/sda rm $n;
	done
	sleep 5;
    parted -s /dev/sda mklabel gpt && \
    parted -s /dev/sda mkpart primary 1 16500 && \
    sleep 5;
    mdadm --create /dev/md0 --run --force --metadata=0.90 --level=1 --raid-devices=2 missing /dev/sda1 && \
    mkfs.put_fs_here -L put_label_here /dev/md0 && \
    mdadm --detail --scan >> /etc/mdadm/mdadm.conf && \
    sleep 5;
    #echo 'mdadm mdadm/mail_to string root' | debconf-set-selections; sleep 5;
    #echo 'mdadm mdadm/initrdstart string all' | debconf-set-selections; sleep 5;
    #echo 'mdadm mdadm/autostart boolean true' | debconf-set-selections; sleep 5;
    #echo 'mdadm mdadm/autocheck boolean true' | debconf-set-selections; sleep 5;
    #echo 'mdadm mdadm/initrdstart_notinconf boolean true' | debconf-set-selections; sleep 5;
    #echo 'mdadm mdadm/start_daemon boolean true' | debconf-set-selections; sleep 5;
    #export DEBIAN_FRONTEND=noninteractive ; sleep 5;
    #dpkg-reconfigure mdadm ; sleep 15;
    debconf-set-selections <<< "mdadm mdadm/mail_to string root"
    debconf-set-selections <<< "mdadm mdadm/initrdstart string all"
    debconf-set-selections <<< "mdadm mdadm/initrdstart_notinconf boolean true"
    debconf-set-selections <<< "mdadm mdadm/autostart boolean true"
    debconf-set-selections <<< "mdadm mdadm/autocheck boolean true"
    debconf-set-selections <<< "mdadm mdadm/start_daemon boolean true"
    export DEBIAN_FRONTEND=noninteractive ; dpkg-reconfigure mdadm ; sleep 15;
    mkimage -A arm -O linux -T kernel  -C none -a 0x00008000 -e 0x00008000 -n Linux-kernel_name_here     -d /boot/vmlinuz-kernel_name_here    /boot/uImage && \
    mkimage -A arm -O linux -T ramdisk -C gzip -a 0x00000000 -e 0x00000000 -n initramfs-kernel_name_here -d /boot/initrd.img-kernel_name_here /boot/uInitrd && \
    sed -i -e "s/move_to_raid=true/move_to_raid=false/" /root/firstrun.sh && \
    mkdir /tmp/mnt && \
    mount /dev/md0 /tmp/mnt && \
    rsync -auHxv --exclude=/proc/* --exclude=/sys/* --exclude=/tmp/* /* /tmp/mnt && \
    e2label /dev/sdb1 "oldrfs" && \
    mv /boot /old-boot && \
    umount /tmp/mnt && \
    shutdown -r now
fi

# debconf-set-selections <<< "mdadm mdadm/mail_to string root"
# debconf-set-selections <<< "mdadm mdadm/initrdstart string all"
# debconf-set-selections <<< "mdadm mdadm/initrdstart_notinconf boolean true"
# debconf-set-selections <<< "mdadm mdadm/autostart boolean true"
# debconf-set-selections <<< "mdadm mdadm/autocheck boolean true"
# debconf-set-selections <<< "mdadm mdadm/start_daemon boolean true"
# export DEBIAN_FRONTEND=noninteractive ; dpkg-reconfigure mdadm




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