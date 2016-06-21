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

INST=$PWD

echo "delete lib mysqludf_sys.so"
sudo apt-get remove libmysqlclient-dev
sudo rm /usr/lib/mysql/plugin/lib_mysqludf_sys.so
sudo rm /etc/apparmor.d/usr.sbin.mysqld
sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld

mysql -u root -p wordpress < $INST/dropTrigger.sql

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
