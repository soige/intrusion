#!/bin/bash

# brief    : 检测unix账户安全
#
#

PLUGIN_NAME="unix account"
HAVE_RISK=0
Show "Checking ${PLUGIN_NAME}"

ACCOUNT_CONFIG_FILE="/etc/passwd"

# 是否有除了root外UID为0的用户
UID0_COUNT=0
# 如果不带':x:'的用户肯定是无法正常使用的,所以可以用此方法来检测
UID0_COUNT=$(cat ${ACCOUNT_CONFIG_FILE} | grep ":x:0" | grep -v "root:x:0" | wc -l)
if [ ${UID0_COUNT} -ne 0 ]; then
    HAVE_RISK=$(( ${HAVE_RISK} + 1 )) && PROBLEM_COUNT=$(( ${PROBLEM_COUNT} + 1 )) && Logger "[info] found ${UID0_COUNT} accounts with uid 0 at ${ACCOUNT_CONFIG_FILE}"
fi

# 系统无关账号
USELESS_COUNT=0
USELESS_USERS="bin,daemon,adm,lp.sync.shutdown,halt,mail,news,uucp,operator,games,gopher,ftp,nobody,vcsa,oprofile,ntp,xfs,dbus,avahi,haldeamon,gdm,avahi-autoipd,sabayon,pcap"
for HOME_USER in $(awk -F: '{ print $1 }' ${ACCOUNT_CONFIG_FILE}); do
    echo ${USELESS_USERS} | grep "${HOME_USER}," > /dev/null
    [ $? -eq 0 ] && USELESS_COUNT=$(( ${USELESS_COUNT} + 1 )) && Logger "[info] found useless account ${HOME_USER}"
done

if [ ${USELESS_COUNT} -ne 0 ]; then
    HAVE_RISK=$(( ${HAVE_RISK} + 1 )) && PROBLEM_COUNT=$(( ${PROBLEM_COUNT} + 1 )) && Logger "[info] total (${USELESS_COUNT}) useless accounts"
fi

# Home目录权限
HOME_COUNT=0
for HOME_DIR in $(awk -F: '{ print $6 }' ${ACCOUNT_CONFIG_FILE}); do
    USER_NAME=$(cat /etc/passwd | grep "${HOME_DIR}" | awk -F: '{print $1}')
    echo ${USELESS_USERS} | grep "${USER_NAME}," > /dev/null
    [ $? -ne 0 ] && ls -ld ${HOME_DIR} | grep -v "^drwxr-x---" > /dev/null && HOME_COUNT=$(( ${HOME_COUNT} + 1 )) && Logger "[info] found ${HOME_DIR} directory attributes not 750"
done

if [ ${HOME_COUNT} -ne 0 ]; then
    HAVE_RISK=$(( ${HAVE_RISK} + 1 )) && PROBLEM_COUNT=$(( ${PROBLEM_COUNT} + 1 )) && Logger "[info] total (${HOME_COUNT}) directories attributes not 750"
fi

# other approach

if [ $HAVE_RISK -eq 0 ]; then
    Logger "[info] no ${PLUGIN_NAME} risk"
fi
