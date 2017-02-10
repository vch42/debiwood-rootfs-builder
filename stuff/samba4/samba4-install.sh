#!/bin/sh
# samba4_install.sh

if [ -z $1 ]; then
   echo "Missing version number to install...";
   echo "eg. ./samba4_install.sh 4.0.0";
   echo "                                    ";
   exit 1;
fi


# Install dependencies
time apt-get install -y acl attr autoconf bison build-essential \
  debhelper dnsutils docbook-xml docbook-xsl flex gdb krb5-user \
  libacl1-dev libaio-dev libattr1-dev libblkid-dev libbsd-dev \
  libcap-dev libcups2-dev libgnutls28-dev libjson-perl \
  libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl \
  libpopt-dev libreadline-dev perl perl-modules pkg-config \
  python-all-dev python-dev python-dnspython python-crypto \
  xsltproc zlib1g-dev ntp


# Download samba4 sources
wget https://download.samba.org/pub/samba/stable/samba-$1.tar.gz
# Extract archive
tar -zxvf samba-$1.tar.gz


# Build & Install
cd samba-$1
rm -f buildtime.log


echo 'Configure start: ' $(date) > buildtime.log
#Paths:
#   #BINDIR:  /usr/bin
#   #SBINDIR: /usr/sbin
#
#   #CONFIGFILE:      /etc/samba/smb.conf
#   #SMB_PASSWD_FILE: /etc/samba/smbpasswd
#   #LMHOSTSFILE:     /etc/samba/lmhosts
#
#   #LIBDIR:     /usr/lib/x86_64-linux-gnu
#   #MODULESDIR: /usr/lib/x86_64-linux-gnu/samba
#
#   SHLIBEXT: so
#
#   #LOCKDIR:     /var/run/samba
#   #PIDDIR:      /var/run/samba
#
#   #STATEDIR:    /var/lib/samba
#   #PRIVATE_DIR: /var/lib/samba/private
#
#   #CACHEDIR:    /var/cache/samba
#   #LOGFILEBASE: /var/log/samba

time ./configure \
        --enable-fhs \
        --prefix=/usr --exec-prefix=/usr \
        --sysconfdir=/etc --localstatedir=/var \
        --with-lockdir=/var/run/samba \
        --libdir=/usr/lib/x86_64-linux-gnu \
        --with-systemd --with-regedit --enable-debug



echo 'Make start:      ' $(date) >> buildtime.log
make -j4

echo 'Install start:   ' $(date) >> buildtime.log
make -j4 install

echo 'All done:        ' $(date) >> buildtime.log








cp ./packaging/systemd/*.service /lib/systemd/system/
cp ./packaging/systemd/samba.sysconfig /etc/samba/

back=$(pwd)

cd /lib/systemd/system

sed -i \
-e 's@ExecReload=/usr/bin/kill -HUP $MAINPID@ExecReload=/bin/kill -HUP $MAINPID@' \
-e 's@EnvironmentFile=-/etc/sysconfig/samba@EnvironmentFile=-/etc/samba/samba.sysconfig@' \
-e 's@Type=notify@Type=forking@' \
nmb.service smb.service samba.service winbind.service

sed -i -e 's@PIDFile=/run/nmbd.pid@PIDFile=/var/run/samba/nmbd.pid@' nmb.service
sed -i -e 's@PIDFile=/run/smbd.pid@PIDFile=/var/run/samba/smbd.pid@' smb.service
sed -i -e 's@PIDFile=/run/samba.pid@PIDFile=/var/run/samba/samba.pid@' samba.service
sed -i -e 's@PIDFile=/run/winbindd.pid@PIDFile=/var/run/samba/winbindd.pid@' winbind.service


systemctl daemon-reload

systemctl enable samba.service
#systemctl enable smb.service
#systemctl enable nmb.service
#systemctl enable winbind.service




mkdir /var/lib/samba/ntp_signd/
chown root:ntp /var/lib/samba/ntp_signd/
chmod 750 /var/lib/samba/ntp_signd/
ls -ld /var/lib/samba/ntp_signd/



cat <<EOT > /etc/ntp.conf
# Local clock (Note: This is not the localhost address!)
server 127.127.1.0
fudge  127.127.1.0 stratum 10
# The source, where we are receiving the time from
server 192.168.1.254            iburst prefer
server ro.pool.ntp.org          iburst
server europe.pool.ntp.org      iburst
driftfile       /var/lib/ntp/ntp.drift
logfile         /var/log/ntp
ntpsigndsocket  /var/lib/samba/ntp_signd/
# Access control
# Default restriction: Only allow querying time (incl. ms-sntp) from this machine
restrict default kod nomodify notrap nopeer mssntp
# Allow everything from localhost
restrict 127.0.0.1
# Allow that our time source can only provide time and do nothing else
restrict 192.168.1.254          mask 255.255.255.255    nomodify notrap nopeer noquery
restrict ro.pool.ntp.org        mask 255.255.255.255    nomodify notrap nopeer noquery
restrict europe.pool.ntp.org    mask 255.255.255.255    nomodify notrap nopeer noquery
EOT

service ntp restart


cd $back; cd ..
