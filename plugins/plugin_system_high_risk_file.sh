#!/bin/bash

# brief    : 检测系统高危文件
#
#

PLUGIN_NAME="system high risk file"
HAVE_RISK=0
Show "Checking ${PLUGIN_NAME}"


HIGH_RISK_FILE="/.netrc,/.rhosts,/etc/hosts.equiv"
HIGH_COUNT=0

for HIGH_FILE in $(echo ${HIGH_FILES} | awk -F, '{ for(i=1; i<=NF; i++) print $i }'); do
    [ -f "${HIGH_FILE}" ] && HIGH_COUNT=$(( ${HIGH_COUNT} + 1 )) && Logger "[info] found high risk file ${HIGH_FILE}"
done

if [ ${HIGH_COUNT} -ne 0 ]; then
    HAVE_RISK=$(( ${HAVE_RISK} + 1 )) && PROBLEM_COUNT=$(( ${PROBLEM_COUNT} + 1 )) && Logger "[info] total (${HIGH_COUNT}) high risk files"
fi

if [ $HAVE_RISK -eq 0 ]; then
    Logger "[info] no ${PLUGIN_NAME} risk"
fi
