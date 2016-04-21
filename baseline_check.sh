#!/bin/bash

###############################################################################
# Brief: Linux baseline check.
# Time: 2016/04/21
#
# Author: xyang
#
# Referer: http://drops.wooyun.org/tips/2621
###############################################################################

VERSION=0.01


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
echo "--------------------------------------------------------------------------"
echo "  Operating system::                ${OS}"
echo "  Operating system version:         ${OS_NAME}"
echo "  Hardware platform:                ${PLATFORM}"
echo "  Hostname:                         ${HOST_NAME}"
echo "--------------------------------------------------------------------------"

## 基线检测

### 检测是否有系统安全更新
echo "[+] 检测是否有系统安全更新"
HAVE_UPDATE=0
UPDATE_INFO=`yum info-security | grep "Update ID"`
[ $? -eq 0 ] && HAVE_UPDATE=$(( $HAVE_UPDATE + 1 ))

if [ $HAVE_UPDATE -ne 0 ]; then
    echo " [-] 存在系统安全更新"
else
    echo " [-] 暂无系统安全更新"
fi

### 检测是否存在系统信息泄露
echo "[+] 检测是否存在系统信息泄露"
WEAK_COUNT=0
if [ -f "/etc/rc.d/rc.local" ]; then
    # 检测是否存在echo/printf语句
    WEAK_INFO=`cat /etc/rc.d/rc.local | grep -v "^#" | grep -E "echo|printf"`
    [ $? -eq 0 ] && WEAK_COUNT=$(( $WEAK_COUNT + 1 ))
fi
# 检测issue文件是否存在，该文件用于用户登录终端时的回显信息
[ -f "/etc/issue" -o -f "/etc/issue.net" ] && WEAK_COUNT=$(( $WEAK_COUNT + 1 ))

if [ $WEAK_COUNT -ne 0 ]; then
    echo " [-] 存在系统信息泄露风险"
else
    echo " [-] 暂无风险"
fi

### 检测SSH安全配置
echo "[+] 检测SSH安全配置"
SSH_COUNT=0
if [ -f "/etc/ssh/sshd_config" ]; then
    cat /etc/ssh/sshd_config | grep "^PermitRootLogin yes" > /dev/null
    [ $? -eq 0 ] && SSH_COUNT=$(( $SSH_COUNT + 1 ))
    cat /etc/ssh/sshd_config | grep "^X11Forwarding yes" > /dev/null
    [ $? -eq 0 ] && SSH_COUNT=$(( $SSH_COUNT + 1 ))
    # 开启密码登录且端口为默认22端口
    SSH_PORT=`netstat -ntpl | grep sshd | head -n 1 | awk -F " " '{print $4}' | awk -F ":" '{print $2}'`
    cat /etc/ssh/sshd_config | grep "^PasswordAuthentication yes" > /dev/null
    [ $? -eq 0 ] && [ 22 -eq $SSH_PORT ] && SSH_COUNT=$(( $SSH_COUNT + 1 ))
    
    if [ $SSH_COUNT -ne 0 ]; then
        echo " [-] 存在SSH安全配置风险"
    else
        echo " [-] 暂无风险"
    fi
else
    echo " [-] 未发现sshd_config文件"
fi

### 检测是否允许root以telnet等方式远程登录
echo "[+] 检测是否允许root以telnet等方式远程登录"
REMOTE_COUNT=0
if [ -f "/etc/securetty" ]; then
    cat /etc/securetty | grep "^pts" > /dev/null
    [ $? -eq 0 ] && REMOTE_COUNT=$(( $REMOTE_COUNT + 1 ))
    
    if [ $REMOTE_COUNT -ne 0 ]; then
        echo " [-] 存在root以telnet等方式远程登录风险"
    else
        echo " [-] 暂无风险"
    fi
else
    echo " [-] 未发现securetty文件"
fi

### 检测是否有除了root外UID为0的用户
echo "[+] 检测是否有除了root外UID为0的用户"
# 如果不带':x:'的用户肯定是无法正常使用的,所以可以用此方法来检测
UID0_COUNT=`cat /etc/passwd | grep ":x:0" | grep -v "root:x:0" | wc -l`

if [ $UID0_COUNT -ne 0 ]; then
    echo " [-] 存在除了root外UID为0的用户"
else
    echo " [-] 暂无风险"
fi

### 检测系统无关账号
echo "[+] 检测系统无关账号"
USELESS_COUNT=0

USELESS_USERS="bin,daemon,adm,lp.sync.shutdown,halt,mail,news,uucp,operator,games,gopher,ftp,nobody,vcsa,oprofile,ntp,xfs,dbus,avahi,haldeamon,gdm,avahi-autoipd,sabayon,pcap"

for HOME_USER in $(awk -F: '{ print $1 }' /etc/passwd)
do
    echo $USELESS_USERS | grep "${HOME_USER}," > /dev/null
    [ $? -eq 0 ] && USELESS_COUNT=$(( $USELESS_COUNT + 1 ))
done

if [ $USELESS_COUNT -ne 0 ]; then
    echo " [-] 存在系统无关账号"
else
    echo " [-] 暂无风险"
fi

### 检测Home目录的权限
echo "[+] 检测Home目录的权限"
HOME_COUNT=1
for HOME_DIR in $(awk -F: '{ print $6 }' /etc/passwd)
do
    USER_NAME=`cat /etc/passwd | grep "${HOME_DIR}" | awk -F: '{print $1}'`
    echo $USELESS_USERS | grep "${USER_NAME}," > /dev/nul
    [ $? -ne 0 ] && ls -ld $HOME_DIR | grep -v "^drwxr-x---" > /dev/null && HOME_COUNT=$(( $HOME_COUNT + 1 ))
done

if [ $HOME_COUNT -ne 0 ]; then
    echo " [-] 存在Home目录权限风险"
else
    echo " [-] 暂无风险"
fi

### 检测系统高危文件
echo "[+] 检测系统高危文件"
HIGH_COUNT=0

HIGH_FILES="/.netrc,/.rhosts,/etc/hosts.equiv"
for HIGH_FILE in $(echo $HIGH_FILES | awk -F, '{ for(i=1; i<=NF; i++) print $i }')
do
    [ -f "$HIGH_FILE" ] && HIGH_COUNT=$(( $HIGH_COUNT + 1 ))
done

if [ $HIGH_COUNT -ne 0 ]; then
    echo " [-] 存在系统高危文件"
else
    echo " [-] 暂无风险"
fi

### 检测开放的端口
echo "[+] 检测开放的端口"
for OPEN_PORT in $(netstat -ntpl | awk '{ print $4 }' | grep '0.0.0.0:' | awk -F: '{ print $2 }')
do
    echo " [-] 发现开放端口：${OPEN_PORT}"
done

### 检测系统日志权限
echo "[+] 检测系统日志权限"
LOGS_COUNT=0
SYSTEM_LOGS="/var/log/messages,/var/log/secure,/var/log/maillog,/var/log/cron,/var/log/spooler,/var/log/boot.log"
for SYSTEM_LOG in $(echo $SYSTEM_LOGS | awk -F, '{ for(i=1; i<=NF; i++) print $i }')
do
    [ -f "$SYSTEM_LOG" ] && ls -ld $SYSTEM_LOG | grep -E "^-rw-------|^-rw-r-----" > /dev/null && LOGS_COUNT=$(( $LOGS_COUNT + 1 ))
done

if [ $LOGS_COUNT -ne 0 ]; then
    echo " [-] 存在系统日志权限风险"
else
    echo " [-] 暂无风险"
fi

echo "[*] Done"
echo


