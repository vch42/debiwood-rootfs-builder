#!/bin/bash
#Check config variables and fall-back to defaults if needed


# Composing package list to be installed

packs_required=' dbus ca-certificates device-tree-compiler build-essential i2c-tools u-boot-tools initramfs-tools isc-dhcp-client ntp ntpdate ssh mtd-utils parted mdadm rsync wget '
packs="$packs_required $packs_recommended $packs_other"

###########################################################################################################################################################

tools=' qemu-user-static debootstrap binfmt-support udisks2 parted u-boot-tools '

if $samba; then
    packs+=" samba smbclient cifs-utils "
fi


if $cups; then
        packs+=" cups "
fi

if $hdidle; then
        packs+=" hd-idle "
fi

if $hdidle_from_source; then
        packs+=" dh-golang golang-go debhelper git "
fi

if $log_2_ram; then
	packs+=" rsync "
fi

if $nsa320_dtb_chip_delay_0x28; then
    tools+=" device-tree-compiler "
fi
#############################################################################################################################################################


# Some defaults

if [ -z "$label" ]; then
	label='rootfs'
	echo 'No value found for $label, falling back to '$label
fi

if [ -z "$filesystem" ]; then
	filesystem='ext4'
	echo 'No value found for $filesystem, falling back to '$filesystem
fi

if [ -z "$distro" ]; then
	distro='bullseye'
	echo 'No value found for $distro, falling back to '$distro
fi

if [ -z "$repo" ]; then
	repo='http://deb.debian.org/debian'
	echo 'No value found for $repo, falling back to '$repo
fi

if [ -z "$repo_sec" ]; then
	repo_sec='http://security.debian.org/debian-security'
	echo 'No value found for $repo_sec, falling back to '$repo_sec
fi


if [ -z "$arch" ]; then
	arch='armel'
	echo 'No value found for $arch, falling back to '$arch
fi

if [ -z "$machine" ]; then
	machine='nsa320'
	echo 'No value found for $machine, falling back to '$machine
fi

if [ -z "$kernel" ]; then
	kernel='5.18.6-kirkwood-tld-1'
	echo 'No value found for $kernel, falling back to '$kernel
fi

if [ -z "$initial_user" ]; then
	initial_user='user'
	echo 'No value found for $initial_user, falling back to '$initial_user
fi

if [ -z "$initial_pass" ]; then
	initial_pass='changeme'
	echo 'No value found for $initial_pass, falling back to '$initial_pass
fi

if [ -z "$hname" ]; then
	hname='debNAS'
	echo 'No value found for $hname, falling back to '$hname
fi

if [ -z "$dnssuffix" ]; then
	dnssuffix='home.arpa'
	echo 'No value found for $hname, falling back to '$dnssuffix
fi

if [ $write2usb ] && [ -z "$usbblkdev" ]; then
	write2usb=false
	echo '$write2usb is true, but no value found for $usbblkdev, disabling write2usb.'
fi


if $uboot_sntp; then
	flag=0
	[ -z $sntp_ip ]     && ((flag++));
        [ -z $sntp_mask ]   && ((flag++));
        [ -z $sntp_gw ]     && ((flag++));
        [ -z $sntp_dns ]    && ((flag++));
        [ -z $sntp_server ] && ((flag++));
	if [ $flag -gt 0 ]; then
		uboot_sntp=false
		echo;echo;echo;
		echo '$uboot_sntp is true, but values are missing for its config, disabling uboot_sntp.'
		echo 'Check the config file and setup values for sntp_ip, sntp_mask, sntp_gw, sntp_dns and sntp_server.'
	fi
fi

