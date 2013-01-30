#!/bin/bash

#todo - get latest db file to remove DB_FILE_NAME_TO_REMOVE

## FUNCTIONS
usage()
{
cat << EOF
usage: `basename $0` options

This script cleanup db db after importing.

OPTIONS:
   -h      Show this message
   -u      Live server user
   -l      Live host; hostname or IP address
   
EOF
}

remove_old_db() {
  echo [1/4] removing old latest..
  rm -rf {$pathtodo}/{$DB_FILE_NAME_TO_REMOVE}
}

copy_new_db() {
  USER=$1; # todo get as param
  LIVE=$2; # todo get as param
  # if last exit code was OK (equal zero)
  echo "[2/4] Coping from LIVE.. (${USER}@${LIVE}:/home/backup/db_latest.sql.gz ~)"
  scp ${USER}@${LIVE}:{$fullpathfromwhere} {$fullpathwhereTO}
}



## CHECK OPTIONS
while getopts “hu:l:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         u)
             USER=$OPTARG
             ;;
         l)
             LIVE=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $USER ]] || [[ -z $LIVE ]]
then
     usage
     exit 1
fi



## MAIN SCRIPT
remove_old_db;
copy_new_db $USER $LIVE;
