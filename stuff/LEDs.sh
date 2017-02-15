#!/bin/bash
start() {
#################
# Activate LEDs #
#######################################################################
if [ -d /sys/class/leds/nsa320:orange:sys ]; then
	echo none > /sys/class/leds/nsa320:orange:sys/trigger
	if [ -d /sys/class/leds/nsa320:green:sys ]; then
		echo default-on  > /sys/class/leds/nsa320:green:sys/trigger
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


stop() {
###################
# Deactivate LEDs #
#######################################################################
for x in /sys/class/leds/*
do
	if [ -a "$x/trigger" ]; then
		echo none > $x/trigger
	fi
done

}

case $1 in
        start|stop) "$1" ;;
        *) echo "Usage: systemctl start|stop LEDs"
esac
