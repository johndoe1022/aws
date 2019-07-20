#!/bin/sh

IAMGROUPNAME='administrators'
DOMAINGROUPNAME='develop'
INITIALPASS='passwd'

USER_INFO='/home/admin/virtualenv/aws/log/AddUserInfo.conf'
STDOUT_PATH="/home/admin/virtualenv/aws/log/CreateIAMandDomainUser.log"

# Initiai method
echo "`date +"%Y/%m/%d %H:%M:%S"` [INF] Start IAM and Domain user creation "

if [ ! -e $USER_INFO ]; then
    logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] User configuration file was not found."
    #exit 99
fi

if [ -e $STDOUT_PATH ]; then
    rm -f $STDOUT_PATH
fi

while read line;
do
    # Create IAM user
    echo '***********************Create IAM user***********************' #>> $STDOUT_PATH
    aws iam create-user --user-name $line >> $STDOUT_PATH
    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Failed to IAM user."
        #exit 98
    fi
    
    echo '***********************Attach group to createed IAM user***********************' #>> $STDOUT_PATH
    aws iam add-user-to-group --user-name $line --group-name $IAMGROUPNAME #>> $STDOUT_PATH
    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Failed to attache group to created user."
        #exit 97
    fi
    
    # Create domain user
    echo '***********************Create domain user***********************' #>> $STDOUT_PATH
    echo "samba-tool user create $line $INITIALPASS"
    samba-tool user create $line $INITIALPASS >> $STDOUT_PATH
    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Failed to create domain user."
        #exit 96
    fi
    
    echo '***********************Add created user to domain group***********************' #>> $STDOUT_PATH
    samba-tool group addmembers $DOMAINGROUPNAME $line >> $STDOUT_PATH
    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Failed to add created user to group for developper."
        #exit 95
    fi
done < $USER_INFO