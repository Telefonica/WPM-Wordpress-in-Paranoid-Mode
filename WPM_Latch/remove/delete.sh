#!/bin/bash

INST=$PWD

echo "delete lib mysqludf_sys.so"
sudo apt-get remove libmysqlclient-dev
sudo rm /usr/lib/mysql/plugin/lib_mysqludf_sys.so
sudo rm /etc/apparmor.d/usr.sbin.mysqld
sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld

mysql -u root -p wordpress < $INST/dropTrigger.sql
if [ $? -eq 0 ]
then
        echo "Success! Triggers removed!"
else
        echo "Error!"
        exit
fi
