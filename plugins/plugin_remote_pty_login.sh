#!/bin/bash

# brief    : 检测是否允许root以telnet等方式远程登录
#
#

PLUGIN_NAME="remote pty login"
HAVE_RISK=0
Show "Checking ${PLUGIN_NAME}"

TTY_CONFIG_FILE="/etc/securetty"

if [ -f "${TTY_CONFIG_FILE}" ]; then
    cat ${TTY_CONFIG_FILE} | grep "^pts" > /dev/null
    [ $? -eq 0 ] && HAVE_RISK=$(( $HAVE_RISK + 1)) && PROBLEM_COUNT=$(( $PROBLEM_COUNT + 1 )) && Logger "[info] found pts at ${TTY_CONFIG_FILE}"
    
    if [ $HAVE_RISK -eq 0 ]; then 
        Logger "[info] no ${PLUGIN_NAME} risk" 
    fi
else
    Logger "[warn] no securetty file"
fi
