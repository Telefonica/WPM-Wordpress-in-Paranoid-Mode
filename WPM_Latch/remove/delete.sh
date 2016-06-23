#!/bin/bash

# Make sure only root can run us.
if [ ! "${UID}" = 0 ]
then
	echo >&2
	echo >&2
	echo >&2 "Only user root can run Uninstall WPM."
	echo >&2
	exit 1
fi

### Getting OS Information
if [ -f /etc/lsb-release ]; 
then
	. /etc/lsb-release
	DIST=$DISTRIB_ID
	DIST_VER=$DISTRIB_RELEASE
else
	DIST="Unknown"
	DIST_VER="Unknown"
fi
if [ -f /etc/debian_version ]; 
then
	OS="Debian"
	VER=$(cat /etc/debian_version)
elif [ -f /etc/redhat-release ]; 
then
	OS="Red Hat"
	VER=$(cat /etc/redhat-release)
elif [ -f /etc/SuSE-release ]; 
then
	OS="SuSE"
	VER=$(cat /etc/SuSE-release)
else
	OS=$(uname -s)
	VER=$(uname -r)
fi

which_cmd() {
	local block=1
	if [ "a${1}" = "a-n" ]
	then
		local block=0
		shift
	fi

	unalias $2 >/dev/null 2>&1
	local cmd=`which $2 2>/dev/null | head -n 1`
	if [ $? -gt 0 -o ! -x "${cmd}" ]
	then
		if [ ${block} -eq 1 ]
		then
			echo >&2
			echo >&2 "ERROR:	Command '$2' not found in the system path."
			echo >&2 "	WPM requires this command for its operation."
			echo >&2 "	Please install the required package and retry."
			echo >&2
			echo >&2 "	which $2"
			exit 1
		fi
		return 1
	fi
	
	eval $1=${cmd}
	return 0
}

INST=$PWD

# Commands that are mandatory for WPM operation:
which_cmd RM_CMD rm
which_cmd APPARMOR_CMD apparmor_parser
which_cmd MYSQL_CMD mysql

echo >&2
echo >&2
echo >&2 "Delete lib mysqludf_sys.so..."
echo >&2
# Uninstall libmysqlclient-dev
if [ "${OS}" = "Debian" ];
then
	apt-get remove libmysqlclient-dev
else
	yum remove libmysqlclient-dev
fi
"${RM_CMD}" /usr/lib/mysql/plugin/lib_mysqludf_sys.so
"${RM_CMD}" /etc/apparmor.d/usr.sbin.mysqld
"${APPARMOR_CMD}" -R /etc/apparmor.d/usr.sbin.mysqld

echo >&2 "MySQL: Ingress Database:"
read DATABASE
echo >&2 "MySQL: Ingress password:"
"${MYSQL_CMD}" -h localhost -u root -p "${DATABASE}" < "${INST}"/dropTrigger.sql

if [ $? -eq 0 ]
then
	echo >&2
	echo >&2
	echo "Success! Triggers removed!"
	echo >&2
	exit 0
else
	echo >&2
	echo >&2
	echo "Error!"
	echo >&2
	exit 1
fi
