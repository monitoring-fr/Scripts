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
echo "|   ndoutils on ubuntu server (8.04)             |" 
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
if [ ! -f $arcdir/ndoutils-$ndover.$arcsuffix ]
then
	cecho "Downloading ndoutils-$ndover.$arcsuffix" green
	cd $arcdir
	wget $ndodl
fi

# Extract
cd $builddir
rm -Rf ./ndoutils-$ndover
cecho "Extracting sources" green
tar zxvf $arcdir/ndoutils-$ndover.$arcsuffix
cd ndoutils-$ndover
if [ "$?" != "0" ]
then 
	cecho "[FATAL] Error while extractring sources !" red
	exit 1
fi
# Prerequisites
cecho "Prerequisites installation" green
sudo apt-get install mysql-server mysql-client libmysql++-dev libmysqlclient15-dev libssl-dev openssl

# sources tree configuration
cecho "Configuring sources tree..." green
./configure --bindir=$prefix/bin --sbindir=$prefix/bin --prefix=$prefix --with-ndo2db-user=$naguser  --with-ndo2db-group=$naggroup --enable-mysql --disable-pgsql --enable-ssl 
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
cecho "  + Creating DB..." green
mysql -h localhost -u ${mysqlroot} -p${mysqlrootpassword} -e "DROP DATABASE IF EXISTS ${ndodbname};"
mysql -h localhost -u ${mysqlroot} -p${mysqlrootpassword} -e "CREATE DATABASE IF NOT EXISTS ${ndodbname};"
mysql -h localhost -u ${mysqlroot} -p${mysqlrootpassword} -D ${ndodbname} -e "GRANT ALL PRIVILEGES ON ${ndodbname}.* TO '${ndouser}'@'${mysqlhost}' IDENTIFIED BY '${ndopassowrd}';";
mysql -h localhost -u ${mysqlroot} -p${mysqlrootpassword} -D ${ndodbname} -e "FLUSH PRIVILEGES;";
mysql -h localhost -u ${mysqlroot} -p${mysqlrootpassword} -D ${ndodbname} < db/mysql.sql
cecho "  + Moving Files..." green
cp src/ndomod-3x.o $prefix/bin/ndomod.o
cp src/ndo2db-3x $prefix/bin/ndo2db
cp src/sockdebug $prefix/bin/
cp src/log2ndo $prefix/bin/
cp src/file2sock $prefix/bin/
cat config/ndo2db.cfg-sample | sed -e "s/ndouser/${ndouser}/" | sed -e "s/ndopassword/${ndopassowrd}/" > $prefix/etc/ndo2db.cfg
cp config/ndomod.cfg-sample $prefix/etc/ndomod.cfg
cp daemon-init /etc/init.d/ndo2db
chmod +x /etc/init.d/ndo2db
update-rc.d ndo2db defaults

if [ -z "$( cat $prefix/etc/nagios.cfg | grep "ndomod.o" | grep -v \"^#\")" ]
then
	echo broker_module="$prefix/bin/ndomod.o config_file=$prefix/etc/ndomod.cfg" >> $prefix/etc/nagios.cfg
fi
cecho "  + Fixing owner..." green
sudo chown $naguser:$naggroup  $prefix/bin/ndomod.o
sudo chown $naguser:$naggroup  $prefix/bin/ndo2db
sudo chown $naguser:$naggroup  $prefix/bin/sockdebug
sudo chown $naguser:$naggroup  $prefix/bin/file2sock
sudo chown $naguser:$naggroup  $prefix/etc/ndo2db.cfg
sudo chown $naguser:$naggroup  $prefix/etc/ndomod.cfg
cecho "starting ndo2db" green
/etc/init.d/ndo2db start
