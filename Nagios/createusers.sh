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
echo "|   This script just create the necessarie users  |" 
echo "|   and groups for nagios                         |" 
echo "+-------------------------------------------------+" 
echo "| 2010-03-05 - initial release                    |"
echo "+-------------------------------------------------+" 

# Check if we launch the script with root privileges (aka sudo)
if [ "$UID" != "0" ]
then
	cecho "You should start the script with sudo!" red
	exit 1
fi

cecho "Création des utilisateurs et groupes" green 
sudo groupadd -g 9000 $naguser 
sudo groupadd -g 9001 $nagcmdgroup
sudo useradd -u 9000 -m -g $naggroup -G $nagcmdgroup -d ${prefix} -c "Nagios Admin" $naguser
sudo adduser $apacheuser $nagcmdgroup 
sudo adduser $adminuser $naggroup
sudo adduser $adminuser $nagcmdgroup 

