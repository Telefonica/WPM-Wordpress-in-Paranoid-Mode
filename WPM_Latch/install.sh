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

# Commands that are mandatory for WPM operation:
which_cmd CP_CMD cp
which_cmd SED_CMD sed
which_cmd GIT_CMD git
which_cmd LN_CMD ln
which_cmd GCC_CMD gcc
which_cmd MYSQL_CMD mysql
which_cmd APPARMOR_CMD apparmor_parser
which_cmd RUBY_CMD ruby

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
echo >&2 "Go to Install? [ ENTER ]" 
read enter

"${CP_CMD}" "${INST}"/token_template.rb "${INST}"/token.rb
"${SED_CMD}" -i "s|%APPID%|$1|g" "${INST}"/token.rb 
"${SED_CMD}" -i "s|%SECRET%|$2|g" "${INST}"/token.rb

"${CP_CMD}" "${INST}"/operations_template.rb "${INST}"/operations.rb
"${SED_CMD}" -i "s|%APPID%|$1|g" "${INST}"/operations.rb
"${SED_CMD}" -i "s|%SECRET%|$2|g" "${INST}"/operations.rb

echo >&2
echo >&2 "Step 1: Pairing with Latch"
echo >&2 "=========================="
echo >&2
echo -n "Give me token:"
read token
echo >&2
echo >&2 "Pairing..."
temp=$("${RUBY_CMD}" "${INST}"/token.rb $token)
if [ $? -eq 0 ]
then
	ACCOUNTID="${temp}"
	echo >&2
	echo "Account ID: "${ACCOUNTID}". "
	echo >&2
else
	echo >&2
	echo "Error: Account ID Invalid"
	echo >&2
	exit 1
fi

echo >&2
echo >&2 "Step 2: Creating Ruby files for Latch operations"
echo >&2 "================================================"
echo >&2
echo >&2 "Copying comment_template.rb to comment.rb"
"${CP_CMD}" "${INST}"/comment_template.rb "${INST}"/comment.rb
"${SED_CMD}" -i "s/%APPID%/$APPID/g" "${INST}"/comment.rb
"${SED_CMD}" -i "s/%SECRET%/$SECRET/g" "${INST}"/comment.rb
"${SED_CMD}" -i "s/%ACCOUNTID%/$ACCOUNTID/g" "${INST}"/comment.rb
"${SED_CMD}" -i "s|%LATCH%|$INST|g" "${INST}"/comment.rb
echo >&2 "Copying post_template.rb to post.rb"
"${CP_CMD}" "${INST}"/post_template.rb "${INST}"/post.rb
"${SED_CMD}" -i "s/%APPID%/$APPID/g" "${INST}"/post.rb
"${SED_CMD}" -i "s/%SECRET%/$SECRET/g" "${INST}"/post.rb
"${SED_CMD}" -i "s/%ACCOUNTID%/$ACCOUNTID/g" "${INST}"/post.rb
"${SED_CMD}" -i "s|%LATCH%|$INST|g" "${INST}"/post.rb
echo >&2 "Copying users_template.rb to users.rb"
"${CP_CMD}" "${INST}"/users_template.rb "${INST}"/users.rb
"${SED_CMD}" -i "s/%APPID%/$APPID/g" "${INST}"/users.rb
"${SED_CMD}" -i "s/%SECRET%/$SECRET/g" "${INST}"/users.rb
"${SED_CMD}" -i "s/%ACCOUNTID%/$ACCOUNTID/g" "${INST}"/users.rb
"${SED_CMD}" -i "s|%LATCH%|$INST|g" "${INST}"/users.rb

echo >&2 
echo >&2 "Step 3: Create Operations"
echo >&2 "========================="
echo >&2
echo >&2 "Creating ReadOnly Operation..."
echo >&2
com=$("${RUBY_CMD}" "${INST}"/operations.rb ReadOnly)

if [ $? -eq 0 ]
then
	COMMENT=$com
	echo $COMMENT
	"${SED_CMD}" -i "s/%COMMENT%/$COMMENT/g" "${INST}"/comment.rb
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
pos=$("${RUBY_CMD}" "${INST}"/operations.rb Edition)

if [ $? -eq 0 ]
then
	POST=$pos
	echo $POST
	"${SED_CMD}" -i "s/%POST%/$POST/g" "${INST}"/post.rb
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
user=$("${RUBY_CMD}" "${INST}"/operations.rb Administration)

if [ $? -eq 0 ]
then
	USERS=$user
	echo $USERS
	"${SED_CMD}" -i "s/%USERS%/$USERS/g" "${INST}"/users.rb
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

# Install libmysqlclient-dev
if [ "${OS}" = "Debian" ];
then
	apt-get install libmysqlclient-dev
else
	yum install libmysqlclient-dev
fi

"${GIT_CMD}" clone https://github.com/mysqludf/lib_mysqludf_sys.git
cd "${INST}"/lib_mysqludf_sys/
"${GCC_CMD}" -fPIC -Wall -I/usr/include/mysql -I. -shared lib_mysqludf_sys.c -o /usr/lib/mysql/plugin/lib_mysqludf_sys.so

echo >&2 "MySQL: Ingress password"
"${MYSQL_CMD}" -h localhost -u root -p < lib_mysqludf_sys.sql

echo >&2
echo >&2 "Step 5: AppArmor Configuration"
echo >&2 "=============================="
echo >&2
cd /etc/apparmor.d/
"${LN_CMD}" -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
"${APPARMOR_CMD}" -R /etc/apparmor.d/usr.sbin.mysqld
echo >&2 "Reboot MySQL, if this fail, you need reboot MySQL"
/etc/init.d/mysql restart
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
echo >&2 "Database:"
read DATABASE
"${CP_CMD}" "${INST}"/proof_template.sql "${INST}"/proof.sql
"${SED_CMD}" -i "s|%PATH%|$INST|g" "${INST}"/proof.sql
"${SED_CMD}" -i "s|%DATABASE%|$DATABASE|g" "${INST}"/proof.sql

"${MYSQL_CMD}" -u root -p "${DATABASE}" < "${INST}"/proof.sql

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

