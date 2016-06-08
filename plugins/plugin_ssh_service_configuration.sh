#!/bin/bash

# brief    : 检测SSH服务配置
#
#

PLUGIN_NAME="ssh service configuration"
HAVE_RISK=0
Show "Checking ${PLUGIN_NAME}"

SSHD_CONFIG_FILE="/etc/ssh/sshd_config"

if [ -f "${SSHD_CONFIG_FILE}" ]; then
    cat ${SSHD_CONFIG_FILE} | grep -E "^PermitRootLogin\s+yes" > /dev/null
    [ $? -eq 0 ] && HAVE_RISK=$(( $HAVE_RISK + 1 )) && Logger "[info] found PermitRootLogin is enabled at ${SSHD_CONFIG_FILE}"
    cat ${SSHD_CONFIG_FILE} | grep -E "^X11Forwarding\s+yes" > /dev/null
    [ $? -eq 0 ] && HAVE_RISK=$(( $HAVE_RISK + 1 )) && Logger "[info] found X11Forwarding is enabled at ${SSHD_CONFIG_FILE}"
    cat ${SSHD_CONFIG_FILE} | grep -E "^PasswordAuthentication\s+yes" > /dev/null
    [ $? -eq 0 ] && HAVE_RISK=$(( $HAVE_RISK + 1 )) && Logger "[info] found opened PasswordAuthentication at ${SSHD_CONFIG_FILE}"
    CURRENT_SSHD_PORT=$(netstat -ntpl | grep sshd | head -n 1 | awk -F " " '{print $4}' | awk -F ":" '{print $2}')
    [ $? -eq 0 ] && [ "22" -eq "${CURRENT_SSHD_PORT}" ] && HAVE_RISK=$(( $HAVE_RISK + 1 )) && Logger "[info] found sshd listen port 22"
    
    if [ $HAVE_RISK -ne 0 ]; then 
        PROBLEM_COUNT=$(( $PROBLEM_COUNT + 1 )) 
    else
        Logger "[info] no ${PLUGIN_NAME} risk"
    fi
else
    Logger "[warn] no sshd_config file"
fi
