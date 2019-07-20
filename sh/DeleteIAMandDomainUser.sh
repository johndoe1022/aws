#!/bin/sh

# Read configuration
. /home/admin/virtualenv/aws/conf/Common.conf

# Read AWS and Domain function
. ${SH_DIR}/Common.sh &&
. ${SH_DIR}/CommonAWSFunction.sh &&
. ${SH_DIR}/CommonDomainFunction.sh
if [ $? -ne 0 ]; then
    logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [INF] Failed to read initial function."
    exit 99
fi

# Set Variable
SH_NAME=`basename $0 .sh`
SH_LOG_PATH=${LOG_DIR}/${SH_NAME}_`date +"%Y%m%d"`.log
DELETE_USER_INFO_PATH="${CONF_DIR}/DeleteUserInfo.lst"

# Main method / initila
OutputLogMsg "Delete iam and domain user" ${SH_LOG_PATH} "info"

if [ ! -e $DELETE_USER_INFO_PATH ]; then
    OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$SH_NAME] Failed to read delete user information." ${SH_LOG_PATH} "err"
fi

# Main method / main
while read line
do
    # delete iam user
    CheckIAMUser ${line}
    if [ $? -eq 0 ]; then
        OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` There is no IAM user." ${SH_LOG_PATH} "info"

    else
        DeleteIAMUser ${line} ${IAM_ADMINISTRATOR_GROUP} $SH_LOG_PATH
        if [ $? -ne 0 ]; then
            OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$SH_NAME] Failed to delete iam user." ${SH_LOG_PATH} "err"
            exit 99
        fi
        OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$line] Delete iam user successful." ${SH_LOG_PATH} "info"
    fi

    # delete domain user
    CheckDomainUser ${line}
    if [ $? -eq 0 ]; then
        OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` There is no domain user" ${SH_LOG_PATH} "info"

    else
        DeleteDomainUser ${line} $SH_LOG_PATH
        if [ $? -ne 0 ]; then
            OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$SH_NAME] Faild to delete domain user." ${SH_LOG_PATH} "err"
            exit 99
        fi
        OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$line] Delete domain user successful." ${SH_LOG_PATH} "info"
    fi

done < ${DELETE_USER_INFO_PATH}

# Main method / end
OutputLogMsg "End delete iam and domain user" ${SH_LOG_PATH} "info"