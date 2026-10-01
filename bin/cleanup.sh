#!/usr/bin/bash

cleanup_old_files() {
    for old_file in $(find "$REPORT_DIR" -type f -mtime +"$RETENTION_DAYS")
    do
        rm -f "$old_file"
    done

    for old_file in $(find "$BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS")
    do
        rm -f "$old_file"
    done

    for old_file in $(find "$LOG_DIR" -type f -mtime +"$RETENTION_DAYS")
    do
        rm -f "$old_file"
    done
    
    for old_file in $(find "$RESTORE_DIR" -type f -mtime +"$RETENTION_DAYS")
    do
    rm -f "$old_file"
    done
    
    write_line "[INFO] 已清理超过 $RETENTION_DAYS 天的历史文件"
}
