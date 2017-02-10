#!/bin/bash
#main_stage.sh

# Change these variables in these files to fit your needs!
source ./config
source ./chkconfig.sh


cat <<EOT



WARNING!!! If write2usb is 'true', then the drive at usbblkdev will be wiped!
Abort the script now if something is not configured ok!

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
apt-get -y install $tools





echo;echo;echo '*****************************************************'
echo "Creating root filesystem in ./$targetdir"
echo "(debootstrap stage 1 - downloading packages)"; sleep 1
mkdir $targetdir
debootstrap --arch=$arch --foreign $distro $targetdir $repo;






echo;echo;echo '*****************************************************'
echo "Copy kernel packages and other stuff to ./$targetdir/root/"
echo "(to be installed in chroot and after first boot)"; sleep 1

mkdir -p ./stuff/kern/$kernel/extracted
tar zxf ./stuff/kern/$kernel/*.tar.gz -C ./stuff/kern/$kernel/extracted
tar xf  ./stuff/kern/$kernel/extracted/*.tar -C ./stuff/kern/$kernel/extracted
mkdir -p $targetdir/root/kern
\cp -p  ./stuff/kern/$kernel/extracted/*.deb $targetdir/root/kern/
\cp -rp ./stuff/kern/$kernel/extracted/dts $targetdir/boot/
\rm -rf ./stuff/kern/$kernel/extracted

\cp -rp ./stuff/boot/* $targetdir/boot/

\cp -p ./chroot_stage.sh $targetdir/root/
\cp -p ./config $targetdir/root/
\cp -p ./stuff/firstrun.sh $targetdir/root/

if $samba; then
	cp -rp ./stuff/samba4 $targetdir/root/
fi

if $hpnssh; then
	cp -rp ./stuff/hpnssh $targetdir/root/
fi





echo;echo;echo '*****************************************************'
echo "Will now chroot into $targetdir to continue the setup."; sleep 1
\cp -p /usr/bin/qemu-arm-static $targetdir/usr/bin/;
\cp -p /etc/resolv.conf $targetdir/etc/
chroot $targetdir /root/chroot_stage.sh;



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
\rm -f $targetdir/etc/resolv.conf
\rm -f $targetdir/usr/bin/qemu-arm-static
\rm -f $targetdir/root/chroot_stage.sh
\rm -f $targetdir/root/config
\rm -rf $targetdir/debootstrap/







if $write2usb; then
	echo;echo;echo '*****************************************************'
	echo "Will now write rootfs to $usbblkdev!"
	echo "$usbblkdev WILL BE WIPED!!!"
	read -p "Enter 'yes' to proceed or anything else to abort: " confirmation
	if [ $confirmation = 'yes' ]; then
		for n in $usbblkdev* ; do
			umount $n ;
		done
		sleep 1
		for n in {1..9} ; do
			parted -s $usbblkdev rm $n;
		done
		sleep 1
		parted -s $usbblkdev mklabel msdos; sleep 1
		parted -s -a optimal -- $usbblkdev mkpart primary 1 -1; sleep 1
		mkfs.ext4 -F -L $label $usbblkdev"1"; sleep 1
		mount $usbblkdev"1" ./mnt; sleep 1
		\cp -rpv $targetdir/* ./mnt/; sleep 1
                echo "Customizing /etc/fstab for this specific partition UUID: " $(blkid $usbblkdev"1"|cut -d \  -f 3|sed -e "s@\"@@g")
		sed -ie "s@device_UUID_here@$(blkid $usbblkdev"1"|cut -d \  -f 3|sed -e "s@\"@@g")@" ./mnt/etc/fstab
		echo "Syncing USB drive..."
		sync
cat <<EOT
*****************************
*** USB Install finished. ***
*** Unmounting drive....  ***
*****************************
EOT
		udisks --unmount $usbblkdev"1"
		udisks --detach $usbblkdev

		echo; echo; echo;
		echo "You can now remove the usb stick and boot from it."; sleep 8
	fi
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

read -p "Enter 'y' if you want to keep the installed tools or 'n' to remove: " confirmation
if [ $confirmation != "y" ]; then
        echo "Removing...."
	apt-get purge -y $tools
fi

sleep 7

cat <<EOT
*************************
*** Install finished. ***
*************************
EOT
