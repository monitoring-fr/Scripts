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
echo "|   nagios plugins on ubuntu server (8.04)        |" 
echo "+-------------------------------------------------+" 
echo "| 2010-03-06 - initial release                    |"
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
 
# download
if [ ! -f $arcdir/nagios-plugins-$plugver.$arcsuffix ]
then
	cecho "Downloading nagios-plugins-$plugver.$arcsuffix" green
	cd $arcdir
	wget $plugdl
fi

# Extract
cd $builddir
rm -Rf ./nagios-plugins-$plugver
cecho "Extracting sources" green
tar zxvf $arcdir/nagios-plugins-$plugver.$arcsuffix
cd nagios-plugins-$plugver
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while extractring sources !" red
	exit 1
fi

# Prerequisites
cecho "Prerequisites installation" green
sudo apt-get install mysql-client

# sources tree configuration
cecho "Configuring sources tree..." green
./configure --prefix=$prefix --libexecdir=$prefix/libexec --with-nagios-user=$naguser --with-nagios-group=$naggroup --enable-libtap --enable-extra-opts --enable-perl-modules
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
cecho "Installing..." green
sudo make install
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while installing !" red
	exit 1
fi