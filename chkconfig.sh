#!/bin/bash
#Check variables and fall-back to defaults if needed

if [ -z "$label" ]; then
	label='rootfs'
	echo 'No value found for $label, falling back to '$label
fi

if [ -z "$distro" ]; then
	distro='jessie'
	echo 'No value found for $distro, falling back to '$distro
fi

if [ -z "$repo" ]; then
	repo='http://httpredir.debian.org/debian'
	echo 'No value found for $repo, falling back to '$repo
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
	kernel='4.4.0-kirkwood-tld-1'
	echo 'No value found for $kernel, falling back to '$kernel
fi

if [ -z "$timezone" ]; then
	timezone='UTC'
	echo 'No value found for $timezone, falling back to '$timezone
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
	hname=$targetdir
	echo 'No value found for $hname, falling back to '$hname
fi

if [ $write2usb ] && [ -z "$usbblkdev" ]; then
	write2usb=false
	echo '$write2usb is true, but no value found for $usbblkdev, disabling write2usb.'
fi

if $uboot-sntp; then
	echo 'Uboot SNTP setup not yet implemented!!! Disabling...'
	uboot-sntp=false
#	if [ $uboot-sntp ] && [[ -z $uboot-sntp-dnsn ] || [ -z $uboot-sntp-server ]]; then
#		uboot-sntp=false
#		echo '$uboot-sntp is true, but values are missing for $uboot-sntp-dns or $uboot-sntp-server, disabling uboot-sntp.'
#	fi
fi
