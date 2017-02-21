#!/bin/bash
#chroot_stage.sh

source /root/config
source /root/chkconfig.sh

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

cat <<EOT > /etc/apt/apt.conf.d/99force-ipv4
Acquire::ForceIPv4 "true";
EOT


echo;echo;echo '*****************************************************'
echo "Updating apt and packages.";sleep 1
apt-get clean
apt-get update
apt-get upgrade -y



echo;echo;echo '*****************************************************'
echo "Setting timezone..."
echo "(currently selected $timezone)"; sleep 1
echo $timezone > /etc/timezone && dpkg-reconfigure --frontend=noninteractive tzdata



echo;echo;echo '*****************************************************'
echo "Installing/Configuring locales to en_US.UTF-8"; sleep 1
apt-get install -y locales dialog
sed -ie 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
dpkg-reconfigure --frontend=noninteractive locales && \
update-locale LANG=en_US.UTF-8



echo;echo;echo '*****************************************************'
echo "Installing initramfs-tools "; sleep 1
apt-get install -y initramfs-tools



echo;echo;echo '*****************************************************'
echo "Installing kernel and headers"
echo "/root/kern/"; sleep 1
dpkg -i /root/kern/* && \rm -rf /root/kern




echo;echo;echo '*****************************************************'
echo "Setting some values in /boot/uEnv"
echo " -select machine DTB file: kirkwood-"$machine
echo " -setup rootfs label variables for partition with LABEL="$label
echo " -setup rootfs filesystem type to "$filesystem
echo " -setup init system to "$initsystem
echo " -setup machid/arcNumber for "$machine; sleep 2

sed -ie "s/set_label_here/$label/g; s/set_dtb_here/kirkwood-$machine/g; s/set_filesystem_here/$filesystem/g" /boot/uEnv

#if [ $initsystem = "systemd" ]; then
#    sed -ie "s/set_init_here/init=\/bin\/systemd/g" /boot/uEnv
#else
#    sed -ie "s/set_init_here//g" /boot/uEnv
#fi

case $machine in
nsa310)
    sed -ie "s/set_arc_number_here/4022/g; s/set_machid_here//g" /boot/uEnv;;
nsa310s)
    sed -ie "s/set_arc_number_here/4931/g; s/set_machid_here//g" /boot/uEnv;;
nsa320)
    sed -ie "s/set_arc_number_here/3956/g; s/set_machid_here/0x118f/g" /boot/uEnv;;
nsa320s)
    sed -ie "s/set_arc_number_here/4931/g; s/set_machid_here//g" /boot/uEnv;;
nsa325)
    sed -ie "s/set_arc_number_here/4995/g; s/set_machid_here//g" /boot/uEnv;;
pogo_e02)
    sed -ie "s/set_arc_number_here/3542/g; s/set_machid_here/0xdd6/g" /boot/uEnv;;
pogoplug_v4)
    sed -ie "s/set_arc_number_here/3960/g; s/set_machid_here/0xf78/g" /boot/uEnv;;
iconnect)
    sed -ie "s/set_arc_number_here/2870/g; s/set_machid_here//g" /boot/uEnv;;
netgear_stora_ms2000)
    sed -ie "s/set_arc_number_here/2743/g; s/set_machid_here//g" /boot/uEnv;;
dockstar)
    sed -ie "s/set_arc_number_here/2998/g; s/set_machid_here//g" /boot/uEnv;;
goflexhome)
    sed -ie "s/set_arc_number_here/3338/g; s/set_machid_here//g" /boot/uEnv;;
goflexnet)
    sed -ie "s/set_arc_number_here/3089/g; s/set_machid_here//g" /boot/uEnv;;
sheevaplug)
    sed -ie "s/set_arc_number_here/2097/g; s/set_machid_here//g" /boot/uEnv;;
cloudbox)
    sed -ie "s/set_arc_number_here/4170/g; s/set_machid_here//g" /boot/uEnv;;
d2net)
    sed -ie "s/set_arc_number_here/2282/g; s/set_machid_here//g" /boot/uEnv;;
db-88f6281)
    sed -ie "s/set_arc_number_here/1680/g; s/set_machid_here//g" /boot/uEnv;;
dir665)
    sed -ie "s/set_arc_number_here/3487/g; s/set_machid_here//g" /boot/uEnv;;
dns320)
    sed -ie "s/set_arc_number_here/3985/g; s/set_machid_here//g" /boot/uEnv;;
dns325)
    sed -ie "s/set_arc_number_here/3800/g; s/set_machid_here//g" /boot/uEnv;;
dreamplug)
    sed -ie "s/set_arc_number_here/3550/g; s/set_machid_here//g" /boot/uEnv;;
guruplug-server-plus)
    sed -ie "s/set_arc_number_here/2659/g; s/set_machid_here//g" /boot/uEnv;;
iomega_ix2_200)
    sed -ie "s/set_arc_number_here/3119/g; s/set_machid_here//g" /boot/uEnv;;
km_kirkwood)
    sed -ie "s/set_arc_number_here/2255/g; s/set_machid_here//g" /boot/uEnv;;
lsxhl)
    sed -ie "s/set_arc_number_here/2663/g; s/set_machid_here//g" /boot/uEnv;;
mv88f6281gtw_ge)
    sed -ie "s/set_arc_number_here/1932/g; s/set_machid_here//g" /boot/uEnv;;
nas2big)
    sed -ie "s/set_arc_number_here/3757/g; s/set_machid_here//g" /boot/uEnv;;
net2big)
    sed -ie "s/set_arc_number_here/2342/g; s/set_machid_here//g" /boot/uEnv;;
net5big)
    sed -ie "s/set_arc_number_here/2426/g; s/set_machid_here//g" /boot/uEnv;;
openrd-base)
    sed -ie "s/set_arc_number_here/2325/g; s/set_machid_here//g" /boot/uEnv;;
openrd-client)
    sed -ie "s/set_arc_number_here/2361/g; s/set_machid_here//g" /boot/uEnv;;
openrd-ultimate)
    sed -ie "s/set_arc_number_here/2884/g; s/set_machid_here//g" /boot/uEnv;;
rd88f6192)
    sed -ie "s/set_arc_number_here/1681/g; s/set_machid_here//g" /boot/uEnv;;
rd88f6281-a)
    sed -ie "s/set_arc_number_here/1682/g; s/set_machid_here//g" /boot/uEnv;;
rd88f6281-z0)
    sed -ie "s/set_arc_number_here/1682/g; s/set_machid_here//g" /boot/uEnv;;
t5325)
    sed -ie "s/set_arc_number_here/2846/g; s/set_machid_here//g" /boot/uEnv;;
topkick)
    sed -ie "s/set_arc_number_here/4101/g; s/set_machid_here//g" /boot/uEnv;;
ts219-6281)
    sed -ie "s/set_arc_number_here/2139/g; s/set_machid_here//g" /boot/uEnv;;
ts219-6282)
    sed -ie "s/set_arc_number_here/2139/g; s/set_machid_here//g" /boot/uEnv;;
*)
    sed -ie "s/set_arc_number_here//g; s/set_machid_here//g" /boot/uEnv;;
esac





# Uboot SNTP
if $uboot_sntp then;
echo " -setup uboot rtc sntp "; sleep 2
cat <<EOT >> /boot/uEnv/uEnv.txt

set_rtc=setenv ipaddr $sntp_ip ; setenv dnsip $sntp_dns ; setenv gatewayip $sntp_gw ; setenv netmask $sntp_mask; dns $sntp_server ntpserverip; sntp
bootcmd=mw 0x800000 0 1; run set_rtc; run bootcmd_uenv; run scan_disk; run set_bootargs; run bootcmd_exec; sleep 5; reset
EOT
fi





echo;echo;echo '*****************************************************'
echo "Setting /etc/fw_env.config "
echo "(/dev/mtd0 0xc0000 0x20000 0x20000)"; sleep 1
cat <<EOT > /etc/fw_env.config
# MTD device name       Device offset   Env. size       Flash sector size       Number of sectors
  /dev/mtd0             0xc0000         0x20000         0x20000
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
echo "LABEL=$label    /   ext4  errors=remount-ro  0  1"
sleep 1
cat <<EOT > /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type> <options>              <dump>  <pass>
#device_UUID_here       /                ext4  errors=remount-ro        0       1

LABEL=$label       /                ext4  errors=remount-ro        0       1


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
Default user: $initial_user
Default pass: $initial_pass
CHANGE THEM ON FIRST LOGIN !!!!
===================================================
EOT



echo;echo;echo '*****************************************************'
echo "Setting firstboot.service to run /usr/sbin/firstboot "
echo " "; sleep 1
chmod +x /usr/sbin/firstboot
systemctl daemon-reload
systemctl enable firstboot.service



echo;echo;echo '*****************************************************'
echo "Activating rc-local.service"
echo " "; sleep 5
chmod +x /etc/rc.local
cat<<EOT >> /lib/systemd/system/rc-local.service


[Install]
 WantedBy=multi-user.target
EOT
systemctl enable rc-local.service



echo;echo;echo '*****************************************************'
echo "Creating the service to start/stop LEDs"
echo ""; sleep 3
chmod +x /usr/sbin/leds
systemctl daemon-reload
systemctl enable leds.service




echo;echo;echo '*****************************************************'
echo "Installing the rest of the packages"
echo " "; sleep 5
debconf-set-selections <<< 'iptables-persistent iptables-persistent/autosave_v4 boolean true'
debconf-set-selections <<< 'iptables-persistent iptables-persistent/autosave_v6 boolean true'
apt-get install -y $packs
echo 'DEVICE /dev/sd?*' >> /etc/mdadm/mdadm.conf
update-initramfs -u -k all



echo;echo;echo '*****************************************************'
echo "Cleaning up apt cache to reduce rootfs size."; sleep 1
apt-get clean




echo;echo;echo '*****************************************************'
echo "Done here!"
echo "Will now exit chroot."; sleep 5


exit 0
