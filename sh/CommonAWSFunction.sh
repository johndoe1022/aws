#!/bin/sh

# Read common configuration
. /home/admin/virtualenv/aws/conf/Common.conf

# Check IAM user
function CheckIAMUser() {
    CREATE_IAM_NAME=$1

    IAM_RES=`aws iam list-users | jq -r '.Users[].UserName' | grep ${CREATE_IAM_NAME}`
    if [ -n "${IAM_RES}" ]; then
        return 99
    fi
}

# Create IAM User
function CreateIAMUser() {
    CREATE_IAM_NAME=$1
    STD_LOG_PATH=$2
    PASSWD=$3

    # create iam user
    echo '********************Create iam user********************' >> ${STD_LOG_PATH}
    aws iam create-user --user-name ${CREATE_IAM_NAME} >> ${STD_LOG_PATH}
    if [ $? -ne 0 ]; then
        return 99
    fi
    echo '' >> ${STD_LOG_PATH}

    # initial passwd setting
    aws iam create-login-profile --user-name ${CREATE_IAM_NAME} \
                                 --password ${PASSWD} \
                                 --password-reset-required >> ${STD_LOG_PATH}
    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Failed to set initial passwd."
        return 99
    fi
    echo '' >> ${STD_LOG_PATH}
}

# Attache group to iam user
function AttachIAMGroup() {
    IAM_NAME=$1
    IAM_GROUP=$2
    STD_LOG_PATH=$3

    echo '********************Attach group to iam user********************' >> ${STD_LOG_PATH}
    aws iam add-user-to-group --user-name ${IAM_NAME} --group-name ${IAM_GROUP} >> ${STD_LOG_PATH}
    if [ $? -ne 0 ]; then
        logger -p err "`date +"%Y/%m/%d %H:%M:%S"` [ERR] Failed to attach group to iam user."
        return 99
    fi
    echo '' >> ${STD_LOG_PATH}
}

# Get ec2 descriptions
function GetEC2Infomation() {

    STDOUT_PATH=$1

    aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.State.Name == "running") |
        [
            (.Tags[]| select(.Key == "Name") | .Value ) // "",
                .InstanceId,
                .InstanceType,
                .Placement.AvailabilityZone,
                .State.Name,
                .Platform,
                .EbsOptimized,
                .VpcId,
                .VirtualizationType,
                .PublicDnsName,
                .PublicIpAddress,
                .PrivateIpAddress,
                .KeyName
        ] | @csv' > ${STDOUT_PATH}
}

# Delete IAM user
function DeleteIAMUser() {
    DELETE_IAM_NAME=$1
    STD_LOG_PATH=$2

    # delete iam user
    echo '********************Delete iam user********************' >> ${STD_LOG_PATH}
    aws iam delete-user --user-name ${DELETE_IAM_NAME} >> ${STD_LOG_PATH}
    if [ $? -ne 0 ]; then
        return 99
    fi
    echo '' >> ${STD_LOG_PATH}
}