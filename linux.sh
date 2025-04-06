#!/bin/bash

# Linux系统管理脚本

# 脚本版本号
SCRIPT_VERSION="1.0.0"

# 设置终端颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # 恢复默认颜色

# 确保脚本能从任何位置运行
ensure_script_location() {
    # 获取脚本的绝对路径
    SCRIPT_PATH=$(readlink -f "$0")
    # 获取脚本所在目录
    SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
    
    # 如果当前目录不是脚本所在目录，则切换
    if [ "$PWD" != "$SCRIPT_DIR" ]; then
        echo -e "${YELLOW}切换到脚本所在目录: ${SCRIPT_DIR}${NC}"
        cd "$SCRIPT_DIR"
        
        # 检查是否成功切换目录
        if [ $? -ne 0 ]; then
            echo -e "${RED}错误: 无法切换到脚本目录 ${SCRIPT_DIR}${NC}"
            echo -e "${YELLOW}脚本可能无法正常工作...${NC}"
            sleep 2
        else
            echo -e "${GREEN}已切换到: $(pwd)${NC}"
            sleep 1
        fi
    fi
}

# 显示系统详细信息
show_system_info() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      系统详细信息       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 操作系统信息
    echo -e "${BLUE}操作系统信息:${NC}"
    echo -e "${GREEN}-----------------------------${NC}"
    
    # 获取发行版信息
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION
        OS_ID=$ID
    else
        OS_NAME=$(uname -s)
        OS_VERSION=$(uname -r)
        OS_ID="unknown"
    fi
    
    echo -e "发行版名称: ${YELLOW}$OS_NAME${NC}"
    echo -e "发行版版本: ${YELLOW}$OS_VERSION${NC}"
    echo -e "发行版ID: ${YELLOW}$OS_ID${NC}"
    echo -e "内核版本: ${YELLOW}$(uname -r)${NC}"
    echo -e "主机名: ${YELLOW}$(hostname)${NC}"
    echo -e "架构: ${YELLOW}$(uname -m)${NC}"
    
    echo ""
    
    # CPU信息
    echo -e "${BLUE}CPU信息:${NC}"
    echo -e "${GREEN}-----------------------------${NC}"
    
    # CPU型号
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//')
    CPU_CORES=$(grep -c "processor" /proc/cpuinfo)
    
    echo -e "CPU型号: ${YELLOW}$CPU_MODEL${NC}"
    echo -e "CPU核心数: ${YELLOW}$CPU_CORES${NC}"
    
    # CPU负载
    LOAD=$(cat /proc/loadavg | awk '{print $1", "$2", "$3}')
    echo -e "系统负载 (1, 5, 15分钟): ${YELLOW}$LOAD${NC}"
    
    echo ""
    
    # 内存信息
    echo -e "${BLUE}内存信息:${NC}"
    echo -e "${GREEN}-----------------------------${NC}"
    
    if command -v free &> /dev/null; then
        # 总内存
        MEM_TOTAL=$(free -h | grep "Mem:" | awk '{print $2}')
        # 已用内存
        MEM_USED=$(free -h | grep "Mem:" | awk '{print $3}')
        # 可用内存
        MEM_AVAIL=$(free -h | grep "Mem:" | awk '{print $7}')
        # 内存使用率
        MEM_USAGE_PERCENT=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
        
        echo -e "总内存: ${YELLOW}$MEM_TOTAL${NC}"
        echo -e "已用内存: ${YELLOW}$MEM_USED${NC}"
        echo -e "可用内存: ${YELLOW}$MEM_AVAIL${NC}"
        echo -e "内存使用率: ${YELLOW}$MEM_USAGE_PERCENT%${NC}"
        
        # SWAP信息
        SWAP_TOTAL=$(free -h | grep "Swap:" | awk '{print $2}')
        SWAP_USED=$(free -h | grep "Swap:" | awk '{print $3}')
        
        echo -e "Swap总量: ${YELLOW}$SWAP_TOTAL${NC}"
        echo -e "Swap已用: ${YELLOW}$SWAP_USED${NC}"
    else
        echo -e "${RED}无法获取内存信息: free命令不可用${NC}"
    fi
    
    echo ""
    
    # 磁盘信息
    echo -e "${BLUE}磁盘信息:${NC}"
    echo -e "${GREEN}-----------------------------${NC}"
    
    if command -v df &> /dev/null; then
        echo -e "分区使用情况:"
        df -h | grep -v "tmpfs" | grep -v "udev" | grep -v "loop" | awk 'NR>1 {print "  "$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}'
    else
        echo -e "${RED}无法获取磁盘信息: df命令不可用${NC}"
    fi
    
    echo ""
    
    # 网络信息
    echo -e "${BLUE}网络信息:${NC}"
    echo -e "${GREEN}-----------------------------${NC}"
    
    if command -v ip &> /dev/null; then
        # 获取默认网关
        DEFAULT_ROUTE=$(ip route | grep default | awk '{print $3}')
        echo -e "默认网关: ${YELLOW}$DEFAULT_ROUTE${NC}"
        
        # 获取网络接口信息
        echo -e "网络接口信息:"
        ip -o addr show | grep -v "lo\|docker\|br-\|veth" | awk '{split($4, a, "/"); print "  "$2": "a[1]}'
    elif command -v ifconfig &> /dev/null; then
        # 如果ip命令不可用，尝试使用ifconfig
        echo -e "网络接口信息:"
        ifconfig | grep -E "^[a-zA-Z0-9]+" | awk '{print $1}' | while read iface; do
            if [[ "$iface" != "lo" && ! "$iface" =~ ^(docker|br-|veth) ]]; then
                IP=$(ifconfig $iface | grep "inet " | awk '{print $2}')
                if [ ! -z "$IP" ]; then
                    echo "  $iface: $IP"
                fi
            fi
        done
    else
        echo -e "${RED}无法获取网络信息: ip和ifconfig命令都不可用${NC}"
    fi
    
    # 获取公网IP地址
    if command -v curl &> /dev/null; then
        echo -e "正在获取公网IP地址..."
        PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://icanhazip.com || curl -s https://ifconfig.me)
        if [ ! -z "$PUBLIC_IP" ]; then
            echo -e "公网IP: ${YELLOW}$PUBLIC_IP${NC}"
        else
            echo -e "${RED}无法获取公网IP地址${NC}"
        fi
    else
        echo -e "${RED}无法获取公网IP地址: curl命令不可用${NC}"
    fi
    
    echo ""
    
    # 系统运行时间
    echo -e "${BLUE}系统运行时间:${NC}"
    echo -e "${GREEN}-----------------------------${NC}"
    
    if command -v uptime &> /dev/null; then
        UPTIME_INFO=$(uptime -p)
        echo -e "${YELLOW}$UPTIME_INFO${NC}"
    else
        UPTIME_SEC=$(cat /proc/uptime | awk '{print $1}')
        UPTIME_DAYS=$((${UPTIME_SEC%.*}/86400))
        UPTIME_HOURS=$(((${UPTIME_SEC%.*}%86400)/3600))
        UPTIME_MINUTES=$(((${UPTIME_SEC%.*}%3600)/60))
        
        echo -e "${YELLOW}系统已运行: $UPTIME_DAYS 天 $UPTIME_HOURS 小时 $UPTIME_MINUTES 分钟${NC}"
    fi
    
    # 获取系统最后一次启动时间
    if command -v who &> /dev/null; then
        LAST_BOOT=$(who -b | awk '{print $3" "$4}')
        echo -e "上次启动时间: ${YELLOW}$LAST_BOOT${NC}"
    fi
    
    echo ""
    
    # 进程信息
    echo -e "${BLUE}进程信息:${NC}"
    echo -e "${GREEN}-----------------------------${NC}"
    
    # 运行进程数量
    PROCESS_COUNT=$(ps aux | wc -l)
    echo -e "运行中的进程数: ${YELLOW}$((PROCESS_COUNT-1))${NC}"
    
    # 根进程列表
    echo -e "主要系统服务:"
    ps -eo comm,pcpu,pmem --sort=-pcpu | grep -v "ps\|grep" | head -n 5 | awk '{printf "  %-20s CPU: %.1f%%  MEM: %.1f%%\n", $1, $2, $3}'
    
    echo ""
    echo -e "${GREEN}=============================${NC}"
    
    # 等待用户输入任意键返回
    read -p "按任意键返回..." -n1
    show_main_menu
}

# 显示主菜单
show_main_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}     Linux 系统管理工具     ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "${YELLOW}      版本: ${SCRIPT_VERSION}      ${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} 查看系统详细信息"
    echo -e "${BLUE}0.${NC} 退出"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-1]: " choice

    case $choice in
        1)
            show_system_info
            ;;
        0)
            echo "谢谢使用，再见！"
            exit 0
            ;;
        *)
            echo "无效选择，请重试"
            sleep 1
            show_main_menu
            ;;
    esac
}

# 主程序入口点
main() {
    # 确保脚本从正确的目录运行
    ensure_script_location
    
    # 显示主菜单
    show_main_menu
}

# 执行主程序
main
