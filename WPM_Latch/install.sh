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
	echo >&2
	echo >&2
	echo >&2 "Usage: ./install.sh <APPID> <SECRET>"
	echo >&2
	exit 1
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

# Commands that are mandatory for WPM operation:
which_cmd CP_CMD cp
which_cmd SED_CMD sed
which_cmd LN_CMD ln
which_cmd MYSQL_CMD mysql

APPID=$1
SECRET=$2

echo >&2
echo -e "\e[34m"
echo -e "  ▄█     █▄     ▄███████▄   ▄▄▄▄███▄▄▄▄   "
echo -e " ███     ███   ███    ███ ▄██▀▀▀███▀▀▀██▄ "
echo -e " ███     ███   ███    ███ ███   ███   ███ "
echo -e " ███     ███   ███    ███ ███   ███   ███ "
echo -e " ███     ███ ▀█████████▀  ███   ███   ███ "
echo -e " ███     ███   ███        ███   ███   ███ "
echo -e " ███ ▄█▄ ███   ███        ███   ███   ███ "
echo -e "  ▀███▀███▀   ▄████▀       ▀█   ███   █▀  "
echo >&2
echo >&2
echo -e "\e[96m WordPress in Paranoid Mode with Latch."
echo -e " Chema Alonso & Pablo González @elevenpaths"
echo -e "\e[39m"
echo >&2
echo "Go to Install? ENTER..."
read enter

"${CP_CMD}" $INST/token_template.rb $INST/token.rb
"${SED_CMD}" -i "s|%APPID%|$1|g" $INST/token.rb 
"${SED_CMD}" -i "s|%SECRET%|$2|g" $INST/token.rb

"${CP_CMD}" $INST/operations_template.rb $INST/operations.rb
"${SED_CMD}" -i "s|%APPID%|$1|g" $INST/operations.rb
"${SED_CMD}" -i "s|%SECRET%|$2|g" $INST/operations.rb

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
	echo >&2
	echo "Account ID: $ACCOUNTID"
	echo >&2
else
	echo >&2
	echo "Error: Account ID Invalid"
	echo >&2
	exit 1
fi

echo
echo "Step 2: Creating Ruby files for Latch operations"
echo "================================================"
echo
echo "Copying comment_template.rb to comment.rb"
"${CP_CMD}" comment_template.rb comment.rb
"${SED_CMD}" -i "s/%APPID%/$APPID/g" comment.rb
"${SED_CMD}" -i "s/%SECRET%/$SECRET/g" comment.rb
"${SED_CMD}" -i "s/%ACCOUNTID%/$ACCOUNTID/g" comment.rb
"${SED_CMD}" -i "s|%LATCH%|$INST|g" comment.rb
echo >&2 "Copying post_template.rb to post.rb"
"${CP_CMD}" post_template.rb post.rb
"${SED_CMD}" -i "s/%APPID%/$APPID/g" post.rb
"${SED_CMD}" -i "s/%SECRET%/$SECRET/g" post.rb
"${SED_CMD}" -i "s/%ACCOUNTID%/$ACCOUNTID/g" post.rb
"${SED_CMD}" -i "s|%LATCH%|$INST|g" post.rb
echo >&2 "Copying users_template.rb to users.rb"
"${CP_CMD}" users_template.rb users.rb
"${SED_CMD}" -i "s/%APPID%/$APPID/g" users.rb
"${SED_CMD}" -i "s/%SECRET%/$SECRET/g" users.rb
"${SED_CMD}" -i "s/%ACCOUNTID%/$ACCOUNTID/g" users.rb
"${SED_CMD}" -i "s|%LATCH%|$INST|g" users.rb

echo >&2 
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
	"${SED_CMD}" -i "s/%COMMENT%/$COMMENT/g" comment.rb
else
	echo >&2
	echo "Error: Not Operation."
	echo >&2
	exit 1
fi

echo >&2
echo >&2
echo >&2 "Creating Edition Operation..."
echo >&2
pos=$(ruby operations.rb Edition)

if [ $? -eq 0 ]
then
	POST=$pos
	echo $POST
	"${SED_CMD}" -i "s/%POST%/$POST/g" post.rb
else
	echo >&2
	echo >&2 "Error: Not Operation."
	echo >&2
	exit 1
fi

echo >&2
echo >&2
echo >&2 "Creating Administration Operation"
echo >&2
user=$(ruby operations.rb Administration)

if [ $? -eq 0 ]
then
	USERS=$user
	echo $USERS
	"${SED_CMD}" -i "s/%USERS%/$USERS/g" users.rb
else
	echo >&2
	echo >&2 "Error: Not Operation."
	echo >&2
	exit 1
fi

echo >&2 
echo >&2 "Step 4: Setup lib mysql udf so"
echo >&2 "=============================="
echo >&2
sudo apt-get install libmysqlclient-dev
git clone https://github.com/mysqludf/lib_mysqludf_sys.git
cd lib_mysqludf_sys/
sudo gcc -fPIC -Wall -I/usr/include/mysql -I. -shared lib_mysqludf_sys.c -o /usr/lib/mysql/plugin/lib_mysqludf_sys.so
mysql -u root -p < lib_mysqludf_sys.sql

echo >&2
echo >&2 "Step 5: AppArmor Configuration"
echo >&2 "=============================="
echo >&2
cd /etc/apparmor.d/
sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld
echo "Reboot MySQL, if this fail, you need reboot MySQL"
sudo /etc/init.d/mysql restart
if [ $? -ne 0 ]
then
	echo >&2
	echo >&2
	echo "IMPORTANT: Reboot manually MySQL"
	echo >&2
fi

echo >&2 
echo >&2 "Step 6: Creating Triggers on MySQL"
echo >&2 "=================================="
echo >&2
"${CP_CMD}" $INST/proof_template.sql $INST/proof.sql
"${SED_CMD}" -i "s|%PATH%|$INST|g" $INST/proof.sql

mysql -u root -p wordpress < $INST/proof.sql

if [ $? -eq 0 ]
then
	echo >&2
	echo "Success! Triggers on MySQL."
	echo >&2
	exit 0
else
	echo >&2
	echo "Error: MySQL Triggers."
	echo >&2
	exit 1
fi

