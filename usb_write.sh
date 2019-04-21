#!/bin/bash
#usb_write.sh

if [[ `id -u` -ne 0 ]]; then
   echo "This script must be run as root, exiting."
   exit 1
fi

chmod +x chkconfig.sh
chmod +x config
chmod +x chroot_stage.sh

# Change variables in below files to fit your needs!
source ./config
source ./chkconfig.sh

if [[ -z $1 ]]; then exit 1; fi
if [[ -z $2 ]]; then exit 2; fi

echo "$1 WILL BE WIPED!!!"
for n in $1"*" ; do
    umount $n ;
done
sleep 1
parted -s $1 mklabel msdos; sleep 1
parted -s -a optimal -- $1 mkpart primary 1 -1; sleep 1
mkfs.$filesystem -F -L $label $1"1"; sleep 1
mkdir -p /tmp/mnt
mount $1"1" /tmp/mnt; sleep 1
#\cp -rpv $targetdir/* /tmp/mnt/; sleep 1
\cp -rp $2/* /tmp/mnt/; sleep 1
echo "Syncing USB drive..."
sync
echo "*****************************"
echo "*** USB Install finished. ***"
echo "*** Unmounting drive....  ***"
echo "*****************************"
umount /tmp/mnt
echo; echo; echo;
echo "You can now remove the usb stick and boot from it."
