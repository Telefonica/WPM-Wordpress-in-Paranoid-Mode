#!/bin/bash

ACCOUNTID=""
APPID=""
SECRET=""
COMMENT=""
POST=""
USERS=""
INST=$PWD

# Make sure only root can run us.
if [ ! "${UID}" = 0 ]
then
	echo >&2
	echo >&2
	echo >&2 "Only user root can run WPM."
	echo >&2
	exit 1
fi

if [ $# -ne 2 ]
then
	echo "Usage: ./install.sh <APPID> <SECRET>"
	exit
fi

APPID=$1
SECRET=$2

echo -e "\e[34m"
echo -e " ▄█     █▄     ▄███████▄   ▄▄▄▄███▄▄▄▄   "
echo -e "███     ███   ███    ███ ▄██▀▀▀███▀▀▀██▄ "
echo -e "███     ███   ███    ███ ███   ███   ███ "
echo -e "███     ███   ███    ███ ███   ███   ███ "
echo -e "███     ███ ▀█████████▀  ███   ███   ███ "
echo -e "███     ███   ███        ███   ███   ███ "
echo -e "███ ▄█▄ ███   ███        ███   ███   ███ "
echo -e " ▀███▀███▀   ▄████▀       ▀█   ███   █▀  "

echo
echo
echo -e "\e[96mWordpress in Paranoid Mode with Latch"
echo -e "Chema Alonso & Pablo González @elevenpaths"
echo -e "\e[39m"


echo
echo
echo "Go to Install? ENTER..."
read enter

cp $INST/token_template.rb $INST/token.rb
sed -i "s|%APPID%|$1|g" $INST/token.rb 
sed -i "s|%SECRET%|$2|g" $INST/token.rb

cp $INST/operations_template.rb $INST/operations.rb
sed -i "s|%APPID%|$1|g" $INST/operations.rb
sed -i "s|%SECRET%|$2|g" $INST/operations.rb

echo
echo "Step 1: Pairing with Latch"
echo "=========================="
echo
echo -n "Give me token:"
read token
echo
echo "Pairing..."
temp=$(ruby token.rb $token)
if [ $? -eq 0 ]
then
	ACCOUNTID=$temp
	echo "Account ID: $ACCOUNTID"
else
	echo "Error: Account ID Invalid"
	exit
fi

echo
echo "Step 2: Creating Ruby files for Latch operations"
echo "================================================"
echo
echo "Copying comment_template.rb to comment.rb"
cp comment_template.rb comment.rb
sed -i "s/%APPID%/$APPID/g" comment.rb
sed -i "s/%SECRET%/$SECRET/g" comment.rb
sed -i "s/%ACCOUNTID%/$ACCOUNTID/g" comment.rb
sed -i "s|%LATCH%|$INST|g" comment.rb
echo "Copying post_template.rb to post.rb"
cp post_template.rb post.rb
sed -i "s/%APPID%/$APPID/g" post.rb
sed -i "s/%SECRET%/$SECRET/g" post.rb
sed -i "s/%ACCOUNTID%/$ACCOUNTID/g" post.rb
sed -i "s|%LATCH%|$INST|g" post.rb
echo "Copying users_template.rb to users.rb"
cp users_template.rb users.rb
sed -i "s/%APPID%/$APPID/g" users.rb
sed -i "s/%SECRET%/$SECRET/g" users.rb
sed -i "s/%ACCOUNTID%/$ACCOUNTID/g" users.rb
sed -i "s|%LATCH%|$INST|g" users.rb

echo 
echo "Step 3: Create Operations"
echo "========================="
echo
echo "Creating ReadOnly Operation..."
echo
com=$(ruby operations.rb ReadOnly)

if [ $? -eq 0 ]
then
	COMMENT=$com
	echo $COMMENT
	sed -i "s/%COMMENT%/$COMMENT/g" comment.rb
else
	echo "Error: Not Operation"
	exit
fi

echo
echo
echo "Creating Edition Operation..."
echo
pos=$(ruby operations.rb Edition)

if [ $? -eq 0 ]
then
	POST=$pos
	echo $POST
	sed -i "s/%POST%/$POST/g" post.rb
else
	echo "Error: Not Operation"
	exit
fi

echo
echo
echo "Creating Administration Operation"
echo
user=$(ruby operations.rb Administration)

if [ $? -eq 0 ]
then
	USERS=$user
	echo $USERS
	sed -i "s/%USERS%/$USERS/g" users.rb
else
	echo "Error: Not Operation"
	exit
fi

echo 
echo "Step 4: Setup lib mysql udf so"
echo "=============================="
echo
sudo apt-get install libmysqlclient-dev
git clone https://github.com/mysqludf/lib_mysqludf_sys.git
cd lib_mysqludf_sys/
sudo gcc -fPIC -Wall -I/usr/include/mysql -I. -shared lib_mysqludf_sys.c -o /usr/lib/mysql/plugin/lib_mysqludf_sys.so
mysql -u root -p < lib_mysqludf_sys.sql

echo
echo "Step 5: AppArmor Configuration"
echo "=============================="
echo
cd /etc/apparmor.d/
sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld
echo "Reboot MySQL, if this fail, you need reboot MySQL"
sudo /etc/init.d/mysql restart
if [ $? -ne 0 ]
then
	echo "Reboot manually MySQL"
fi

echo 
echo "Step 6: Creating Triggers on MySQL"
echo "=================================="
echo
cp $INST/proof_template.sql $INST/proof.sql
sed -i "s|%PATH%|$INST|g" $INST/proof.sql
mysql -u root -p wordpress < $INST/proof.sql
if [ $? -eq 0 ]
then
	echo "Success! Triggers on MySQL"
else
	echo "Error: MySQL Triggers"
	exit
fi

