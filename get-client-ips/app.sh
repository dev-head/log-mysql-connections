#!/usr/bin/env bash

#
# This script is used to generate a log file of unique ip|hosts that have connected to
# the configured mysql server.
#

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions

## ------------------------------------------------------------------- ##

# Load in common CI functions
CWD=`dirname $0`
if [[ ! -f "$CWD/functions.sh" ]]; then
    echo "[ERROR]::[FAILED TO LOAD]::[$CWD/functions.sh]"
    exit 1
fi
source $CWD/functions.sh

## ------------------------------------------------------------------- ##

read -r -d '' MESSAGE <<- EOM
--------[  ]------------------------------------------------------------

Usage: $0 [options]
OPTIONS: (*required)
    -c  | --config )                Set path to the database conf file.
    -l  | --log )                   Set path to log file.
    -#  | --debug )                 Enable debug output
    -h  | --help )                  Show this message

Example
-------
./get-client-ips/app.sh --debug --config="config/test.conf" --log="log/my-database.log"

Example Config
--------------
[client]
user = root
password = password
host = 127.0.0.1
port = 3306
-----------------------------------------------------------------------------------
EOM

LOG_PREFIX="[${0}]"
DB_CLIENT=$(which mysql)
DEBUG=false
HELP=false
IFS=$' '
DB_CLIENT_CONN=''
DB_CONFIG="${CWD}/../config/test.conf"
PROCESS_IPS_FOUND=''
PROCESS_LIST=''
LOG_FILE="${CWD}/../log/get-client-ips.log"

## ------------------------------------------------------------------- ##

cleanup() { debug "[cleanup()]"; }
usage() { log "${MESSAGE}" 1>&2; exit 0; }
debugDefaultVars() {
    debug "[PROCESS_LIST]::[${PROCESS_LIST}]"
    debug "[LOG_FILE]::[${LOG_FILE}]"
    debug "[DB_CONFIG]::[${DB_CONFIG}]"
}

validate() {
    debug "[testConnect]::[started]"
    if [[ -z ${DB_CLIENT} ]]; then end_error "[missing client]"; fi
    if [[ ! -f ${DB_CONFIG} ]]; then end_error "[missing db config]"; fi

    if [[ ! -f ${LOG_FILE} ]]; then
        touch ${LOG_FILE}
        if [[ ! -f ${LOG_FILE} ]]; then end_error "[failed to create the log file][${LOG_FILE}]"; fi
    fi

    DB_CLIENT_CONN="${DB_CLIENT} --defaults-extra-file=${DB_CONFIG}"
    debug "[DB_CLIENT_CONN]::[${DB_CLIENT_CONN}]"
    debug "[testConnect]::[completed]"
}

getIpsFromProcessList() {
    if [[ -z "${PROCESS_LIST}" ]]; then getProcesslist; fi
    PROCESS_IPS_FOUND=$(echo ${PROCESS_LIST} | awk '{print $3}' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -n | uniq | sort -nr)
    debug "[getIpsFromProcessList]::[${PROCESS_IPS_FOUND}]"
}

getProcesslist() {
    PROCESS_LIST=$(${DB_CLIENT_CONN} -s -N -e "show processlist;")
    if [[ -z ${PROCESS_LIST} ]]; then end_error '[getProcesslist()]::[PROCESS_LIST]::[empty]'; fi
}

#
# These are the options that we allow to be passed in and that are used in this script.
# NOTE: If string has a "=" it will not work.
#
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | sed 's/^[^=]*=//g'`

    case $PARAM in
        -c  | --config )                    DB_CONFIG=${VALUE} ;;
        -l  | --log )                       LOG_FILE=${VALUE} ;;

        -#  | --debug )                     DEBUG=true ;;
        -h  | --help )                      HELP=true ;;
        *)
            error "[unknown parameter]::[${PARAM}]"
            usage
            ;;
    esac
    shift
done

if [[ ${DEBUG} = true ]]; then debugDefaultVars; fi
if [[ ${HELP} = true ]]; then usage; fi

validate
getProcesslist
getIpsFromProcessList

if [[ -f ${LOG_FILE} ]]; then

IFS='
'
    for ip in ${PROCESS_IPS_FOUND}; do
        debug "[checking for match]::[${ip}]"
        match=$(grep ${ip} ${LOG_FILE})
        if [[ -z ${match} ]]; then
            log "[INFO]::[adding ip]::[${ip}]"
            echo -e "\n${ip}" >> ${LOG_FILE}
        fi
    done
fi

trap cleanup EXIT