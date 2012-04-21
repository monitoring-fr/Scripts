#!/bin/bash

# environnement
myscripts=$(dirname $0)
cd $myscripts
. ./env.sh

clear
echo "+-------------------------------------------------+" 
echo "|   (c)opyLEFT www.nagios-fr.org 2010 by          |" 
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
echo "|   livestatus on ubuntu server (8.04)            |" 
echo "+-------------------------------------------------+" 
echo "| 2010-03-06 - initial release                    |"
echo "+-------------------------------------------------+" 

# Check if we launch the script with root privileges (aka sudo)
if [ "$UID" != "0" ]
then
	cecho "You should start the script with sudo!" red
	exit 1
fi

# Prerequisites
cecho "Prerequisites installation" green
sudo apt-get install xinetd

# check if sources and build directories are here
if [ ! -d "$builddir" ] 
then
	mkdir "$builddir"
fi

if [ ! -d "$arcdir" ] 
then
	mkdir "$arcdir"
fi
 
# download
if [ ! -f $arcdir/mk-livestatus-$livever.$arcsuffix ]
then
	cecho "Downloading mk-livestatus-$livever.$arcsuffix" green
	cd $arcdir
	wget $livedl
fi

# Extract
cd $builddir
rm -Rf ./mk-livestatus-$livever
cecho "Extracting sources" green
tar zxvf $arcdir/mk-livestatus-$livever.$arcsuffix
cd mk-livestatus-$livever
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while extractring sources !" red
	exit 1
fi

# Prerequisites

# sources tree configuration
cecho "Configuring sources tree..." green
./configure 
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while configuring sources tree !" red
	exit 1
fi

# build
cecho "Building...." green

make
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while building !" red
	exit 1
fi

# install
cecho "Installing...." green
cp $builddir/mk-livestatus-$livever/src/unixcat $prefix/bin/unixcat-$livever
cp $builddir/mk-livestatus-$livever/src/livestatus.o $prefix/bin/livestatus-$livever.o
ln -s $prefix/bin/livestatus-$livever.o $prefix/bin/livestatus.o
ln -s $prefix/bin/unixcat-$livever $prefix/bin/unixcat

ts=$(date +%s)
cp $prefix/etc/nagios.cfg $prefix/etc/nagios.cfg.$ts.old
if [ -z "$(cat $prefix/etc/nagios.cfg | grep livestatus.o)" ]
then 
	echo "broker_module=$prefix/bin/livestatus.o $vardir/rw/live" >> $prefix/etc/nagios.cfg
fi

cecho "Configuring xinetd" green
echo "service livestatus" > /etc/xinetd.d/livestatus
echo "{" >> /etc/xinetd.d/livestatus
echo "	type				= UNLISTED" >> /etc/xinetd.d/livestatus
echo "	port				= ${liveport}" >> /etc/xinetd.d/livestatus
echo "	socket_type			= stream" >> /etc/xinetd.d/livestatus
echo "	protocol			= tcp" >> /etc/xinetd.d/livestatus
echo "	wait				= no" >> /etc/xinetd.d/livestatus
echo "	# limit to 100 connections per second. Disable 3 secs if above." >> /etc/xinetd.d/livestatus
echo "	cps             	= 100 3" >> /etc/xinetd.d/livestatus
echo "	# Disable TCP delay, makes connection more responsive" >> /etc/xinetd.d/livestatus
echo "	flags       		= NODELAY" >> /etc/xinetd.d/livestatus
echo "	user				= ${naguser}" >> /etc/xinetd.d/livestatus
echo "	server				= ${bindir}/unixcat" >> /etc/xinetd.d/livestatus
echo "	server_args     	= ${vardir}/rw/live" >> /etc/xinetd.d/livestatus
echo "	# configure the IP address(es) of your Nagios server here:" >> /etc/xinetd.d/livestatus
echo "	# only_from       	= ${liveallowfrom}" >> /etc/xinetd.d/livestatus
echo "	disable				= no" >> /etc/xinetd.d/livestatus
echo "}" >> /etc/xinetd.d/livestatus
cecho "reloading xinetd" green
/etc/init.d/xinetd reload
# restart nagios
cecho "Restarting nagios...." green
sudo /etc/init.d/nagios restart
