#!/bin/bash

###############################################################################
# Brief: Linux baseline check.
# Time: 2016/04/21
# Update: 2016/06/08
#
# Author: xyang
#
# Referer: http://drops.wooyun.org/tips/2621
###############################################################################

VERSION=0.02


OS=`uname`
if [ -f "/etc/redhat-release" ]; then
    OS_NAME=`cat /etc/redhat-release`
    PLATFORM=`uname -i`
elif [ -f "/etc/lsb-release" ]; then
    OS_NAME=`cat /etc/lsb-release | grep "DISTRIB_DESCRIPTION" | awk -F "\"" '{print $2}'`
    PLATFORM=`arch`
elif [ -f "/etc/issue.net" ]; then
    OS_NAME=`cat /etc/issue.net`
    PLATFORM=`uname -i`
else
    OS_NAME="localhost"
    PLATFORM=`unknown`
fi

HOST_NAME=`hostname`

## 系统基本信息
echo
echo "--------------------------------------------------------------------------"
echo "  Operating system:                 ${OS}"
echo "  Operating system version:         ${OS_NAME}"
echo "  Hardware platform:                ${PLATFORM}"
echo "  Hostname:                         ${HOST_NAME}"
echo "--------------------------------------------------------------------------"
echo

## 基线检测
LOGFILE="./log/$(cat /etc/hostname)-$(date '+%Y%m%d%H%M%S').log"
PLUGINDIR="./plugins/"
PROBLEM_COUNT=0

# load common functions
. ./include/*.sh

# search plugins & load plugins
FIND_PLUGINS=$(find ${PLUGINDIR} -type f -name "plugin_[a-z_]*\.sh" | sort)
for PLUGIN_FILE in ${FIND_PLUGINS}; do
    Show ${SECTION}"Found plugin file: ${PLUGIN_FILE}"${NORMAL}
    if [ -f ${PLUGIN_FILE} ]; then
        . ${PLUGIN_FILE}
    fi
done

# result
echo
Show "${PROBLEM_COUNT} total problems found"
