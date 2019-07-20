#!/bin/sh

# Read common configuration
. /home/admin/virtualenv/aws/conf/Common.conf

# Check Domain user
function CheckDomainUser() {
    CREATE_DOMAIN_USER=$1

    DOMAIN_USER=`samba-tool user list | grep ${CREATE_DOMAIN_USER}`
    if [ -n "${DOMAIN_USER}" ]; then
        return 99
    fi
}

function CreareDomainUser() {
    CREATE_DOMAIN_USER=$1
    STD_LOG_PATH=$2
    PASSWD=$3

    echo '********************Create domain user********************' >> ${STD_LOG_PATH}
    samba-tool user create ${CREATE_DOMAIN_USER} ${PASSWD} >> ${STD_LOG_PATH}

    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Faild to delete domain user."
        return 99
    fi
    echo '' >> ${STD_LOG_PATH}
}

function UserAddGroup() {
    DOMAIN_USER=$1
    STD_LOG_PATH=$2
    DOMAIN_GROUP=$3

    echo '********************Add user to group********************' >> ${STD_LOG_PATH}
    samba-tool group addmembers ${DOMAIN_GROUP} ${DOMAIN_USER} >> ${STD_LOG_PATH}
    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Faild to create domain user."
        return 99
    fi
    echo '' >> ${STD_LOG_PATH}
}

function DeleteDomainUser() {
    DELETE_DOMAIN_NAME=$1
    STD_LOG_PATH=$2

    echo '********************Delete domain user********************' >> ${STD_LOG_PATH}
    samba-tool user delete ${DELETE_DOMAIN_NAME} >> ${STD_LOG_PATH}

    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Faild to delete domain user."
        return 99
    fi
    echo '' >> ${STD_LOG_PATH}
}