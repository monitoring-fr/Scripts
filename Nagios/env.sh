#! /bin/bash
#################################################################################
# Configuration file for install scripts
#################################################################################
# Author : David GUENAULT (david.guenault AT monitoring-fr DOT org)
# Copyleft : 2010 - Communauté monitoring francophone
# The scripts are all released under the GNU Public License V2.
#################################################################################

# users and passwords
export naguser=nagios
export naggroup=nagios
export adminuser=system
export nagcmdgroup=nagcmd
export apacheuser=www-data
export nagiospassword=manager

# mysql specific for ndo
export mysqlroot=root
export mysqlrootpassword=manager
export mysqlhost=localhost
export ndouser=system
export ndopassowrd=manager
export ndodbname=nagios

# only used for livestatus TCP access 
export liveallowfrom="127.0.0.1 192.168.0.11"
export liveport="6557"

#versions
export nagver=3.2.1
export plugver=1.4.14
export livever=1.1.3
export ndobranch=1.x
export ndover=1.4b9

export nagscript=/etc/init.d/nagios

# layout definition
export prefix=/opt/monitor
export vardir=$prefix/var
export etcdir=$prefix/etc
export bindir=$prefix/bin
export sbindir=$prefix/sbin
export libexecdir=$prefix/libexec
export basedir=$(pwd)
export arcdir=$basedir/sources
export builddir=$basedir/build
export tmpdir=$basedir/tmp

# url for downloads
export baseurlnagios=http://freefr.dl.sourceforge.net/sourceforge/nagios
export baseurlnagiosplugins=http://freefr.dl.sourceforge.net/sourceforge/nagiosplug
export baseurllive=http://mathias-kettner.de/download
export baseurlndo=http://downloads.sourceforge.net/project/nagios/ndoutils-${ndobranch}

# suffixe des archives
export arcsuffix=tar.gz

# apache2 configuration directory
export apache2confdir=/etc/apache2/conf.d

# download urls
export nagdl=$baseurlnagios/nagios-$nagver.$arcsuffix
export plugdl=${baseurlnagiosplugins}/nagios-plugins-$plugver.$arcsuffix
export livedl=${baseurllive}/mk-livestatus-${livever}.tar.gz
export ndodl=${baseurlndo}/ndoutils-${ndover}/ndoutils-${ndover}.tar.gz?use_mirror=freefr

### colorisation de texte dans un script bash ###
cecho ()                    
{

	# Argument $1 = message
	# Argument $2 = foreground color
	# Argument $3 = background color

	case "$2" in
		"black")
			fcolor='30'
			;;
		"red")
			fcolor='31'
			;;
		"green")
			fcolor='32'
			;;
		"yellow")
			fcolor='33'
			;;
		"blue")
			fcolor='34'
			;;
		"magenta")
			fcolor='35'
			;;
		"cyan")
			fcolor='36'
			;;
		"white")
			fcolor='37'
			;;
		*)
			fcolor=''
	esac	
	case "$3" in
		"black")
			bcolor='40'
			;;
		"red")
			bcolor='41'
			;;
		"green")
			bcolor='42'
			;;
		"yellow")
			bcolor='43'
			;;
		"blue")
			bcolor='44'
			;;
		"magenta")
			bcolor='45'
			;;
		"cyan")
			bcolor='46'
			;;
		"white")
			bcolor='47'
			;;
		*)
			bcolor=""
	esac	

	if [ -z $bcolor ]
	then
		echo -ne "\E["$fcolor"m"$1"\n"
	else
		echo -ne "\E["$fcolor";"$bcolor"m"$1"\n"
	fi
	tput sgr0
	return
}
