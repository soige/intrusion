#!/bin/bash

# brief    : 检测系统开放端口
#
#

PLUGIN_NAME="system opened port"

Show "Checking ${PLUGIN_NAME}"

OPENED_COUNT=0
for OPEN_PORT in $(netstat -tan |grep LISTEN |grep -v 127.0.0.1 | grep -v "tcp6" | awk -F" " '{print $4}'); do
    OPENED_COUNT=$(( ${OPENED_COUNT} + 1 )) && Logger "[info] found ${OPEN_PORT} open"
done

if [ ${OPENED_COUNT} -ne 0 ]; then
    PROBLEM_COUNT=$(( ${PROBLEM_COUNT} + 1 )) && Logger "[info] total (${OPENED_COUNT}) opened ports"
fi

if [ $PROBLEM_COUNT -eq 0 ]; then
    Logger "[info] no ${PLUGIN_NAME} risk"
fi
