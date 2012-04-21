#!/bin/bash

# environnement
myscripts=$(dirname $0)
cd $myscripts
. ./env.sh
   
clear
echo "+-------------------------------------------------+" 
echo "|   (c)opyLEFT www.monitoring-fr.org 201 by       |" 
echo "|   david GUENAULT dguenault AT nagios-fr DOT org |" 
echo "+-------------------------------------------------+" 
echo "|   This Script is subject to the GPL License!    |" 
echo "|   You can copy and change it!                   |" 
echo "|                                                 |" 
echo "|   We can't guarantee that it works smooth       |" 
echo "|   on your system!                               |" 
echo "|                                                 |" 
echo "|   You use it at your own risk!                  |" 
echo "|                                                 |" 
echo "|   This script download, build and install       |" 
echo "|   nagios on ubuntu server (8.04+)               |" 
echo "+-------------------------------------------------+" 
echo "| 2010-03-05 - initial release                    |"
echo "+-------------------------------------------------+" 

# Check if we launch the script with root privileges (aka sudo)
if [ "$UID" != "0" ]
then
	cecho "You should start the script with sudo!" red
	exit 1
fi

# check if sources and build directories are here
if [ ! -d "$builddir" ] 
then
	mkdir "$builddir"
fi

if [ ! -d "$arcdir" ] 
then
	mkdir "$arcdir"
fi

# Install all prerequisites
cecho "Prerequisites installation" green
apt-get install apache2 libapache2-mod-php5 php5-gd mailutils fping snmp ntp smbclient nmap saidar traceroute php5-snmp curl gettext syslog-ng
apt-get install build-essential
apt-get install libperl-dev libgd2-xpm-dev libltdl3-dev linux-headers-generic
apt-get install  libglib2.0-dev iputils-ping wget tree

# verify updates
# TO DO !!!!!!!!!!

# download (if needed)
if [ ! -f $arcdir/nagios-$nagver.$arcsuffix ]
then
	cecho "Downloding nagios-$nagver.$arcsuffix..." green
	cd $arcdir
	wget $nagdl
fi
# extract the sources
cecho "Extracting the sources..." green
cd $builddir
if [ -d $builddir/nagios-$nagver ]
then
	rm -Rf $builddir/nagios-$nagver
fi
tar zxvf $arcdir/nagios-$nagver.$arcsuffix
cd nagios-$nagver
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while extracting sources !" red
	exit 1
fi

# configuration
cecho "Configuring sources tree..." green
make clean  
make distclean 
./configure --prefix=$prefix --sysconfdir=$etcdir --localstatedir=$vardir --bindir=$bindir --sbindir=$sbindir --libexecdir=$libexecdir --datadir=$vardir/www --libdir=$prefix/lib --with-nagios-user=$naguser --with-nagios-group=$naggroup --with-command-user=$naguser --with-command-group=$nagcmdgroup --enable-event-broker --with-temp-dir=$prefix/temp --enable-nanosleep --enable-embedded-perl --with-perlcache 
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while configuring sources tree !" red
	exit 1
fi

# build
cecho "Building..." green 
make all  
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while building !" red
	exit 1
fi

# installation
cecho "Installation..." green
make install
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while installing !" red
	exit 1
fi

cecho "Installing startup script..." green
make install-init

if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while installing startup script!" red
	exit 1
fi

cecho "Installing command pipe" green
make install-commandmode
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while installing command pipe!" red
	exit 1
fi

cecho "Installing configuration" green
make install-config  
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while installing configuration!" red
	exit 1
fi
cecho "Installing apache configuration" green
make install-webconf  
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while installing apache configuration!" red
	exit 1
fi
# move apache2 config to install dir. This will ease backup because we
# only need to backup the nagios folder
sudo mv $apache2confdir/nagios.conf $prefix/etc/apache2.conf
sudo ln -s $prefix/etc/apache2.conf $apache2confdir/nagios.conf

# additional folders
sudo mkdir -p $prefix/temp

# redemarage des processus
cecho "Starting nagios" green
/etc/init.d/apache2 restart 
update-rc.d nagios defaults 
/etc/init.d/apache2 reload 
/etc/init.d/nagios start 
cecho "nagiosadmin password" green
htpasswd -c -b $prefix/etc/htpasswd.users nagiosadmin $nagiospassword  
