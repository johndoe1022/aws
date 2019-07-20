#!/bin/sh

# Read common configuration
. /home/admin/virtualenv/aws/conf/Common.conf

function OutputLogMsg() {
    MSG=$1
    LOG_PATH=$2
    PRIORITY=$3

    logger -p $PRIORITY "`date +"%Y/%m/%d %H:%M:%S"` [$PRIORITY] $MSG"
    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` Failed to set priority."
        exit 99
    fi

    echo "`date +"%Y/%m/%d %H:%M:%S"` [$PRIORITY] $MSG" >> ${LOG_PATH}

}