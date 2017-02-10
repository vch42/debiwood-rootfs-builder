#!/bin/sh
#chroot_stage.sh

source ./root/config
source ./root/chkconfig.sh

export LANG=C


echo;echo;echo '*****************************************************'
echo "We have now chrooted to the rootfs."
echo "Proceeding to debootstrap stage 2 install"; sleep 1
/debootstrap/debootstrap --second-stage --keep-debootstrap-dir




echo;echo;echo '*****************************************************'
echo "Done debootstrap second stage. Further customizing rootfs."
echo "Setting  /apt/sources.list to use selected repo"
echo "($repo)"; sleep 1
cat <<EOT > /etc/apt/sources.list
deb $repo $distro main contrib non-free
#deb-src $repo $distro main contrib non-free
deb $repo $distro-updates main contrib non-free
#deb-src $repo $distro-updates main contrib non-free
deb http://security.debian.org/debian-security $distro/updates main contrib non-free
#deb-src http://security.debian.org/debian-security $distro/updates main contrib non-free
EOT

cat <<EOT > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOT




echo;echo;echo '*****************************************************'
echo "Updating apt and packages.";sleep 1
apt-get clean
apt-get update
apt-get upgrade -y



echo;echo;echo '*****************************************************'
echo "Setting timezone..."
echo "(currently selected $timezone)"; sleep 1
echo $timezone > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata



echo;echo;echo '*****************************************************'
echo "Installing/Configuring locales to en_US.UTF-8"; sleep 1
apt-get install -y locales dialog
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
dpkg-reconfigure --frontend=noninteractive locales && \
update-locale LANG=en_US.UTF-8



echo;echo;echo '*****************************************************'
echo "Installing initramfs-tools "; sleep 1
apt-get install -y initramfs-tools



