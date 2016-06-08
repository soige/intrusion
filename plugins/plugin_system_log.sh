#!/bin/bash

# brief    : 检测系统日志权限
#
#

PLUGIN_NAME="system log"
HAVE_RISK=0
Show "Checking ${PLUGIN_NAME}"

LOGS_COUNT=0
SYSTEM_LOGS="/var/log/messages,/var/log/secure,/var/log/maillog,/var/log/cron,/var/log/spooler,/var/log/boot.log"

for SYSTEM_LOG in $(echo $SYSTEM_LOGS | awk -F, '{ for(i=1; i<=NF; i++) print $i }'); do
    [ -f "$SYSTEM_LOG" ] && ls -ld $SYSTEM_LOG | grep -E "^-rw-------|^-rw-r-----" > /dev/null && LOGS_COUNT=$(( $LOGS_COUNT + 1 )) && Logger "[info] found ${SYSTEM_LOG} attributes not 600 or 640"
done

if [ ${LOGS_COUNT} -ne 0 ]; then
    HAVE_RISK=$(( ${HAVE_RISK} + 1 )) && PROBLEM_COUNT=$(( ${PROBLEM_COUNT} + 1 )) && Logger "[info] total (${LOGS_COUNT}) system logs illegal"
fi

if [ $HAVE_RISK -eq 0 ]; then
    Logger "[info] no ${PLUGIN_NAME} risk"
fi
