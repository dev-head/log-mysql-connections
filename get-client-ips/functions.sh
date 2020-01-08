#!/usr/bin/env bash

# Used to log a warning message to stdout.
end_error () {
    DATE=`date +%Y-%m-%d:%H:%M:%S`
    LOG_PREFIX=${LOG_PREFIX:-}
    while [ "$1" != "" ]; do
        echo "${LOG_PREFIX}::[QUITING]::[${DATE}]::${1}"
        shift;
    done;
    exit 1
}

error() {
    DATE=`date +%Y-%m-%d:%H:%M:%S`
    LOG_PREFIX=${LOG_PREFIX:-}
    while [ "$1" != "" ]; do
        echo "${LOG_PREFIX}::[ERROR]::[${DATE}]::${1}"
        shift;
    done;
}

# Used to output a message to stdout
log() {
    DATE=`date +%Y-%m-%d:%H:%M:%S`
    LOG_PREFIX=${LOG_PREFIX:-}
    while [ "$1" != "" ]; do
        echo "${LOG_PREFIX}::[LOG]::[${DATE}]::${1}"
        shift;
    done;
}

debug() {
    DATE=`date +%Y-%m-%d:%H:%M:%S`
    LOG_PREFIX=${LOG_PREFIX:-}
    while [ "$1" != "" ]; do
        if [[ "${DEBUG}" == "true" ]]; then
            echo "${LOG_PREFIX}::[DEBUG]::[${DATE}]::${1}"
        fi
        shift;
    done;
}

ucFirst() {
    while [ "$1" != "" ]; do
            echo "$1" | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }'
        shift;
    done;
}

ucAll() {
    while [ "$1" != "" ]; do
            echo "$1" | awk '{ print toupper($0) }'
        shift;
    done;
}