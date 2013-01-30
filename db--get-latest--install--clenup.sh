#!/bin/bash

######################
## SETTINGS
ERRORMSG='script: Somthing goes wrong'

######################
## FUNCTIONS
usage()
{
cat << EOF
usage: `basename $0` options
   -h      for this message
   -u      live host username
   -l      live hostname domain or IP
   -n      local dbname
   -s      local dbuser
   -p      local dbpass
   -d      main part of domain (TODO EXAMPLE)

Check script code for more details
EOF
}

install_db() {
  #$DBNAME=$1;
  #$DBUSER=$2;
  #$DBPASS=$3;
  #$ERRORMSG=$4;
  
  # if last exit code was OK (equal zero)
  if [ $? -eq 0 ]; then
    echo [3/4] Installing on host.. `hostname`
    # todo check in the beginning do we have all commands avaible (and maybe versions)
    zcat ~/db_latest.sql.gz | pv -cN zcat | mysql ${DBNAME} --user=${DBUSER} --password=${DBPASS};
  else
    echo ${ERRORMSG}
    exit 11
  fi
}

######################
## CHECK OPTIONS
while getopts “hu:l:n:s:p:d:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         u) # live username
             USER=$OPTARG
             ;;
         l) # live hostname
             LIVE=$OPTARG
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

if [[ -z $USER ]] || [[ -z $LIVE ]] || [[ -z $DBNAME ]] || [[ -z $DBUSER ]] || [[ -z $DBPASS ]] || [[ -z $DOMAIN ]]
then
     usage
     exit 1
fi


######################
## MAIN SCRIPT
db--remove-old-get-latest-db.sh -u ${USER} -l ${LIVE}
install_db ${DBNAME} ${DBUSER} ${DBPASS} ${ERRORMSG}
db--general-cleanup.sh -d ${DOMAIN} -u ${DBUSER} -p ${DBPASS} -n ${DBNAME}

if [ $? -eq 0 ]; then
  echo 'done'
else
  echo ${ERRORMSG}
  exit 13
fi
