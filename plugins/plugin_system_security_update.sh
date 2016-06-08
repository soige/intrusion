#!/bin/bash

# brief    : 检测是否有系统安全更新
#
#

PLUGIN_NAME="system security updates"

Show "Checking ${PLUGIN_NAME}"


UPDATE_INFO=$(yum info-security | grep "Update ID")
[ $? -eq 0 ] && PROBLEM_COUNT=$(( $PROBLEM_COUNT + 1 )) && Logger "[info] found ${PLUGIN_NAME}"

if [ $PROBLEM_COUNT -eq 0 ]; then
    Logger "[info] no ${PLUGIN_NAME}"
fi
