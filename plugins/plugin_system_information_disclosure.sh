#!/bin/bash

# brief    : 检测是否存在系统信息泄露
#
#

PLUGIN_NAME="system information disclosure"
HAVE_RISK=0
Show "Checking ${PLUGIN_NAME}"


if [ -f "/etc/rc.d/rc.local" ]; then
    DISCLOSURE_INFO=$(cat /etc/rc.d/rc.local | grep -v "^#" | grep -E "echo|printf")
    [ $? -eq 0 ] && HAVE_RISK=$(( $HAVE_RISK + 1 )) && PROBLEM_COUNT=$(( $PROBLEM_COUNT + 1 )) && Logger "[info] found echo OR printf at /etc/rc.d/rc.local"
fi

[ -f "/etc/issue" -o -f "/etc/issue.net" ] && HAVE_RISK=$(( $HAVE_RISK + 1 )) && PROBLEM_COUNT=$(( $PROBLEM_COUNT + 1 ))  && Logger "[info] found issue OR issue.net at /etc/"

if [ $HAVE_RISK -eq 0 ]; then
    Logger "[info] no ${PLUGIN_NAME}"
fi
