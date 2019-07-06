#!/bin/bash
#Check config variables and fall-back to defaults if needed

if [ -z "$label" ]; then
	label='rootfs'
	echo 'No value found for $label, falling back to '$label
fi

if [ -z "$filesystem" ]; then
	filesystem='ext4'
	echo 'No value found for $filesystem, falling back to '$filesystem
fi

#if [ -z "$initsystem" ]; then
#	initsystem='systemd'
#	echo 'No value found for $initsystem, falling back to '$initsystem
#fi

if [ -z "$distro" ]; then
	distro='stretch'
	echo 'No value found for $distro, falling back to '$distro
fi

if [ -z "$repo" ]; then
	repo='http://httpredir.debian.org/debian'
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
	kernel='4.20.6-kirkwood-tld-1'
	echo 'No value found for $kernel, falling back to '$kernel
fi

#if [ -z "$timezone" ]; then
#	timezone='UTC'
#	echo 'No value found for $timezone, falling back to '$timezone
#fi

if [ -z "$initial_user" ]; then
	initial_user='user'
	echo 'No value found for $initial_user, falling back to '$initial_user
fi

if [ -z "$initial_pass" ]; then
	initial_pass='changeme'
	echo 'No value found for $initial_pass, falling back to '$initial_pass
fi

if [ -z "$hname" ]; then
	hname=$targetdir
	echo 'No value found for $hname, falling back to '$hname
fi

if [ $write2usb ] && [ -z "$usbblkdev" ]; then
	write2usb=false
	echo '$write2usb is true, but no value found for $usbblkdev, disabling write2usb.'
fi

if ! [[ $move_to_raid_on_first_boot ]]; then
    packs+=" busybox-syslogd "
    create_swap=false
    filesystem='f2fs'
    echo '$move_to_raid_on_first_boot is false. Swap and logging on USB is not recommended, it leads to increased medium wear.'
    echo 'Disabling swap creation and installing busybox-syslogd to log to RAM.'
    echo 'Will implement logs persistence at a later time.'
    echo 'Also, setting filesystem to f2fs, a better choice for flash drives.'
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

