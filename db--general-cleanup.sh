#!/bin/bash

###
# General scirpt for cleaning DB. Setting up proper local domains.
###


## SETTINGS
BACKOFFICE_NAME='back';

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)

# Absolute path this script is in. /home/user/bin
SCRIPTPATH=`dirname $SCRIPT`


## FUNCTIONS
usage()
{
cat << EOF
usage: `basename $0` options

This script cleanup db db after importing.

OPTIONS:
   -h      Show this message
   -d      Domain last part
   -u      Local DB user
   -p      Local DB password
   -n      Local DB name
   -b      Backoffice name (default: "back")
   
I.E.:
 `basename $0` -d .asdf -u user_name -p secret_password -n db_local
EOF
}


## CHECK OPTIONS
while getopts “hd:u:p:b:n:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         d)
             DOMAIN=$OPTARG
             ;;
         u)
             DBUSER=$OPTARG
             ;;
         p)
             DBPASS=$OPTARG
             ;;
         n)
             DBNAME=$OPTARG
             ;;
         b)
             BACKOFFICE_NAME=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $DOMAIN ]] || [[ -z $DBUSER ]] || [[ -z $DBPASS ]] || [[ -z $DBNAME ]]
then
  usage
  exit 1
fi


## SCRIPT

# change dir where sql file exist
cd $SCRIPTPATH

# check cleanup sql file exist
if [ ! -e ./db--general-cleanup.sql ]; then 
  echo "ERROR: Missing db-general-cleanup.sql file"; 
  exit 1;
else
  SQL=./db--general-cleanup.sql;
fi

# prepare regexp to change in sql file
DOMAIN_REGEXP="s/=DOMAIN=/${DOMAIN}/g"
SERIALIZE_LENGHT=$( expr `echo -n ${DOMAIN} | wc -c` + `echo -n ${BACKOFFICE_NAME} | wc -c` ) # count lenght of domain
SER_REGEXP="s/=SERIALIZE_LENGHT=/${SERIALIZE_LENGHT}/g"
BACKOFFICE_EXP="s/=BACKOFFICE_NAME=/${BACKOFFICE_NAME}/g"

# .. change it!
PREPARED_SQL=$(sed ${DOMAIN_REGEXP} ${SQL} | sed ${SER_REGEXP} | sed ${BACKOFFICE_EXP})

# show user to confirm
echo '==============================================================='
echo "$PREPARED_SQL"
echo '==============================================================='
echo
echo -n 'Looks ok? [Y/n]: '
read ANSWER
ANSWER=${ANSWER,,} # string to lower

# .. check answer
if [ "${ANSWER}" == "y" ] || [ -z $ANSWER ]
then
  echo 'Running clean-up script..'
elif [ $ANSWER == "n" ]
then
  echo 'No means no'
  exit 2;
fi

# apply cleanup script
echo "$PREPARED_SQL" | mysql -u${DBUSER} -p${DBPASS}  ${DBNAME};

# if last exit code was OK (equal zero)
if [ $? -eq 0 ]; then
  echo 'Cleaning DB done'
fi
