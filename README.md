# Intrusion
Security Hardening、Detection

# UPDATE
 * 将检查项整合以插件模块输出
 * 增加日志记录功能

# TODO
 * 增加上传（FTP、Rsync）模块，将日志上传到统一服务器

## Baseline Check

~~~
[root@ccsec intrusion]# bash baseline_check.sh

        --------------------------------------------------------------------------
        Operating system:                 Linux
        Operating system version:         CentOS Linux release 7.0.1406 (Core)
        Hardware platform:                x86_64
        Hostname:                         ccsec
        --------------------------------------------------------------------------

        [*] Found plugin file: ./plugins/plugin_remote_pty_login.sh
        [*] Checking remote pty login
        [*] Found plugin file: ./plugins/plugin_ssh_service_configuration.sh
        [*] Checking ssh service configuration
        [*] Found plugin file: ./plugins/plugin_system_high_risk_file.sh
        [*] Checking system high risk file
        [*] Found plugin file: ./plugins/plugin_system_information_disclosure.sh
        [*] Checking system information disclosure
        [*] Found plugin file: ./plugins/plugin_system_log.sh
        [*] Checking system log
        [*] Found plugin file: ./plugins/plugin_system_opened_port.sh
        [*] Checking system opened port
        [*] Found plugin file: ./plugins/plugin_system_security_update.sh
        [*] Checking system security updates
        [*] Found plugin file: ./plugins/plugin_unix_account.sh
        [*] Checking unix account

        [*] 5 total problems found
~~~

### 检测是否有系统安全更新

 * yum update software-name

### 检测是否存在系统信息泄露

 * 修改文件 ```/etc/rc.d/rc.local```，注释含有类似 ```echo``` 或 ```printf``` 的行

 * 删除 ```/etc/issue```、```/etc/issue.net``` 文件

### 检测SSH安全配置

 * 不允许 ```root``` 用户ssh登录，只能通过普通用户使用 ```su``` 命令提升

 * 服务器建议上不开启 ```X11Forwarding```

 * 修改默认 ```22``` 端口

 * 关闭密码认证 ```PasswordAuthentication no```

### 检测是否允许root以telnet等方式远程登录

 * ```/etc/securetty``` 中删除 ```pts``` 相关

### 检测是否有除了root外UID为0的用户

 * 排查账户的由来，并删除

### 检测系统无关账号

 * 删除系统无关账号

### 检测Home目录的权限

 * ```/home/xxx``` 目录保证 ```750``` 权限码

### 检测系统高危文件

 * 删除 ```/.netrc```、```/.rhosts```、```/etc/hosts.equiv``` 文件

### 检测开放的端口

 * 关闭不需要的端口

### 检测系统日志权限

 * 系统日志权限控制在 ```640``` 或 ```600```
