#!/usr/bin/bash

set -u

BACKUP_DIR="/opt/server_ops/backups"
RESTORE_DIR="/opt/server_ops/restore"
OLD_DIR="/opt/server_ops/backups/old_configs"

BACKUP_FILE=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -n 1)

TEMP_DIR="$RESTORE_DIR/restore_$(date '+%Y-%m-%d_%H%M%S')"

prepare_restore() {
    if [ -z "$BACKUP_FILE" ]; then
        echo "ERROR: 没有找到备份文件"
        return 1
    fi

    echo "使用备份文件：$BACKUP_FILE"

    mkdir -p "$TEMP_DIR"
    mkdir -p "$OLD_DIR"

    tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

    if [ "$?" != "0" ]; then
        echo "ERROR: 备份文件解压失败"
        return 1
    fi
}

restore_one_file() {
    echo "1. conf/server_ops.conf"
    echo "2. conf/SYSTEMCTL_NAME.conf"
    echo "3. conf/VAR_LOG_NAME.conf"
    echo "4. conf/Shell_function.conf"
    echo "5. bin/main.sh"
    echo "6. bin/check.sh"
    echo "7. bin/backup.sh"
    echo "8. bin/cleanup.sh"
    echo "9. bin/menu_bar.sh"

    read -p "请选择文件：" FILE_NUM

    case "$FILE_NUM" in
    1) FILE_NAME="conf/server_ops.conf"; OLD_NAME="server_ops.conf" ;;
    2) FILE_NAME="conf/SYSTEMCTL_NAME.conf"; OLD_NAME="SYSTEMCTL_NAME.conf" ;;
    3) FILE_NAME="conf/VAR_LOG_NAME.conf"; OLD_NAME="VAR_LOG_NAME.conf" ;;
    4) FILE_NAME="conf/Shell_function.conf"; OLD_NAME="Shell_function.conf" ;;
    5) FILE_NAME="bin/main.sh"; OLD_NAME="main.sh" ;;
    6) FILE_NAME="bin/check.sh"; OLD_NAME="check.sh" ;;
    7) FILE_NAME="bin/backup.sh"; OLD_NAME="backup.sh" ;;
    8) FILE_NAME="bin/cleanup.sh"; OLD_NAME="cleanup.sh" ;;
    9) FILE_NAME="bin/menu_bar.sh"; OLD_NAME="menu_bar.sh" ;;
    *) echo "输入错误"; return 1 ;;
    esac

    SOURCE_FILE="$TEMP_DIR/opt/server_ops/$FILE_NAME"

    TARGET_FILE="/opt/server_ops/$FILE_NAME"

    OLD_FILE="$OLD_DIR/${OLD_NAME}.old_$(date '+%Y-%m-%d_%H%M%S')"

    if [ ! -f "$SOURCE_FILE" ]; then
        echo "ERROR: 备份中没有找到文件：$FILE_NAME"
        return 1
    fi

    if [ -f "$TARGET_FILE" ]; then
        cp "$TARGET_FILE" "$OLD_FILE"

        if [ "$?" != "0" ]; then
            echo "ERROR: 当前文件备份失败"
            return 1
        fi
    else
        echo "当前文件不存在，跳过旧文件备份：$TARGET_FILE"
    fi

    cp "$SOURCE_FILE" "$TARGET_FILE"

    if [ "$?" != "0" ]; then
        echo "ERROR: 文件恢复失败：$TARGET_FILE"
        return 1
    fi

    echo "单个文件恢复成功：$TARGET_FILE"
    echo "旧文件保存位置：$OLD_FILE"
}

restore_conf() {
    SOURCE_DIR="$TEMP_DIR/opt/server_ops/conf"

    TARGET_DIR="/opt/server_ops/conf"

    OLD_DIRECTORY="$OLD_DIR/conf_old_$(date '+%Y-%m-%d_%H%M%S')"

    if [ ! -d "$SOURCE_DIR" ]; then
        echo "ERROR: 备份中没有找到 conf 目录"
        return 1
    fi

    if [ -d "$TARGET_DIR" ]; then
        mv "$TARGET_DIR" "$OLD_DIRECTORY"

        if [ "$?" != "0" ]; then
            echo "ERROR: 当前 conf 目录存档失败"
            return 1
        fi
    else
        echo "当前 conf 目录不存在，跳过旧目录存档：$TARGET_DIR"
    fi

    cp -r "$SOURCE_DIR" "$TARGET_DIR"

    if [ "$?" != "0" ]; then
        echo "ERROR: conf 目录恢复失败"
        return 1
    fi

    echo "conf 目录恢复成功：$TARGET_DIR"
    echo "旧目录保存位置：$OLD_DIRECTORY"
}

restore_bin() {
    SOURCE_DIR="$TEMP_DIR/opt/server_ops/bin"

    TARGET_DIR="/opt/server_ops/bin"

    OLD_DIRECTORY="$OLD_DIR/bin_old_$(date '+%Y-%m-%d_%H%M%S')"

    if [ ! -d "$SOURCE_DIR" ]; then
        echo "ERROR: 备份中没有找到 bin 目录"
        return 1
    fi

    mkdir -p "$OLD_DIRECTORY"

    for file_name in main.sh check.sh backup.sh cleanup.sh menu_bar.sh
    do
        if [ -f "$TARGET_DIR/$file_name" ]; then
            cp "$TARGET_DIR/$file_name" "$OLD_DIRECTORY/$file_name"
        fi

        if [ ! -f "$SOURCE_DIR/$file_name" ]; then
            echo "ERROR: 备份中没有找到脚本：$file_name"
            return 1
        fi

        cp "$SOURCE_DIR/$file_name" "$TARGET_DIR/$file_name"
    done

    echo "bin 目录脚本恢复成功"
    echo "restore.sh 未被覆盖"
    echo "旧脚本保存位置：$OLD_DIRECTORY"
}

restore_menu() {
    echo "1. 恢复单个文件"
    echo "2. 恢复整个 conf 目录"
    echo "3. 恢复 bin 目录脚本"
    echo "4. 退出"

    read -p "请输入选择：" NUM

    case "$NUM" in
    1) restore_one_file ;;
    2) restore_conf ;;
    3) restore_bin ;;
    4) echo "已退出" ;;
    *) echo "请输入 1、2、3 或 4"; return 1 ;;
    esac
}

if prepare_restore; then
    restore_menu
else
    exit 1
fi
