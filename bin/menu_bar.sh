#!/usr/bin/bash
Select_Modile(){
    echo "1 --check"
    echo "2 --backup"
    echo "3 --cleanup"

    local NUM
    read -p "输入执行模块"  NUM

    case "$NUM" in
    1)
        check_basic_info
        check_cpu
        check_memory
        check_disk
        check_large_files
        check_services
        analyze_logs
        echo "巡检完成，报告文件：$REPORT_FILE"
    ;;
    2)
        create_backup
    ;;
    3)
        cleanup_old_files
        echo "清理完成"
    ;;
    *)
    echo "输入正确的数字"
    exit 1
    ;;
    esac
}
