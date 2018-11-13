#!/bin/ksh93

if test $UID -ne 0; then
  echo "This script has to be run as root. Exiting."
  exit 1
fi

LBHOME="${.sh.file%/*/*}"

# sudoers.d
if [ -d /etc/suddoers.d ]; then
	mv /etc/sudoers.d /etc/sudoers.d.orig
fi
if [ -L /etc/sudoers.d ]; then
    rm /etc/sudoers.d
fi
ln -s $LBHOME/system/sudoers /etc/sudoers.d

# profile.d/loxberry.sh
if [ -L /etc/profile.d/loxberry.sh ]; then
    rm /etc/profile.d/loxberry.sh
fi
ln -s $LBHOME/system/profile/loxberry.sh /etc/profile.d/loxberry.sh

# /etc/creds for autofs and smb
if [ -e /etc/creds ]; then
	rm /etc/creds
fi
ln -s $LBHOME/system/samba/credentials /etc/creds

# Obsolete Apache2 logrotate config (we this by our own)
if [ -e /etc/logrotate.d/apache2 ]; then
    rm /etc/logrotate.d/apache2
fi

# Init Script
if [ -L /etc/init.d/loxberry ]; then  
   rm /etc/init.d/loxberry
fi
ln -s $LBHOME/sbin/loxberryinit.sh /etc/init.d/loxberry
update-rc.d loxberry defaults

if [ -L /etc/init.d/createtmpfsfoldersinit ]; then  
   rm /etc/init.d/createtmpfsfoldersinit
fi
ln -s $LBHOME/sbin/createtmpfsfoldersinit.sh /etc/init.d/createtmpfsfoldersinit
update-rc.d createtmpfsfoldersinit defaults

# Apache Config
if [ ! -L /etc/apache2 ]; then
	mv /etc/apache2 /etc/apache2.old
fi
if [ -L /etc/apache2 ]; then  
    rm /etc/apache2
fi
ln -s $LBHOME/system/apache2 /etc/apache2

# Network config
if [ ! -L /etc/network/interfaces ]; then
	mv /etc/network/interfaces /etc/network/interfaces.old
fi
if [ -L /etc/network/interfaces ]; then  
    rm /etc/network/interfaces
fi
ln -s $LBHOME/system/network/interfaces /etc/network/interfaces

# Logrotate job - move to hourly
if [ -e /etc/cron.daily/logrotate ] ; then mv -f /etc/cron.daily/logrotate /etc/cron.hourly/ ; fi 
# Logrotate config
if [ -L /etc/logrotate.d/loxberry ]; then
    rm /etc/logrotate.d/loxberry
fi
ln -s $LBHOME/system/logrotate/logrotate /etc/logrotate.d/loxberry

# Samba Config
if [ ! -L /etc/samba ]; then
	mv /etc/samba /etc/samba.old
fi
if [ -L /etc/samba ]; then
    rm /etc/samba
fi
ln -s $LBHOME/system/samba /etc/samba

# VSFTPd Config
if [ ! -L /etc/vsftpd.conf ]; then
	mv /etc/vsftpd.conf /etc/vsftpd.conf.old
fi
if [ -L /etc/vsftpd.conf ]; then
    rm /etc/vsftpd.conf
fi
ln -s $LBHOME/system/vsftpd/vsftpd.conf /etc/vsftpd.conf

# SSMTP Config
if [ ! -L /etc/ssmtp ]; then
	mv /etc/ssmtp /etc/ssmtp.old
fi
if [ -L /etc/ssmtp ]; then
    rm /etc/ssmtp
fi
ln -s $LBHOME/system/ssmtp /etc/ssmtp

# PHP
print "include_path='.:$LBHOME/libs/phplib'" \
	> /etc/php/7.0/apache2/conf.d/20-loxberry.ini
print "include_path='.:$LBHOME/libs/phplib'" \
	> /etc/php/7.0/cli/conf.d/20-loxberry.ini


# Cron.d
if [ ! -L /etc/cron.d ]; then
	mv /etc/cron.d /etc/cron.d.old
fi
if [ -L /etc/cron.d ]; then
    rm /etc/cron.d
fi
ln -s $LBHOME/system/cron/cron.d /etc/cron.d

# Group mebership
/usr/sbin/usermod -a -G sudo,dialout,audio,gpio,tty,www-data loxberry

# Skel for system logs, LB system logs and LB plugin logs
if [ -d $LBHOME/log/skel_system/ ]; then
    find $LBHOME/log/skel_system/ -type f -exec rm {} \;
fi
if [ -d $LBHOME/log/skel_syslog/ ]; then
    find $LBHOME/log/skel_syslog/ -type f -exec rm {} \;
fi
if [ -d $LBHOME/log/skel_plugins/ ]; then
    find $LBHOME/log/skel_plugins/ -type f -exec rm {} \;
fi

# Clean apt cache
rm -rf /var/cache/apt/archives/*

# Disable PrivateTmp for Apache2 on systemd
# (also included in 1.0.2 Update script)
if [ ! -e /etc/systemd/system/apache2.service.d/privatetmp.conf ]; then
	mkdir -p /etc/systemd/system/apache2.service.d
	echo -e "[Service]\nPrivateTmp=no" > /etc/systemd/system/apache2.service.d/privatetmp.conf 
fi

# Systemd service for usb automount
# (also included in 1.0.4 Update script)
if [ ! -e /etc/systemd/system/usb-mount@.service ]; then
(cat <<END
[Unit]
Description=Mount USB Drive on %i
[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=$LBHOME/sbin/usb-mount.sh add %i
ExecStop=$LBHOME/sbin/usb-mount.sh remove %i
END
) > /etc/systemd/system/usb-mount@.service
fi

# Create udev rules for usbautomount
# (also included in 1.0.4 Update script)
if [ ! -e /etc/udev/rules.d/99-usbmount.rules ]; then
(cat <<END
KERNEL=="sd[a-z]*[0-9]", SUBSYSTEMS=="usb", ACTION=="add", RUN+="/opt/loxberry/sbin/usb-mount.sh chkadd %k"
KERNEL=="sd[a-z]*[0-9]", SUBSYSTEMS=="usb", ACTION=="remove", RUN+="/bin/systemctl stop usb-mount@%k.service"
END
) > /etc/udev/rules.d/99-usbmount.rules
fi

# Configure autofs
if [ ! -e /etc/auto.master ]; then
	awk -v s='/media/smb /etc/auto.smb --timeout=300 --ghost' '/^\/media\/smb/{$0=s;f=1} {a[++n]=$0} END{if(!f)a[++n]=s;for(i=1;i<=n;i++)print a[i]>ARGV[1]}' /etc/auto.master
fi
mkdir -p /media/smb
mkdir -p /media/usb

# creds for AutoFS (SMB)
if [ -L /etc/creds ]; then
    rm /etc/creds
fi
ln -s $LBHOME/system/samba/credentials /etc/creds

# Activating i2c
# (also included in 1.0.3 Update script)
$LBHOME/sbin/activate_i2c.sh

# Mount all from /etc/fstab
if ! grep -q -e "^mount -a" /etc/rc.local; then
	sed -i 's/^exit 0/mount -a\n\nexit 0/g' /etc/rc.local
fi
