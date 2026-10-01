#!/usr/bin/bash

check_basic_info() {
    write_line "===== Linux 服务器基础巡检报告 ====="
    write_line "报告时间：$(date '+%Y-%m-%d %H:%M:%S')"
    write_line "系统版本：$(cat /etc/centos-release 2>/dev/null || echo '未知')"
    write_line "主机名：$(hostname)"
    write_line "IP 地址：$(hostname -I 2>/dev/null | awk '{print $1}')"
    write_line "当前用户：$(whoami)"
    write_line "======================================"
}

check_cpu() {
    cpu_used=$(top -bn1 | grep "Cpu(s)" | grep -o '[0-9.]* id' | awk '{print 100 - $1}')

    if [ -z "$cpu_used" ]; then
        write_line "[ERROR] 无法获取 CPU 使用率"
        return 1
    fi

    cpu_used=${cpu_used%.*}

    if [ "$cpu_used" -ge "$CPU_LIMIT" ]; then
        write_line "[WARN] CPU 使用率：${cpu_used}%（阈值：${CPU_LIMIT}%）"
    else
        write_line "[INFO] CPU 使用率：${cpu_used}%（阈值：${CPU_LIMIT}%）"
    fi
}

check_memory() {
    mem_used=$(free -m | grep Mem | awk '{print $3 / $2 * 100}')

    if [ -z "$mem_used" ]; then
        write_line "[ERROR] 无法获取内存使用率"
        return 1
    fi

    mem_used=${mem_used%.*}

    if [ "$mem_used" -ge "$MEM_LIMIT" ]; then
        write_line "[WARN] 内存使用率：${mem_used}%（阈值：${MEM_LIMIT}%）"
    else
        write_line "[INFO] 内存使用率：${mem_used}%（阈值：${MEM_LIMIT}%）"
    fi
}

check_disk() {
    root_used=$(df -h / | grep / | awk '{print $5+0}')
    var_used=$(df -h /var | tail -n 1 | awk '{print $5+0}')

    if [ -z "$root_used" ]; then
        write_line "[ERROR] 无法获取 / 磁盘使用率"
    else
        if [ "$root_used" -ge "$DISK_LIMIT" ]; then
            write_line "[WARN] / 磁盘使用率：${root_used}%（阈值：${DISK_LIMIT}%）"
        else
            write_line "[INFO] / 磁盘使用率：${root_used}%（阈值：${DISK_LIMIT}%）"
        fi
    fi

    if [ -z "$var_used" ]; then
        write_line "[ERROR] 无法获取 /var 磁盘使用率"
    else
        if [ "$var_used" -ge "$DISK_LIMIT" ]; then
            write_line "[WARN] /var 磁盘使用率：${var_used}%（阈值：${DISK_LIMIT}%）"
        else
            write_line "[INFO] /var 磁盘使用率：${var_used}%（阈值：${DISK_LIMIT}%）"
        fi
    fi
}

check_large_files() {
    large_files=$(find "$LARGE_FILE_DIR" -type f -size +"$LARGE_FILE_SIZE_MB"M 2>/dev/null)

    if [ -z "$large_files" ]; then
        write_line "[INFO] 未发现超过 ${LARGE_FILE_SIZE_MB}MB 的大文件"
    else
        write_line "[WARN] 发现超过 ${LARGE_FILE_SIZE_MB}MB 的大文件："
        write_line "$large_files"
    fi
}

check_service() {
    service_status=$(systemctl is-active "$1" 2>/dev/null)

    if [ "$service_status" = "active" ]; then
        write_line "[INFO] 服务 $1 状态正常：$service_status"
    else
        write_line "[WARN] 服务 $1 状态异常：$service_status"
    fi
}

check_ports() {
    port_status=$(ss -lnt | grep ':22 ')

    if [ -z "$port_status" ]; then
        write_line "[WARN] SSH 端口 22 未监听"
    else
        write_line "[INFO] SSH 端口 22 正在监听"
    fi
}

check_services() {
    SYSTEMCTL_NAME="/opt/server_ops/conf/SYSTEMCTL_NAME.conf"
    if [[ ! -f "$SYSTEMCTL_NAME" ]]; then
    echo "ERROR: 服务器名配置文件不存在：$SYSTEMCTL_NAME"
    return 1
    else
        for n in $(cat "$SYSTEMCTL_NAME" | grep -v '^#')
            do
                if [ $n = "sshd" ] ; then
                check_service "$n"
                check_ports
                else
                check_service "$n"
                fi
            done
    fi
}


analyze_logs() {
    VAR_LOG_NAM=/opt/server_ops/conf/VAR_LOG_NAME.conf
    for log_file in  $(cat "$VAR_LOG_NAM" | grep -v '^#')
    do
        if [ ! -f "$log_file" ]; then
            write_line "[ERROR] 日志文件不存在：$log_file"
        else
            write_line "===== 分析日志：$log_file ====="

            NUM_ONE="0"
           
            for keyword in error fail failed warning denied
            do
                count=$(grep -i "$keyword" "$log_file" | wc -l)
                if [ "$count" -gt 0 ]; then
                    write_line "[WARN] 关键字 $keyword 出现 $count 次"
                    write_line "最近 3 条记录："
                    write_line "$(grep -i "$keyword" "$log_file" | tail -n 3)"
                    NUM_ONE="1"  
                else
                    if [ "$NUM_ONE" = "0" ] && [ "$keyword" = "denied" ] ; then
                    write_line "[INFO] 关键字 problem 未发现"
                fi

                fi
            done
            auth_count=$(grep -i "authentication failure" "$log_file" | wc -l)

                if [ "$auth_count" = "0" ]; then
                    write_line "[INFO] 关键字 authentication failure 未发现"
                else
                     write_line "[WARN] 关键字 authentication failure 出现 $auth_count 次"
                    write_line "最近 3 条记录："
                    write_line "$(grep -i "authentication failure" "$log_file" | tail -n 3)"
                fi
        fi
    done
}
