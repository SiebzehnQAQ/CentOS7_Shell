\# CentOS 7 Linux 服务器自动化巡检与备份系统



\## 1. 项目简介



主要功能：



\- 检查 CPU、内存和磁盘使用率；

\- 检查指定目录中的大文件；

\- 检查 sshd、crond、rsyslog扥服务；

\- 检查 SSH 22 端口；

\- 分析系统日志中的异常关键字；

\- 备份重要配置文件和项目文件；

\- 清理超过保留天数的历史文件；

\- 使用 crond 每天自动执行；

\- 支持从备份中恢复单个文件、conf 目录和项目脚本。



\## 2. 项目目录



```text

/opt/server\_ops/

├── bin/

│   ├── main.sh

│   ├── check.sh

│   ├── backup.sh

│   ├── cleanup.sh

│   ├── menu\_bar.sh

│   └── restore.sh

├── conf/

├── logs/

├── reports/

├── backups/

│   └── old\_configs/

└── restore/

