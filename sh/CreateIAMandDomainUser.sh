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
CREATE_USER_INFO_PATH="${CONF_DIR}/CreatUserInfo.lst"
USER_PASSWD='John_10228979'

# Main method / initila
OutputLogMsg "Start creation of iam and domain user" ${SH_LOG_PATH} "info"

if [ ! -e $CREATE_USER_INFO_PATH ]; then
    OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$SH_NAME] Failed to read creation user information." ${SH_LOG_PATH} "err"
fi

# Main method / main
while read line
do
    # creat iam user
    CheckIAMUser ${line}
    if [ $? -ne 0 ]; then
        OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` IAM user already exists." ${SH_LOG_PATH} "info"

    else
        CreateIAMUser ${line} $SH_LOG_PATH ${USER_PASSWD}
        if [ $? -ne 0 ]; then
            OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$SH_NAME] Failed to create iam user." ${SH_LOG_PATH} "err"
            exit 99
        fi

        AttachIAMGroup ${line} ${IAM_ADMINISTRATOR_GROUP} $SH_LOG_PATH
        if [ $? -ne 0 ]; then
            OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$SH_NAME] Failed to attach group to created iam user." ${SH_LOG_PATH} "err"
            exit 99
        fi

        OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$line] IAM user creation successful." ${SH_LOG_PATH} "info"
    fi

    # create domain user
    CheckDomainUser ${line}
    if [ $? -ne 0 ]; then
        OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` Domain user already exits." ${SH_LOG_PATH} "info"

    else
        CreareDomainUser ${line} $SH_LOG_PATH ${USER_PASSWD}
        if [ $? -ne 0 ]; then
            OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$SH_NAME] Failed to create domain user." ${SH_LOG_PATH} "err"
            exit 99
        fi

        UserAddGroup ${line} $SH_LOG_PATH ${DOMAIN_DEVELOPER_GROUP}
        if [ $? -ne 0 ]; then
            OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$SH_NAME] Failed to create domain user." ${SH_LOG_PATH} "err"
            exit 99
        fi

        OutputLogMsg "`date +"%Y/%m/%d %H:%M:%S"` [$line] Domain user creation successful." ${SH_LOG_PATH} "info"
    fi

done < ${CREATE_USER_INFO_PATH}

# Main method / end
OutputLogMsg "End creation of iam and domain user" ${SH_LOG_PATH} "info"