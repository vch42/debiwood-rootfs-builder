#!/bin/bash
#main_stage.sh

chmod +x chkconfig.sh
chmod +x config
chmod +x chroot_stage.sh

# Change variables in below files to fit your needs!
source ./config
source ./chkconfig.sh


cat <<EOT



WARNING!!! If write2usb is 'true', then the drive at usbblkdev will be wiped!
Abort the script now if something is not configured ok!

Current settings are:

write2usb=$write2usb
usbblkdev=$usbblkdev



EOT

read -p "Enter 'yes' to proceed or 'no' to abort: " confirmation
if [ $confirmation != "yes" ]; then
	echo "Aborting... Please reconfigure as required and run again."
	exit 78
fi



echo;echo;echo '*****************************************************'
echo Installing tools...;sleep 1
apt-get update && apt-get -y install $tools




echo;echo;echo '*****************************************************'
echo "Creating root filesystem in ./$targetdir"
echo "(debootstrap stage 1 - downloading packages)"; sleep 1
mkdir $targetdir
debootstrap --arch=$arch --foreign $distro $targetdir $repo;



echo;echo;echo '*****************************************************'
echo "Copy kernel packages and other stuff to ./$targetdir/root/"
echo "(to be installed in chroot and after first boot)"; sleep 1

mkdir -p ./stuff/kern/$kernel/extracted
mkdir -p ./$targetdir/root/kern
tar jxf ./stuff/kern/$kernel/*.tar.bz2 -C ./stuff/kern/$kernel/extracted
tar xf  ./stuff/kern/$kernel/extracted/*.tar -C ./stuff/kern/$kernel/extracted
\cp -p  ./stuff/kern/$kernel/extracted/*.deb ./$targetdir/root/kern/
\cp -rp ./stuff/kern/$kernel/extracted/dts ./$targetdir/boot/
\rm -rf ./stuff/kern/$kernel/extracted

if $nsa320_dtb_chip_delay_0x28; then
        echo "Changing DTB for NSA320 (chipdelay change from 0x23 to 0x28)..."
        \cp -p ./$targetdir/boot/dts/kirkwood-nsa320.dtb ./$targetdir/boot/dts/kirkwood-nsa320.dtb.orig
        dtc -q -I dtb -O dts -o ./$targetdir/boot/dts/kirkwood-nsa320.dts ./$targetdir/boot/dts/kirkwood-nsa320.dtb
        sed -i 's/chip-delay = <0x23>;/chip-delay = <0x28>;/' ./$targetdir/boot/dts/kirkwood-nsa320.dts
        \rm -f ./$targetdir/boot/dts/kirkwood-nsa320.dtb
        dtc -q -I dts -O dtb -o ./$targetdir/boot/dts/kirkwood-nsa320.dtb ./$targetdir/boot/dts/kirkwood-nsa320.dts
        \rm -f ./$targetdir/boot/dts/kirkwood-nsa320.dts
        echo "Changed."
fi


\cp -rp ./stuff/uEnv/uEnv_skel ./$targetdir/boot/uEnv


\cp -p ./chroot_stage.sh ./$targetdir/root/
\cp -p ./config ./$targetdir/root/
\cp -p ./chkconfig.sh ./$targetdir/root/


\cp -p ./stuff/firstboot/firstboot ./$targetdir/usr/sbin/
\cp -p ./stuff/firstboot/firstboot.conf ./$targetdir/etc/
#\cp -p ./stuff/firstboot/firstboot.service ./$targetdir/lib/systemd/system/
\cp -p ./stuff/firstboot/firstboot.service ./$targetdir/root/


if $move_to_raid_on_first_boot; then
   sed -i 's/move_to_raid=false/move_to_raid=true/' ./$targetdir/etc/firstboot.conf
fi


sed -i "s/rootfs_fs_here/$filesystem/" ./$targetdir/etc/firstboot.conf
sed -i "s/rootfs_label_here/$label/" ./$targetdir/etc/firstboot.conf
sed -i "s/kernel_name_here/$kernel/" ./$targetdir/etc/firstboot.conf
sed -i "s/size_of_raid_part/$raid_rootfs_partition_size/" ./$targetdir/etc/firstboot.conf


\cp -p ./stuff/leds/leds ./$targetdir/usr/sbin/
#\cp -p ./stuff/leds/leds.service ./$targetdir/lib/systemd/system/
\cp -p ./stuff/leds/leds.service ./$targetdir/root/


if $hpnssh; then
    cp -rp ./stuff/hpnssh ./$targetdir/usr/src/
    sed -i "s/hpnssh=false/hpnssh=true/" ./$targetdir/etc/firstboot.conf
fi

if $create_swap; then
    sed -i "s/create_swap=false/create_swap=true/" ./$targetdir/etc/firstboot.conf
fi



echo;echo;echo '*****************************************************'
echo "Will now chroot into $targetdir to continue the setup."; sleep 1
\cp -p /usr/bin/qemu-arm-static $targetdir/usr/bin/
\cp -p /etc/resolv.conf $targetdir/etc/
chroot $targetdir /root/chroot_stage.sh



###########################################################################
###########################################################################
###########################################################################




echo;echo;echo '*****************************************************'
echo "Generating kernel and initramfs images."
echo " "; sleep 1
mkimage -A arm -O linux -T kernel  -C none -a 0x00008000 -e 0x00008000 -n Linux-$kernel     -d $targetdir/boot/vmlinuz-$kernel    $targetdir/boot/uImage
mkimage -A arm -O linux -T ramdisk -C gzip -a 0x00000000 -e 0x00000000 -n initramfs-$kernel -d $targetdir/boot/initrd.img-$kernel $targetdir/boot/uInitrd




echo;echo;echo '*****************************************************'
echo "Cleaning up rootfs and preparing."
echo " "; sleep 1
\rm -f  $targetdir/etc/resolv.conf
\rm -f  $targetdir/usr/bin/qemu-arm-static
\rm -f  $targetdir/root/chroot_stage.sh
\rm -f  $targetdir/root/config
\rm -f  $targetdir/root/chkconfig.sh
\rm -rf $targetdir/debootstrap/








if $write2usb; then
	echo;echo;echo '*****************************************************'
	echo "Will now write rootfs to $usbblkdev!"
	echo "$usbblkdev WILL BE WIPED!!!"
		for n in $usbblkdev* ; do
			umount $n ;
		done
		sleep 1
#		for n in {1..9} ; do
#			parted -s $usbblkdev rm $n;
#		done
		sleep 1
		parted -s $usbblkdev mklabel msdos; sleep 1
		parted -s -a optimal -- $usbblkdev mkpart primary 1 -1; sleep 1
		mkfs.$filesystem -F -L $label $usbblkdev"1"; sleep 1
		mkdir -p /tmp/mnt
		mount $usbblkdev"1" /tmp/mnt; sleep 1
		\cp -rpv $targetdir/* /tmp/mnt/; sleep 1
		echo "Syncing USB drive..."
		sync
cat <<EOT
*****************************
*** USB Install finished. ***
*** Unmounting drive....  ***
*****************************
EOT
		#udisks --unmount $usbblkdev"1"
		#udisks --detach $usbblkdev
        
		echo; echo; echo;
		echo "You can now remove the usb stick and boot from it."; sleep 8
fi








if $pack2archive; then
	echo;echo;echo '*****************************************************'
	echo "Generating $filename"
	cd $targetdir
	tar cpjf ../$filename .
	cd ..
	ls -lh |grep $filename
	if $send2server; then
		echo;echo;echo '*****************************************************'
		echo "Sending $filename to $server2send, connecting as $serverusername"
		echo "Please input password when requested."
		scp $filename $serverusername@$server2send:/root/
		echo "File saved on $server2send at /home/$serverusername/$filename"
	fi
	rm -rf $targetdir
fi




cat <<EOT
Tools installed on this PC by these scripts:
$tools

EOT

#read -p "Enter 'y' if you want to keep the installed tools or 'n' to remove: " confirmation
#if [ $confirmation != "y" ]; then
#        echo "Removing...."
#	apt-get purge -y $tools
#fi

#sleep 7

cat <<EOT
*************************
*** Install finished. ***
*************************
EOT
