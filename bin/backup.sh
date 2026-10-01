#!/usr/bin/bash

create_backup() {
    BACKUP_FILE=""$BACKUP_DIR"/server_backup_$(date '+%Y-%m-%d_%H%M%S').tar.gz"

    tar -czf "$BACKUP_FILE" \
        /etc/hosts \
        /etc/fstab \
        /etc/ssh/sshd_config \
        /etc/crontab \
        "$BASE_DIR/conf" \
        "$BASE_DIR/bin" 2>/dev/null

    if [ "$?" = "0" ]; then
        echo "备份完成，备份文件:$BACKUP_FILE"
        write_line "[INFO] 备份成功：$BACKUP_FILE"
    else
        echo "备份失败"
        write_line "[ERROR] 备份失败"
        rm -f "$BACKUP_FILE"
        return 1
    fi
}