echo;echo;echo '*****************************************************'
echo "Installing kernel and headers"
echo "/root/kern/"; sleep 1
dpkg -i /root/kern/*
\rm -rf /root/kern


echo;echo;echo '*****************************************************'
echo "Adding nsa3xx-hwmon in /etc/modules"; sleep 1
echo nsa3xx-hwmon >> /etc/modules



echo;echo;echo '*****************************************************'
echo "Setting some values in /boot/uEnv/uEnv.txt."
echo " -select machine DTB file: kirkwood-"$machine
echo " -setup sata_root and usb_root variables for partition with LABEL="$label; sleep 2
sed -ie "s/set_label_here/$label/g; s/set_dtb_here/kirkwood-$DTB/g" /boot/uEnv/uEnv.txt
if [ $machine == "pogo_e02" ]; then
	echo " -setup machid for Pogo E02"; sleep 1
	echo "machid=dd6" >> /boot/uEnv/uEnv.txt
fi
if [ $machine == "pogoplug_v4" ]; then
	echo " - setup machid for Pogo v4"; sleep 1
	echo "machid=f78" >> /boot/uEnv/uEnv.txt
fi
# Uboot SNTP to be done
#if $uboot-sntp then;
#echo " -setup uboot rtc sntp "; sleep 2
#cat <<EOT >> /boot/uEnv/uEnv.txt
#setenv set_rtc \'setenv dnsip $uboot-sntp-gw;setenv gatewayip $uboot-sntp-gw;setenv netmask $uboot-sntp-nmask; dns $uboot-sntp-server ntpserver; sntp \$ntpserver\'
#EOT
#sed -ie "s/usb_boot=/usb_boot=run set_rtc;/; s/sata_boot=/sata_boot=run set_rtc;/" /boot/uEnv/uEnv.txt
#fi





echo;echo;echo '*****************************************************'
echo "Setting /etc/fw_env.config "
echo "(/dev/mtd0 0xc0000 0x20000 0x20000)"; sleep 1
cat <<EOT > /etc/fw_env.config
# MTD device name       Device offset   Env. size       Flash sector size       Number of sectors
/dev/mtd0 0xc0000 0x20000 0x20000
EOT




echo;echo;echo '*****************************************************'
echo "Setting  hostname"
echo "($hname)"; sleep 1
echo $hname > /etc/hostname

cat <<EOT > /etc/hosts
127.0.0.1    localhost.localdomain localhost
127.0.1.1    $hname
EOT






echo;echo;echo '*****************************************************'
echo "Setting  /etc/fstab"
echo "(skel, will be modified when writing to USB)"
sleep 1
cat <<EOT > /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type> <options>              <dump>  <pass>
device_UUID_here       /                ext4  errors=remount-ro        0       1
EOT




echo;echo;echo '*****************************************************'
echo "Setting  /etc/network/interfaces.d/"
echo "(eth0 dhcp; lo loopback)"; sleep 1
cat <<EOT > /etc/network/interfaces.d/eth0
auto eth0
iface eth0 inet dhcp
EOT

cat <<EOT > /etc/network/interfaces.d/lo
auto lo
iface lo inet loopback
EOT





echo;echo;echo '*****************************************************'
echo "Setting  /etc/default/useradd"
echo "(original one saved to old.useradd)"; sleep 1
\mv /etc/default/useradd /etc/default/old.useradd 
cat <<EOT > /etc/default/useradd
SHELL=/bin/bash
GROUP=100
HOME=/home
INACTIVE=-1
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
EOT



echo;echo;echo '*****************************************************'
echo "Setting /etc/skel/.bashrc"
echo "(see script source for changes made)"; sleep 1
cat <<EOT >> /etc/skel/.bashrc
force_color_prompt=yes
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
EOT



echo;echo;echo '*****************************************************'
echo "Setting /root/.bashrc"
echo "(see script source for changes made)"; sleep 1
cat <<EOT >> /root/.bashrc
force_color_prompt=yes
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

EOT



echo;echo;echo '*****************************************************'
echo "Setting /etc/bash.bashrc"
echo "(see script source for changes made)"; sleep 1
cat <<EOT >> /etc/bash.bashrc

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
EOT





echo;echo;echo '*****************************************************'
echo "Configuring serial console and default.target to multi-user.target"
echo " "; sleep 1
ln -s /lib/systemd/system/serial-getty@.service /etc/systemd/system/getty.target.wants/serial-getty@ttyAMA0.service
rm -f /lib/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /lib/systemd/system/default.target







echo;echo;echo '*****************************************************'
echo Creating user: $initial_user
echo password: $initial_pass
echo "User $initial_user has full sudo rights"; sleep 3
useradd -m -G sudo $initial_user
echo $initial_user:$initial_pass | chpasswd
echo
cat <<EOT

WARNING!!!
Root user does not have a password!
It would be smart to leave it this way! ;-)


EOT
sleep 7






echo;echo;echo '*****************************************************'
echo "Setting /etc/issue with a useful prelogin message for serial console."
echo "(hostname, IP, version etc.)"; sleep 3
mv /etc/issue /etc/issue.orig
cat <<EOT > /etc/issue
\S \m \l@\bbps
\v
Kernel: \s-\r
\t \d
Active sessions: \U
===================================================
Host: \n.\O
IPv4: \4{eth0}
IPv6: \6{eth0}
===================================================
EOT



echo;echo;echo '*****************************************************'
echo "Setting first run script in rc.local"
echo " "; sleep 1
sed -ie '/exit 0/d' /etc/rc.local
cat <<EOT >> /etc/rc.local
/root/firstrun.sh &

exit 0
EOT


echo;echo;echo '*****************************************************'
echo "Creating the service to start/stop LEDs"
echo ""; sleep 3

cat <<EOT > /usr/sbin/LEDs.sh
#!/bin/bash
Start() {
#################
# Activate LEDs #
#######################################################################
if [ -d /sys/class/leds/nsa320:orange:sys ]; then
	echo none > /sys/class/leds/nsa320:orange:sys/trigger
	if [ -d /sys/class/leds/nsa320:green:sys ]; then
		echo default-on  > /sys/class/leds/nsa320:green:sys/trigger
	fi
	if [ -d /sys/class/leds/nsa320:orange:sys ]; then
		echo heartbeat  > /sys/class/leds/nsa320:orange:sys/trigger
	fi
	if [ -d /sys/class/leds/nsa320:red:hdd1 ]; then
		echo ide-disk1  > /sys/class/leds/nsa320:red:hdd1/trigger
	fi
	if [ -d /sys/class/leds/nsa320:red:hdd2 ]; then
		echo ide-disk2  > /sys/class/leds/nsa320:red:hdd2/trigger
	fi
	if [ -d /sys/class/leds/nsa320:green:usb ]; then
		echo usb-host  > /sys/class/leds/nsa320:green:usb/trigger
	fi
	if [ -d /sys/class/leds/nsa320:green:copy ]; then
		echo nand-disk  > /sys/class/leds/nsa320:red:copy/trigger
	fi
fi

########################################################################

if [ -d /sys/class/leds/status:green:health ]; then
   echo default-on > /sys/class/leds/status:green:health/trigger
   if [ -d /sys/class/leds/status:orange:fault ]; then
      echo none > /sys/class/leds/status:orange:fault/trigger
   fi
   if [ -d /sys/class/leds/status:blue:health ]; then
      echo none > /sys/class/leds/status:blue:health/trigger
   fi
fi

#########################################################################

if [ -d /sys/class/leds/dockstar:green:health ]; then
   echo default-on > /sys/class/leds/dockstar:green:health/trigger
   echo none > /sys/class/leds/dockstar:orange:misc/trigger
fi

#########################################################################

if [ -d /sys/class/leds/plug:green:health ]; then
   echo default-on > /sys/class/leds/plug:green:health/trigger
   if [ -d /sys/class/leds/plug:red:misc ]; then
      echo none  > /sys/class/leds/plug:red:misc/trigger
   fi
fi

##########################################################################

if [ -d /sys/class/leds/power:blue ]; then
   echo default-on  > /sys/class/leds/power:blue/trigger
   ### echo default-on  > /sys/class/leds/otb:blue/trigger
   echo none        > /sys/class/leds/power:red/trigger
fi

if [ -d /sys/class/leds/usb1:blue ]; then
   echo usb-host > /sys/class/leds/usb1\:blue/trigger
fi
if [ -d /sys/class/leds/usb2:blue ]; then
   echo usb-host > /sys/class/leds/usb2\:blue/trigger
fi
if [ -d /sys/class/leds/usb3:blue ]; then
   echo usb-host > /sys/class/leds/usb3\:blue/trigger
fi
if [ -d /sys/class/leds/usb4:blue ]; then
   echo usb-host > /sys/class/leds/usb4\:blue/trigger
fi

##########################################################################

if [ -d /sys/class/leds/nsa325:green:sys ]; then
   echo default-on  > /sys/class/leds/nsa325:green:sys/trigger
   echo none        > /sys/class/leds/nsa325:orange:sys/trigger
fi

if [ -d /sys/class/leds/nsa325:green:sata1 ]; then
   echo ide-disk1  > /sys/class/leds/nsa325:green:sata1/trigger
fi

if [ -d /sys/class/leds/nsa325:green:sata2 ]; then
   echo ide-disk2  > /sys/class/leds/nsa325:green:sata2/trigger
fi

if [ -d /sys/class/leds/nsa325:green:usb ]; then
   echo usb-host > /sys/class/leds/nsa325\:green\:usb/trigger
fi

###########################################################################

}


Stop() {
###################
# Deactivate LEDs #
#######################################################################
for x in /sys/class/leds/*
do
	if [ -d "\$x/trigger" ]; then
		echo none > \$x/trigger
	fi
done

}

case \$1 in
        start|stop) "\$1" ;;
        *) echo "Usage: systemctl start|stop LEDs"
esac


EOT

chmod +x /usr/sbin/LEDs.sh

cat <<EOT > /lib/systemd/system/LEDs.service
[Unit]
Description=LEDs
After=udev.service
Before=sysinit.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/LEDs.sh start
ExecStop=/usr/sbin/LEDs.sh stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable LEDs.service




echo;echo;echo '*****************************************************'
echo "Installing the rest of the packages"
echo " "; sleep 5
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y $packs
update-initramfs -u




echo;echo;echo '*****************************************************'
echo "Cleaning up apt cache to reduce rootfs size."; sleep 1
apt-get clean






echo;echo;echo '*****************************************************'
echo "Done here!"
echo "Will now exit chroot."; sleep 5


exit 0
