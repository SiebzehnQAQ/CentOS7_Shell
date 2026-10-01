#!/usr/bin/bash

set -u

CONFIG_FILE="/opt/server_ops/conf/server_ops.conf"
FUNCTION_FILE="/opt/server_ops/conf/Shell_function.conf"


if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: 配置文件不存在：$CONFIG_FILE"
    exit 1
elif [ ! -f "$FUNCTION_FILE" ];then
    echo "ERROR: 函数配置文件不存在：$FUNCTION_FILE"
    exit 1
fi
source "$CONFIG_FILE"
for NAME_Shell_function in $(cat "$FUNCTION_FILE" | grep -v '^#')
do 

    source "$NAME_Shell_function"
done

TIMESTAMP=$(date '+%Y-%m-%d_%H%M%S')

REPORT_FILE="${REPORT_DIR}/inspection_${TIMESTAMP}.report"

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$BACKUP_DIR" "$RESTORE_DIR"


write_line() {
    printf '%s\n' "$1" >> "$REPORT_FILE"
    printf '%s\n' "$1" >> "$LOG_FILE"
}

master() {
    if [ "$#" -eq 0 ]; then
        check_basic_info
        check_cpu
        check_memory
        check_disk
        check_large_files
        check_services
        analyze_logs
        create_backup
        cleanup_old_files

        echo "自动任务执行完成"
        echo "巡检报告：$REPORT_FILE"

    elif [ "$1" = "menu" ]; then
        Select_Modile

    else
        echo "请输入 menu 或 不使用参数执行"
    fi
}

master "$@"
