#!/bin/bash

######################
## SETTINGS
# TODO SQL_FILE_NAME get by param

ERRORMSG='script: Somthing goes wrong'
HOME_USER=$(eval echo ~${SUDO_USER})
DB_LATEST=${HOME_USER}'/'${SQL_FILE_NAME}

######################
## FUNCTIONS
usage()
{
cat << EOF
usage: `basename $0` options
   -h      for this message
   -n      local dbname
   -s      local dbuser
   -p      local dbpass
   -d      main part of domain () # todo add exmaple

Check script code for more details
EOF
}


install_db() {
  # if last exit code was OK (equal zero)
  if [ $? -eq 0 ]; then
    if [ -f ${DB_LATEST} ]; then
      echo [3/4] Installing on host.. `hostname`
      zcat ${DB_LATEST} | pv -cN zcat | mysql ${DBNAME} --user=${DBUSER} --password=${DBPASS};
    else 
      echo "File not found: ${DB_LATEST}"
      exit 
    fi
  else
    echo ${ERRORMSG}
    exit 40
  fi
}

######################
## CHECK OPTIONS
while getopts “hn:s:p:d:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         n) # local dbname
             DBNAME=$OPTARG
             ;;
         s) # local dbuser
             DBUSER=$OPTARG
             ;;
         p) # local dbpass
             DBPASS=$OPTARG
             ;;
         d) # clean main part of domain 
             DOMAIN=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $DBNAME ]] || [[ -z $DBUSER ]] || [[ -z $DBPASS ]] || [[ -z $DOMAIN ]]
then
     usage
     exit 1
fi


######################
## MAIN SCRIPT
install_db ${DBNAME} ${DBUSER} ${DBPASS} ${ERRORMSG}
mysql--general-cleanup.sh -d ${DOMAIN} -u ${DBUSER} -p ${DBPASS} -n ${DBNAME}  # todo refactor file

if [ $? -eq 0 ]; then
  echo 'done'
else
  echo ${ERRORMSG}
  exit 13
fi
