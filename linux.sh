#!/bin/bash

# Linux系统管理脚本

# 脚本版本号
SCRIPT_VERSION="1.6.1"
SCRIPT_UPDATE_URL="https://raw.githubusercontent.com/iulove1314520/ASAADSDS/refs/heads/main/linux.sh"

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
    echo -e "${BLUE}2.${NC} 软件源管理"
    echo -e "${BLUE}3.${NC} 防火墙管理"
    echo -e "${BLUE}4.${NC} 检查端口占用"
    echo -e "${BLUE}5.${NC} 检查脚本更新"
    echo -e "${BLUE}0.${NC} 退出"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-5]: " choice

    case $choice in
        1)
            show_system_info
            ;;
        2)
            package_manager_menu
            ;;
        3)
            firewall_menu
            ;;
        4)
            port_check_menu
            ;;
        5)
            update_script
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

# 软件源管理菜单
package_manager_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}       软件源管理       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} 更新系统(更新+升级)"
    echo -e "${BLUE}2.${NC} 仅更新软件包列表"
    echo -e "${BLUE}3.${NC} 仅升级软件包"
    echo -e "${BLUE}4.${NC} 切换软件源镜像"
    echo -e "${BLUE}0.${NC} 返回主菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-4]: " choice

    case $choice in
        1)
            update_and_upgrade
            ;;
        2)
            update_package_list
            ;;
        3)
            upgrade_packages
            ;;
        4)
            change_mirrors_menu
            ;;
        0)
            show_main_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            package_manager_menu
            ;;
    esac
}

# 切换软件源镜像菜单
change_mirrors_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      切换软件源镜像      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} 中国大陆软件源"
    echo -e "${BLUE}2.${NC} 境外软件源"
    echo -e "${BLUE}0.${NC} 返回上级菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-2]: " choice

    case $choice in
        1)
            change_mirrors_china
            ;;
        2)
            change_mirrors_abroad
            ;;
        0)
            package_manager_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            change_mirrors_menu
            ;;
    esac
}

# 切换中国大陆软件源
change_mirrors_china() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}     切换中国大陆软件源     ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${YELLOW}请选择中国大陆软件源:${NC}"
    echo -e "${BLUE}1.${NC} Gitee源 (推荐，国内访问速度快)"
    echo -e "${BLUE}2.${NC} GitHub源 (通过curl方式)"
    echo -e "${BLUE}3.${NC} Gitee源 (通过curl方式)"
    echo -e "${BLUE}0.${NC} 返回上级菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-3]: " choice

    case $choice in
        1)
            echo -e "${YELLOW}正在使用Gitee源切换软件源...${NC}"
            echo -e "${GREEN}执行: bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh)${NC}"
            echo ""
            # 确认执行
            read -p "确定要执行此操作吗? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh)
                echo ""
                echo -e "${GREEN}操作完成${NC}"
                read -p "按任意键返回..." -n1
            else
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
            fi
            change_mirrors_china
            ;;
        2)
            echo -e "${YELLOW}正在使用GitHub源切换软件源...${NC}"
            echo -e "${GREEN}执行: bash <(curl -sSL https://raw.githubusercontent.com/SuperManito/LinuxMirrors/main/ChangeMirrors.sh)${NC}"
            echo ""
            # 确认执行
            read -p "确定要执行此操作吗? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                bash <(curl -sSL https://raw.githubusercontent.com/SuperManito/LinuxMirrors/main/ChangeMirrors.sh)
                echo ""
                echo -e "${GREEN}操作完成${NC}"
                read -p "按任意键返回..." -n1
            else
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
            fi
            change_mirrors_china
            ;;
        3)
            echo -e "${YELLOW}正在使用Gitee源(curl方式)切换软件源...${NC}"
            echo -e "${GREEN}执行: bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh)${NC}"
            echo ""
            # 确认执行
            read -p "确定要执行此操作吗? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh)
                echo ""
                echo -e "${GREEN}操作完成${NC}"
                read -p "按任意键返回..." -n1
            else
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
            fi
            change_mirrors_china
            ;;
        0)
            change_mirrors_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            change_mirrors_china
            ;;
    esac
}

# 切换境外软件源
change_mirrors_abroad() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      切换境外软件源      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${YELLOW}请选择境外软件源:${NC}"
    echo -e "${BLUE}1.${NC} LinuxMirrors.cn源"
    echo -e "${BLUE}2.${NC} GitHub源 (--abroad参数)"
    echo -e "${BLUE}3.${NC} Gitee源 (--abroad参数)"
    echo -e "${BLUE}0.${NC} 返回上级菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-3]: " choice

    case $choice in
        1)
            echo -e "${YELLOW}正在使用LinuxMirrors.cn源切换境外软件源...${NC}"
            echo -e "${GREEN}执行: bash <(curl -sSL https://linuxmirrors.cn/main.sh) --abroad${NC}"
            echo ""
            # 确认执行
            read -p "确定要执行此操作吗? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                bash <(curl -sSL https://linuxmirrors.cn/main.sh) --abroad
                echo ""
                echo -e "${GREEN}操作完成${NC}"
                read -p "按任意键返回..." -n1
            else
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
            fi
            change_mirrors_abroad
            ;;
        2)
            echo -e "${YELLOW}正在使用GitHub源切换境外软件源...${NC}"
            echo -e "${GREEN}执行: bash <(curl -sSL https://raw.githubusercontent.com/SuperManito/LinuxMirrors/main/ChangeMirrors.sh) --abroad${NC}"
            echo ""
            # 确认执行
            read -p "确定要执行此操作吗? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                bash <(curl -sSL https://raw.githubusercontent.com/SuperManito/LinuxMirrors/main/ChangeMirrors.sh) --abroad
                echo ""
                echo -e "${GREEN}操作完成${NC}"
                read -p "按任意键返回..." -n1
            else
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
            fi
            change_mirrors_abroad
            ;;
        3)
            echo -e "${YELLOW}正在使用Gitee源切换境外软件源...${NC}"
            echo -e "${GREEN}执行: bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh) --abroad${NC}"
            echo ""
            # 确认执行
            read -p "确定要执行此操作吗? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh) --abroad
                echo ""
                echo -e "${GREEN}操作完成${NC}"
                read -p "按任意键返回..." -n1
            else
                echo -e "${YELLOW}操作已取消${NC}"
                sleep 1
            fi
            change_mirrors_abroad
            ;;
        0)
            change_mirrors_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            change_mirrors_abroad
            ;;
    esac
}

# 检测并返回包管理器类型
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v apt-get &> /dev/null; then
        echo "apt-get"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# 更新软件包列表
update_package_list() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      更新软件包列表      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测包管理器类型
    PACKAGE_MANAGER=$(detect_package_manager)
    
    echo -e "${YELLOW}检测到的包管理器: $PACKAGE_MANAGER${NC}"
    echo ""
    
    case $PACKAGE_MANAGER in
        apt|apt-get)
            echo -e "${YELLOW}正在更新 APT 软件包列表...${NC}"
            echo -e "${GREEN}执行: sudo $PACKAGE_MANAGER update${NC}"
            echo ""
            sudo $PACKAGE_MANAGER update
            ;;
        dnf|yum)
            echo -e "${YELLOW}正在更新 DNF/YUM 软件包列表...${NC}"
            echo -e "${GREEN}执行: sudo $PACKAGE_MANAGER check-update${NC}"
            echo ""
            sudo $PACKAGE_MANAGER check-update
            ;;
        zypper)
            echo -e "${YELLOW}正在更新 Zypper 软件包列表...${NC}"
            echo -e "${GREEN}执行: sudo zypper refresh${NC}"
            echo ""
            sudo zypper refresh
            ;;
        pacman)
            echo -e "${YELLOW}正在更新 Pacman 软件包列表...${NC}"
            echo -e "${GREEN}执行: sudo pacman -Sy${NC}"
            echo ""
            sudo pacman -Sy
            ;;
        *)
            echo -e "${RED}错误: 无法识别的包管理器，无法更新软件包列表。${NC}"
            echo -e "${RED}此功能支持 apt、apt-get、dnf、yum、zypper 和 pacman。${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}操作完成${NC}"
    
    read -p "按任意键返回..." -n1
    package_manager_menu
}

# 升级所有软件包
upgrade_packages() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      升级所有软件包      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测包管理器类型
    PACKAGE_MANAGER=$(detect_package_manager)
    
    echo -e "${YELLOW}检测到的包管理器: $PACKAGE_MANAGER${NC}"
    echo ""
    
    # 确认升级
    read -p "确定要升级所有软件包吗? 这可能需要一些时间 (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo -e "${YELLOW}升级已取消${NC}"
        read -p "按任意键返回..." -n1
        package_manager_menu
        return
    fi
    
    echo ""
    
    case $PACKAGE_MANAGER in
        apt|apt-get)
            echo -e "${YELLOW}正在升级所有 APT 软件包...${NC}"
            echo -e "${GREEN}执行: sudo $PACKAGE_MANAGER upgrade -y${NC}"
            echo ""
            sudo $PACKAGE_MANAGER upgrade -y
            ;;
        dnf)
            echo -e "${YELLOW}正在升级所有 DNF 软件包...${NC}"
            echo -e "${GREEN}执行: sudo dnf upgrade -y${NC}"
            echo ""
            sudo dnf upgrade -y
            ;;
        yum)
            echo -e "${YELLOW}正在升级所有 YUM 软件包...${NC}"
            echo -e "${GREEN}执行: sudo yum update -y${NC}"
            echo ""
            sudo yum update -y
            ;;
        zypper)
            echo -e "${YELLOW}正在升级所有 Zypper 软件包...${NC}"
            echo -e "${GREEN}执行: sudo zypper update -y${NC}"
            echo ""
            sudo zypper update -y
            ;;
        pacman)
            echo -e "${YELLOW}正在升级所有 Pacman 软件包...${NC}"
            echo -e "${GREEN}执行: sudo pacman -Syu --noconfirm${NC}"
            echo ""
            sudo pacman -Syu --noconfirm
            ;;
        *)
            echo -e "${RED}错误: 无法识别的包管理器，无法升级软件包。${NC}"
            echo -e "${RED}此功能支持 apt、apt-get、dnf、yum、zypper 和 pacman。${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}升级操作完成${NC}"
    
    read -p "按任意键返回..." -n1
    package_manager_menu
}

# 检查脚本更新
update_script() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      检查脚本更新      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    echo -e "${YELLOW}当前版本: ${SCRIPT_VERSION}${NC}"
    echo -e "${YELLOW}正在检查更新...${NC}"
    echo ""
    
    # 检查是否安装了curl
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}错误: curl 未安装，无法检查更新。${NC}"
        echo -e "${YELLOW}请先安装 curl 再尝试更新。${NC}"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    # 创建临时文件
    TMP_FILE=$(mktemp)
    
    # 下载最新版本的脚本
    if ! curl -s "$SCRIPT_UPDATE_URL" -o "$TMP_FILE"; then
        echo -e "${RED}错误: 无法连接到更新服务器。${NC}"
        echo -e "${YELLOW}请检查您的网络连接或稍后再试。${NC}"
        rm -f "$TMP_FILE"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    # 检查下载的文件是否为空或太小
    if [ ! -s "$TMP_FILE" ] || [ $(wc -c < "$TMP_FILE") -lt 100 ]; then
        echo -e "${RED}错误: 下载的文件无效或为空。${NC}"
        rm -f "$TMP_FILE"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    # 获取新版本号
    NEW_VERSION=$(grep "SCRIPT_VERSION=" "$TMP_FILE" | head -n 1 | cut -d'"' -f2)
    
    if [ -z "$NEW_VERSION" ]; then
        echo -e "${RED}错误: 无法解析脚本版本号。${NC}"
        rm -f "$TMP_FILE"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    echo -e "${YELLOW}最新版本: ${NEW_VERSION}${NC}"
    echo ""
    
    # 比较版本号 (使用更可靠的比较方法)
    # 将版本号拆分为主要部分并比较
    local CURRENT_MAJOR=$(echo "$SCRIPT_VERSION" | cut -d. -f1)
    local CURRENT_MINOR=$(echo "$SCRIPT_VERSION" | cut -d. -f2)
    local CURRENT_PATCH=$(echo "$SCRIPT_VERSION" | cut -d. -f3)
    
    local NEW_MAJOR=$(echo "$NEW_VERSION" | cut -d. -f1)
    local NEW_MINOR=$(echo "$NEW_VERSION" | cut -d. -f2)
    local NEW_PATCH=$(echo "$NEW_VERSION" | cut -d. -f3)
    
    local UPDATE_AVAILABLE=false
    
    # 检查新版本是否大于当前版本
    if [ "$NEW_MAJOR" -gt "$CURRENT_MAJOR" ]; then
        UPDATE_AVAILABLE=true
    elif [ "$NEW_MAJOR" -eq "$CURRENT_MAJOR" ] && [ "$NEW_MINOR" -gt "$CURRENT_MINOR" ]; then
        UPDATE_AVAILABLE=true
    elif [ "$NEW_MAJOR" -eq "$CURRENT_MAJOR" ] && [ "$NEW_MINOR" -eq "$CURRENT_MINOR" ] && [ "$NEW_PATCH" -gt "$CURRENT_PATCH" ]; then
        UPDATE_AVAILABLE=true
    fi
    
    if [ "$UPDATE_AVAILABLE" = false ]; then
        echo -e "${GREEN}您已经使用最新版本的脚本!${NC}"
        rm -f "$TMP_FILE"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    # 询问是否更新
    echo -e "${YELLOW}发现新版本!${NC}"
    echo -e "${GREEN}版本 ${SCRIPT_VERSION} -> 版本 ${NEW_VERSION}${NC}"
    echo ""
    echo -e "${BLUE}更新可能包含新功能、性能优化和错误修复。${NC}"
    read -p "是否更新到新版本? (y/n): " update_choice
    
    if [ "$update_choice" != "y" ]; then
        echo -e "${YELLOW}更新已取消${NC}"
        rm -f "$TMP_FILE"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    # 检查当前脚本是否可写
    if [ ! -w "$(readlink -f "$0")" ]; then
        echo -e "${YELLOW}警告: 当前脚本文件不可写，尝试使用sudo权限。${NC}"
        NEED_SUDO=true
    else
        NEED_SUDO=false
    fi
    
    # 备份当前脚本
    BACKUP_FILE="linux.sh.bak.$(date +%Y%m%d%H%M%S)"
    if [ "$NEED_SUDO" = true ]; then
        sudo cp "$(readlink -f "$0")" "$BACKUP_FILE"
    else
        cp "$(readlink -f "$0")" "$BACKUP_FILE"
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: 无法创建备份文件。${NC}"
        rm -f "$TMP_FILE"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    echo -e "${GREEN}已创建备份文件: ${BACKUP_FILE}${NC}"
    
    # 替换当前脚本
    if [ "$NEED_SUDO" = true ]; then
        sudo bash -c "cat \"$TMP_FILE\" > \"$(readlink -f "$0")\""
    else
        cat "$TMP_FILE" > "$(readlink -f "$0")"
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: 无法更新脚本。${NC}"
        echo -e "${YELLOW}尝试恢复备份...${NC}"
        
        if [ "$NEED_SUDO" = true ]; then
            sudo cp "$BACKUP_FILE" "$(readlink -f "$0")"
        else
            cp "$BACKUP_FILE" "$(readlink -f "$0")"
        fi
        
        rm -f "$TMP_FILE"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    # 设置执行权限
    if [ "$NEED_SUDO" = true ]; then
        sudo chmod +x "$(readlink -f "$0")"
    else
        chmod +x "$(readlink -f "$0")"
    fi
    
    echo -e "${GREEN}✅ 脚本已成功更新到版本 ${NEW_VERSION}!${NC}"
    echo -e "${YELLOW}请重新启动脚本以应用更改。${NC}"
    
    # 清理临时文件
    rm -f "$TMP_FILE"
    
    # 询问用户是否立即重启脚本
    read -p "是否立即重启脚本? (y/n): " restart
    if [ "$restart" = "y" ]; then
        echo -e "${GREEN}正在重启脚本...${NC}"
        exec "$(readlink -f "$0")"
        exit 0
    else
        read -p "按任意键返回..." -n1
        show_main_menu
    fi
}

# 更新和升级系统(合并功能)
update_and_upgrade() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      系统更新与升级      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测包管理器类型
    PACKAGE_MANAGER=$(detect_package_manager)
    
    echo -e "${YELLOW}检测到的包管理器: $PACKAGE_MANAGER${NC}"
    echo ""
    
    # 确认更新和升级
    read -p "确定要更新软件包列表并升级所有软件包吗? 这可能需要一些时间 (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo -e "${YELLOW}操作已取消${NC}"
        read -p "按任意键返回..." -n1
        package_manager_menu
        return
    fi
    
    echo ""
    
    case $PACKAGE_MANAGER in
        apt|apt-get)
            echo -e "${YELLOW}步骤1: 正在更新 APT 软件包列表...${NC}"
            echo -e "${GREEN}执行: sudo $PACKAGE_MANAGER update${NC}"
            echo ""
            sudo $PACKAGE_MANAGER update
            
            echo ""
            echo -e "${YELLOW}步骤2: 正在升级所有 APT 软件包...${NC}"
            echo -e "${GREEN}执行: sudo $PACKAGE_MANAGER upgrade -y${NC}"
            echo ""
            sudo $PACKAGE_MANAGER upgrade -y
            ;;
        dnf)
            echo -e "${YELLOW}正在执行 DNF 更新和升级...${NC}"
            echo -e "${GREEN}执行: sudo dnf upgrade -y${NC}"
            echo ""
            # DNF会自动更新软件包列表然后升级
            sudo dnf upgrade -y
            ;;
        yum)
            echo -e "${YELLOW}步骤1: 正在更新 YUM 软件包列表...${NC}"
            echo -e "${GREEN}执行: sudo yum check-update${NC}"
            echo ""
            sudo yum check-update
            
            echo ""
            echo -e "${YELLOW}步骤2: 正在升级所有 YUM 软件包...${NC}"
            echo -e "${GREEN}执行: sudo yum update -y${NC}"
            echo ""
            sudo yum update -y
            ;;
        zypper)
            echo -e "${YELLOW}步骤1: 正在更新 Zypper 软件包列表...${NC}"
            echo -e "${GREEN}执行: sudo zypper refresh${NC}"
            echo ""
            sudo zypper refresh
            
            echo ""
            echo -e "${YELLOW}步骤2: 正在升级所有 Zypper 软件包...${NC}"
            echo -e "${GREEN}执行: sudo zypper update -y${NC}"
            echo ""
            sudo zypper update -y
            ;;
        pacman)
            echo -e "${YELLOW}正在执行 Pacman 更新和升级...${NC}"
            echo -e "${GREEN}执行: sudo pacman -Syu --noconfirm${NC}"
            echo ""
            # Pacman的-Syu参数会同时更新软件包列表和升级系统
            sudo pacman -Syu --noconfirm
            ;;
        *)
            echo -e "${RED}错误: 无法识别的包管理器，无法更新和升级系统。${NC}"
            echo -e "${RED}此功能支持 apt、apt-get、dnf、yum、zypper 和 pacman。${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}系统更新与升级操作完成${NC}"
    
    # 询问是否重启系统
    echo ""
    read -p "升级后通常建议重启系统，是否现在重启? (y/n): " reboot_choice
    if [[ "$reboot_choice" == "y" ]]; then
        echo -e "${YELLOW}系统将在5秒后重启...${NC}"
        sleep 5
        sudo reboot
    else
        echo -e "${YELLOW}您选择了不重启系统。如有必要，请稍后手动重启。${NC}"
        read -p "按任意键返回..." -n1
        package_manager_menu
    fi
}

# 检测防火墙类型
detect_firewall() {
    if command -v ufw &> /dev/null && ufw status &> /dev/null; then
        echo "ufw"
    elif command -v firewalld &> /dev/null && systemctl is-active --quiet firewalld; then
        echo "firewalld"
    elif command -v iptables &> /dev/null; then
        echo "iptables"
    else
        echo "unknown"
    fi
}

# 获取防火墙状态
get_firewall_status() {
    local firewall_type=$1
    
    case $firewall_type in
        ufw)
            if ufw status | grep -q "Status: active"; then
                echo "active"
            else
                echo "inactive"
            fi
            ;;
        firewalld)
            if systemctl is-active --quiet firewalld; then
                echo "active"
            else
                echo "inactive"
            fi
            ;;
        iptables)
            # 检查iptables是否有任何规则(简化判断)
            if iptables -L -n | grep -q "Chain"; then
                echo "active"
            else
                echo "inactive"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# 防火墙管理菜单
firewall_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}       防火墙管理       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测防火墙类型
    FIREWALL_TYPE=$(detect_firewall)
    FIREWALL_STATUS=$(get_firewall_status "$FIREWALL_TYPE")
    
    echo -e "${YELLOW}检测到的防火墙: $FIREWALL_TYPE${NC}"
    
    if [ "$FIREWALL_STATUS" == "active" ]; then
        echo -e "当前状态: ${GREEN}已启用${NC}"
    elif [ "$FIREWALL_STATUS" == "inactive" ]; then
        echo -e "当前状态: ${RED}已禁用${NC}"
    else
        echo -e "当前状态: ${YELLOW}未知${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}1.${NC} 关闭防火墙"
    echo -e "${BLUE}2.${NC} 开启防火墙"
    echo -e "${BLUE}3.${NC} 查看防火墙状态"
    echo -e "${BLUE}4.${NC} 管理防火墙端口"
    echo -e "${BLUE}5.${NC} 定时关闭后自动恢复"
    echo -e "${BLUE}0.${NC} 返回主菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-5]: " choice

    case $choice in
        1)
            disable_firewall
            ;;
        2)
            enable_firewall
            ;;
        3)
            check_firewall_status
            ;;
        4)
            manage_firewall_ports
            ;;
        5)
            timed_firewall_disable
            ;;
        0)
            show_main_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            firewall_menu
            ;;
    esac
}

# 关闭防火墙
disable_firewall() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}       关闭防火墙       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测防火墙类型
    FIREWALL_TYPE=$(detect_firewall)
    FIREWALL_STATUS=$(get_firewall_status "$FIREWALL_TYPE")
    
    if [ "$FIREWALL_TYPE" == "unknown" ]; then
        echo -e "${RED}错误: 未检测到支持的防火墙程序。${NC}"
        echo -e "${YELLOW}支持的防火墙包括: ufw, firewalld, iptables${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    if [ "$FIREWALL_STATUS" == "inactive" ]; then
        echo -e "${YELLOW}防火墙 ($FIREWALL_TYPE) 当前已处于关闭状态。${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    # 显示关闭选项
    echo -e "${RED}┌─────────────────────────────────────────┐${NC}"
    echo -e "${RED}│         ⚠️ 安全警告 - 请注意 ⚠️         │${NC}"
    echo -e "${RED}└─────────────────────────────────────────┘${NC}"
    echo -e "${YELLOW}关闭防火墙将使您的系统直接暴露在互联网上，可能导致以下风险:${NC}"
    echo -e " - ${RED}未经授权的访问${NC}"
    echo -e " - ${RED}恶意攻击(如DDoS)${NC}"
    echo -e " - ${RED}数据泄露或丢失${NC}"
    echo -e " - ${RED}系统被入侵的风险${NC}"
    echo ""
    echo -e "${BLUE}请选择关闭防火墙的方式:${NC}"
    echo -e "${BLUE}1.${NC} 永久关闭防火墙 ${RED}(不推荐)${NC}"
    echo -e "${BLUE}2.${NC} 临时关闭防火墙 ${YELLOW}(系统重启后自动恢复)${NC}"
    echo -e "${BLUE}0.${NC} 取消并返回"
    echo ""
    read -p "请选择操作 [0-2]: " disable_choice
    
    case $disable_choice in
        1)
            permanently_disable_firewall
            ;;
        2)
            temporarily_disable_firewall
            ;;
        0|"")
            echo -e "${GREEN}操作已取消，防火墙保持开启状态${NC}"
            read -p "按任意键返回..." -n1
            firewall_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            disable_firewall
            ;;
    esac
}

# 永久关闭防火墙
permanently_disable_firewall() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${RED}     永久关闭防火墙     ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 二次确认
    echo -e "${RED}⚠️ 警告: 您正在尝试永久关闭防火墙!${NC}"
    echo -e "${YELLOW}这将禁用系统启动时的防火墙服务，使您的系统持续暴露在安全风险中。${NC}"
    echo -e "${YELLOW}即使系统重启，防火墙也不会自动启用。${NC}"
    echo ""
    echo -e "${RED}请输入 \"我确认关闭防火墙\" 以继续操作:${NC}"
    read confirm_text
    
    if [ "$confirm_text" != "我确认关闭防火墙" ]; then
        echo -e "${GREEN}操作已取消，防火墙保持开启状态${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    echo ""
    echo -e "${YELLOW}正在永久关闭防火墙...${NC}"
    
    case $FIREWALL_TYPE in
        ufw)
            echo -e "${GREEN}执行: sudo ufw disable${NC}"
            echo ""
            sudo ufw disable
            # 确保开机不启动
            echo -e "${GREEN}执行: sudo systemctl disable ufw${NC}"
            sudo systemctl disable ufw
            ;;
        firewalld)
            echo -e "${GREEN}执行: sudo systemctl stop firewalld${NC}"
            echo ""
            sudo systemctl stop firewalld
            echo -e "${GREEN}执行: sudo systemctl disable firewalld${NC}"
            sudo systemctl disable firewalld
            ;;
        iptables)
            echo -e "${GREEN}正在清空 IPTables 规则...${NC}"
            echo ""
            echo -e "${GREEN}执行: sudo iptables -F${NC}"
            sudo iptables -F
            echo -e "${GREEN}执行: sudo iptables -X${NC}"
            sudo iptables -X
            echo -e "${GREEN}执行: sudo iptables -t nat -F${NC}"
            sudo iptables -t nat -F
            echo -e "${GREEN}执行: sudo iptables -t nat -X${NC}"
            sudo iptables -t nat -X
            echo -e "${GREEN}执行: sudo iptables -t mangle -F${NC}"
            sudo iptables -t mangle -F
            echo -e "${GREEN}执行: sudo iptables -t mangle -X${NC}"
            sudo iptables -t mangle -X
            echo -e "${GREEN}执行: sudo iptables -P INPUT ACCEPT${NC}"
            sudo iptables -P INPUT ACCEPT
            echo -e "${GREEN}执行: sudo iptables -P FORWARD ACCEPT${NC}"
            sudo iptables -P FORWARD ACCEPT
            echo -e "${GREEN}执行: sudo iptables -P OUTPUT ACCEPT${NC}"
            sudo iptables -P OUTPUT ACCEPT
            
            # 禁用iptables服务（如果存在）
            if systemctl list-unit-files | grep -q "iptables.service"; then
                echo -e "${GREEN}执行: sudo systemctl disable iptables${NC}"
                sudo systemctl disable iptables
            fi
            
            # 保存iptables设置
            if command -v iptables-save &> /dev/null; then
                echo -e "${GREEN}执行: sudo mkdir -p /etc/iptables${NC}"
                sudo mkdir -p /etc/iptables
                echo -e "${GREEN}执行: sudo iptables-save > /etc/iptables/rules.v4${NC}"
                sudo iptables-save > /etc/iptables/rules.v4
            fi
            ;;
    esac
    
    # 检查操作是否成功
    FIREWALL_STATUS_AFTER=$(get_firewall_status "$FIREWALL_TYPE")
    if [ "$FIREWALL_STATUS_AFTER" == "inactive" ]; then
        echo ""
        echo -e "${GREEN}✅ 防火墙已成功永久关闭${NC}"
        echo -e "${YELLOW}注意: 系统将在重启后仍保持防火墙关闭状态${NC}"
    else
        echo ""
        echo -e "${RED}❌ 防火墙关闭操作可能未成功完成${NC}"
        echo -e "${YELLOW}请检查防火墙状态或手动关闭${NC}"
    fi
    
    read -p "按任意键返回..." -n1
    firewall_menu
}

# 临时关闭防火墙
temporarily_disable_firewall() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${YELLOW}     临时关闭防火墙     ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    echo -e "${YELLOW}临时关闭将仅在当前会话中禁用防火墙${NC}"
    echo -e "${GREEN}系统重启后，防火墙将自动恢复为启用状态${NC}"
    echo ""
    read -p "确定要临时关闭防火墙吗? (y/n): " confirm
    
    if [[ "$confirm" != "y" ]]; then
        echo -e "${GREEN}操作已取消，防火墙保持开启状态${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    echo ""
    echo -e "${YELLOW}正在临时关闭防火墙...${NC}"
    
    case $FIREWALL_TYPE in
        ufw)
            echo -e "${GREEN}执行: sudo ufw disable${NC}"
            echo ""
            sudo ufw disable
            # 确保开机仍会启动
            echo -e "${GREEN}执行: sudo systemctl enable ufw${NC}"
            sudo systemctl enable ufw
            ;;
        firewalld)
            echo -e "${GREEN}执行: sudo systemctl stop firewalld${NC}"
            echo ""
            sudo systemctl stop firewalld
            # 确保开机仍会启动
            echo -e "${GREEN}执行: sudo systemctl enable firewalld${NC}"
            sudo systemctl enable firewalld
            ;;
        iptables)
            echo -e "${GREEN}正在临时清空 IPTables 规则...${NC}"
            echo ""
            echo -e "${GREEN}执行: sudo iptables -F${NC}"
            sudo iptables -F
            echo -e "${GREEN}执行: sudo iptables -X${NC}"
            sudo iptables -X
            echo -e "${GREEN}执行: sudo iptables -t nat -F${NC}"
            sudo iptables -t nat -F
            echo -e "${GREEN}执行: sudo iptables -t nat -X${NC}"
            sudo iptables -t nat -X
            echo -e "${GREEN}执行: sudo iptables -t mangle -F${NC}"
            sudo iptables -t mangle -F
            echo -e "${GREEN}执行: sudo iptables -t mangle -X${NC}"
            sudo iptables -t mangle -X
            echo -e "${GREEN}执行: sudo iptables -P INPUT ACCEPT${NC}"
            sudo iptables -P INPUT ACCEPT
            echo -e "${GREEN}执行: sudo iptables -P FORWARD ACCEPT${NC}"
            sudo iptables -P FORWARD ACCEPT
            echo -e "${GREEN}执行: sudo iptables -P OUTPUT ACCEPT${NC}"
            sudo iptables -P OUTPUT ACCEPT
            
            # 确保iptables服务开机仍会启动（如果存在）
            if systemctl list-unit-files | grep -q "iptables.service"; then
                echo -e "${GREEN}执行: sudo systemctl enable iptables${NC}"
                sudo systemctl enable iptables
            fi
            ;;
    esac
    
    # 检查操作是否成功
    FIREWALL_STATUS_AFTER=$(get_firewall_status "$FIREWALL_TYPE")
    if [ "$FIREWALL_STATUS_AFTER" == "inactive" ]; then
        echo ""
        echo -e "${GREEN}✅ 防火墙已成功临时关闭${NC}"
        echo -e "${YELLOW}重要提示: 系统重启后防火墙将自动重新启用${NC}"
    else
        echo ""
        echo -e "${RED}❌ 防火墙关闭操作可能未成功完成${NC}"
        echo -e "${YELLOW}请检查防火墙状态或手动关闭${NC}"
    fi
    
    read -p "按任意键返回..." -n1
    firewall_menu
}

# 开启防火墙
enable_firewall() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}       开启防火墙       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测防火墙类型
    FIREWALL_TYPE=$(detect_firewall)
    
    if [ "$FIREWALL_TYPE" == "unknown" ]; then
        echo -e "${RED}错误: 未检测到支持的防火墙程序。${NC}"
        echo -e "${YELLOW}支持的防火墙包括: ufw, firewalld, iptables${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    echo ""
    
    case $FIREWALL_TYPE in
        ufw)
            echo -e "${YELLOW}正在开启 UFW 防火墙...${NC}"
            echo -e "${GREEN}执行: sudo ufw enable${NC}"
            echo ""
            sudo ufw enable
            ;;
        firewalld)
            echo -e "${YELLOW}正在开启 FirewallD 防火墙...${NC}"
            echo -e "${GREEN}执行: sudo systemctl enable firewalld${NC}"
            echo ""
            sudo systemctl enable firewalld
            echo -e "${GREEN}执行: sudo systemctl start firewalld${NC}"
            sudo systemctl start firewalld
            ;;
        iptables)
            echo -e "${YELLOW}正在开启 IPTables 防火墙...${NC}"
            
            # 检查是否有保存的规则
            if [ -f "/etc/iptables/rules.v4" ]; then
                echo -e "${GREEN}执行: sudo iptables-restore < /etc/iptables/rules.v4${NC}"
                echo ""
                sudo iptables-restore < /etc/iptables/rules.v4
            else
                echo -e "${YELLOW}未找到已保存的 IPTables 规则，应用默认安全规则...${NC}"
                echo -e "${GREEN}执行: sudo iptables -P INPUT DROP${NC}"
                echo ""
                sudo iptables -P INPUT DROP
                echo -e "${GREEN}执行: sudo iptables -P FORWARD DROP${NC}"
                sudo iptables -P FORWARD DROP
                echo -e "${GREEN}执行: sudo iptables -A INPUT -i lo -j ACCEPT${NC}"
                sudo iptables -A INPUT -i lo -j ACCEPT
                echo -e "${GREEN}执行: sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT${NC}"
                sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
                echo -e "${GREEN}执行: sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT${NC}"
                sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
            fi
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}防火墙已开启${NC}"
    
    read -p "按任意键返回..." -n1
    firewall_menu
}

# 查看防火墙状态
check_firewall_status() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      防火墙状态详情      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测防火墙类型
    FIREWALL_TYPE=$(detect_firewall)
    
    if [ "$FIREWALL_TYPE" == "unknown" ]; then
        echo -e "${RED}错误: 未检测到支持的防火墙程序。${NC}"
        echo -e "${YELLOW}支持的防火墙包括: ufw, firewalld, iptables${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    echo -e "${YELLOW}防火墙类型: $FIREWALL_TYPE${NC}"
    echo ""
    
    case $FIREWALL_TYPE in
        ufw)
            echo -e "${YELLOW}UFW 防火墙状态:${NC}"
            echo -e "${GREEN}执行: sudo ufw status verbose${NC}"
            echo ""
            sudo ufw status verbose
            ;;
        firewalld)
            echo -e "${YELLOW}FirewallD 防火墙状态:${NC}"
            echo -e "${GREEN}执行: sudo firewall-cmd --state${NC}"
            echo ""
            sudo firewall-cmd --state
            echo ""
            echo -e "${YELLOW}活动区域:${NC}"
            echo -e "${GREEN}执行: sudo firewall-cmd --get-active-zones${NC}"
            echo ""
            sudo firewall-cmd --get-active-zones
            echo ""
            echo -e "${YELLOW}默认区域规则:${NC}"
            echo -e "${GREEN}执行: sudo firewall-cmd --list-all${NC}"
            echo ""
            sudo firewall-cmd --list-all
            ;;
        iptables)
            echo -e "${YELLOW}IPTables 防火墙规则:${NC}"
            echo -e "${GREEN}执行: sudo iptables -L -v -n${NC}"
            echo ""
            sudo iptables -L -v -n
            ;;
    esac
    
    echo ""
    read -p "按任意键返回..." -n1
    firewall_menu
}

# 管理防火墙端口
manage_firewall_ports() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      防火墙端口管理      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测防火墙类型
    FIREWALL_TYPE=$(detect_firewall)
    FIREWALL_STATUS=$(get_firewall_status "$FIREWALL_TYPE")
    
    # 检查防火墙是否运行
    if [ "$FIREWALL_STATUS" != "active" ]; then
        echo -e "${RED}错误: 防火墙当前未启用，无法管理端口。${NC}"
        echo -e "${YELLOW}请先启用防火墙再进行端口管理。${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    echo -e "${YELLOW}防火墙类型: $FIREWALL_TYPE${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} 开放新端口"
    echo -e "${BLUE}2.${NC} 关闭已开放端口"
    echo -e "${BLUE}3.${NC} 查看已开放端口"
    echo -e "${BLUE}0.${NC} 返回上级菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-3]: " choice
    
    case $choice in
        1)
            open_firewall_port
            ;;
        2)
            close_firewall_port
            ;;
        3)
            list_open_ports
            ;;
        0)
            firewall_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            manage_firewall_ports
            ;;
    esac
}

# 开放防火墙端口
open_firewall_port() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      开放防火墙端口      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    read -p "请输入要开放的端口号: " port
    
    # 验证端口号是否有效
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}错误: 无效的端口号! 端口号必须是1-65535之间的整数。${NC}"
        read -p "按任意键返回..." -n1
        manage_firewall_ports
        return
    fi
    
    read -p "请选择协议类型 (tcp/udp/both): " proto
    case "$proto" in
        tcp|TCP)
            proto="tcp"
            ;;
        udp|UDP)
            proto="udp"
            ;;
        both|BOTH)
            proto="both"
            ;;
        *)
            echo -e "${RED}错误: 无效的协议类型! 必须是 tcp, udp 或 both。${NC}"
            read -p "按任意键返回..." -n1
            manage_firewall_ports
            return
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}正在开放端口 $port/$proto...${NC}"
    echo ""
    
    case $FIREWALL_TYPE in
        ufw)
            if [ "$proto" == "both" ]; then
                echo -e "${GREEN}执行: sudo ufw allow $port/tcp${NC}"
                sudo ufw allow $port/tcp
                echo -e "${GREEN}执行: sudo ufw allow $port/udp${NC}"
                sudo ufw allow $port/udp
            else
                echo -e "${GREEN}执行: sudo ufw allow $port/$proto${NC}"
                sudo ufw allow $port/$proto
            fi
            ;;
        firewalld)
            if [ "$proto" == "both" ]; then
                echo -e "${GREEN}执行: sudo firewall-cmd --permanent --add-port=$port/tcp${NC}"
                sudo firewall-cmd --permanent --add-port=$port/tcp
                echo -e "${GREEN}执行: sudo firewall-cmd --permanent --add-port=$port/udp${NC}"
                sudo firewall-cmd --permanent --add-port=$port/udp
                echo -e "${GREEN}执行: sudo firewall-cmd --reload${NC}"
                sudo firewall-cmd --reload
            else
                echo -e "${GREEN}执行: sudo firewall-cmd --permanent --add-port=$port/$proto${NC}"
                sudo firewall-cmd --permanent --add-port=$port/$proto
                echo -e "${GREEN}执行: sudo firewall-cmd --reload${NC}"
                sudo firewall-cmd --reload
            fi
            ;;
        iptables)
            if [ "$proto" == "both" ] || [ "$proto" == "tcp" ]; then
                echo -e "${GREEN}执行: sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT${NC}"
                sudo iptables -A INPUT -p tcp --dport $port -j ACCEPT
            fi
            
            if [ "$proto" == "both" ] || [ "$proto" == "udp" ]; then
                echo -e "${GREEN}执行: sudo iptables -A INPUT -p udp --dport $port -j ACCEPT${NC}"
                sudo iptables -A INPUT -p udp --dport $port -j ACCEPT
            fi
            
            # 保存iptables规则
            if command -v iptables-save &> /dev/null; then
                echo -e "${GREEN}执行: sudo mkdir -p /etc/iptables${NC}"
                sudo mkdir -p /etc/iptables
                echo -e "${GREEN}执行: sudo iptables-save > /etc/iptables/rules.v4${NC}"
                sudo iptables-save > /etc/iptables/rules.v4
            fi
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ 端口 $port/$proto 已成功开放${NC}"
    read -p "按任意键返回..." -n1
    manage_firewall_ports
}

# 关闭已开放端口
close_firewall_port() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      关闭防火墙端口      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    read -p "请输入要关闭的端口号: " port
    
    # 验证端口号是否有效
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}错误: 无效的端口号! 端口号必须是1-65535之间的整数。${NC}"
        read -p "按任意键返回..." -n1
        manage_firewall_ports
        return
    fi
    
    read -p "请选择协议类型 (tcp/udp/both): " proto
    case "$proto" in
        tcp|TCP)
            proto="tcp"
            ;;
        udp|UDP)
            proto="udp"
            ;;
        both|BOTH)
            proto="both"
            ;;
        *)
            echo -e "${RED}错误: 无效的协议类型! 必须是 tcp, udp 或 both。${NC}"
            read -p "按任意键返回..." -n1
            manage_firewall_ports
            return
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}正在关闭端口 $port/$proto...${NC}"
    echo ""
    
    case $FIREWALL_TYPE in
        ufw)
            if [ "$proto" == "both" ]; then
                echo -e "${GREEN}执行: sudo ufw deny $port/tcp${NC}"
                sudo ufw deny $port/tcp
                echo -e "${GREEN}执行: sudo ufw deny $port/udp${NC}"
                sudo ufw deny $port/udp
            else
                echo -e "${GREEN}执行: sudo ufw deny $port/$proto${NC}"
                sudo ufw deny $port/$proto
            fi
            ;;
        firewalld)
            if [ "$proto" == "both" ]; then
                echo -e "${GREEN}执行: sudo firewall-cmd --permanent --remove-port=$port/tcp${NC}"
                sudo firewall-cmd --permanent --remove-port=$port/tcp
                echo -e "${GREEN}执行: sudo firewall-cmd --permanent --remove-port=$port/udp${NC}"
                sudo firewall-cmd --permanent --remove-port=$port/udp
                echo -e "${GREEN}执行: sudo firewall-cmd --reload${NC}"
                sudo firewall-cmd --reload
            else
                echo -e "${GREEN}执行: sudo firewall-cmd --permanent --remove-port=$port/$proto${NC}"
                sudo firewall-cmd --permanent --remove-port=$port/$proto
                echo -e "${GREEN}执行: sudo firewall-cmd --reload${NC}"
                sudo firewall-cmd --reload
            fi
            ;;
        iptables)
            if [ "$proto" == "both" ] || [ "$proto" == "tcp" ]; then
                echo -e "${GREEN}执行: sudo iptables -D INPUT -p tcp --dport $port -j ACCEPT${NC}"
                sudo iptables -D INPUT -p tcp --dport $port -j ACCEPT
            fi
            
            if [ "$proto" == "both" ] || [ "$proto" == "udp" ]; then
                echo -e "${GREEN}执行: sudo iptables -D INPUT -p udp --dport $port -j ACCEPT${NC}"
                sudo iptables -D INPUT -p udp --dport $port -j ACCEPT
            fi
            
            # 保存iptables规则
            if command -v iptables-save &> /dev/null; then
                echo -e "${GREEN}执行: sudo mkdir -p /etc/iptables${NC}"
                sudo mkdir -p /etc/iptables
                echo -e "${GREEN}执行: sudo iptables-save > /etc/iptables/rules.v4${NC}"
                sudo iptables-save > /etc/iptables/rules.v4
            fi
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ 端口 $port/$proto 已成功关闭${NC}"
    read -p "按任意键返回..." -n1
    manage_firewall_ports
}

# 列出已开放端口
list_open_ports() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      已开放的端口      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    echo -e "${YELLOW}正在获取防火墙开放的端口列表...${NC}"
    echo ""
    
    case $FIREWALL_TYPE in
        ufw)
            echo -e "${GREEN}执行: sudo ufw status verbose${NC}"
            echo ""
            sudo ufw status verbose
            ;;
        firewalld)
            echo -e "${GREEN}执行: sudo firewall-cmd --list-ports${NC}"
            echo ""
            echo -e "${BLUE}已开放的端口:${NC}"
            sudo firewall-cmd --list-ports
            
            echo ""
            echo -e "${GREEN}执行: sudo firewall-cmd --list-all${NC}"
            echo -e "${BLUE}完整防火墙规则:${NC}"
            sudo firewall-cmd --list-all
            ;;
        iptables)
            echo -e "${GREEN}执行: sudo iptables -L INPUT -v -n${NC}"
            echo ""
            sudo iptables -L INPUT -v -n
            ;;
    esac
    
    echo ""
    read -p "按任意键返回..." -n1
    manage_firewall_ports
}

# 定时关闭防火墙后自动恢复
timed_firewall_disable() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}   定时关闭防火墙后自动恢复   ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检测防火墙类型
    FIREWALL_TYPE=$(detect_firewall)
    FIREWALL_STATUS=$(get_firewall_status "$FIREWALL_TYPE")
    
    # 检查防火墙是否运行
    if [ "$FIREWALL_STATUS" != "active" ]; then
        echo -e "${RED}错误: 防火墙当前未启用，无法执行定时关闭。${NC}"
        echo -e "${YELLOW}请先启用防火墙再使用此功能。${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    echo -e "${YELLOW}此功能将临时关闭防火墙，并在指定时间后自动重新启用。${NC}"
    echo -e "${GREEN}适用于需要临时允许所有连接的场景，如测试或特定应用程序的使用。${NC}"
    echo ""
    echo -e "${BLUE}请选择防火墙自动恢复的时间:${NC}"
    echo -e "${BLUE}1.${NC} 5分钟后恢复"
    echo -e "${BLUE}2.${NC} 15分钟后恢复"
    echo -e "${BLUE}3.${NC} 30分钟后恢复"
    echo -e "${BLUE}4.${NC} 1小时后恢复"
    echo -e "${BLUE}5.${NC} 自定义时间(分钟)"
    echo -e "${BLUE}0.${NC} 返回上级菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-5]: " choice
    
    minutes=0
    
    case $choice in
        1)
            minutes=5
            ;;
        2)
            minutes=15
            ;;
        3)
            minutes=30
            ;;
        4)
            minutes=60
            ;;
        5)
            echo ""
            read -p "请输入防火墙自动恢复的分钟数: " custom_minutes
            if ! [[ "$custom_minutes" =~ ^[0-9]+$ ]] || [ "$custom_minutes" -lt 1 ]; then
                echo -e "${RED}错误: 无效的时间! 必须是大于0的整数分钟数。${NC}"
                read -p "按任意键返回..." -n1
                timed_firewall_disable
                return
            fi
            minutes=$custom_minutes
            ;;
        0)
            firewall_menu
            return
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            timed_firewall_disable
            return
            ;;
    esac
    
    echo ""
    echo -e "${YELLOW}防火墙将在 $minutes 分钟后自动恢复!${NC}"
    echo -e "${RED}警告: 关闭防火墙可能会使系统暴露在安全风险中。${NC}"
    echo ""
    read -p "确定要临时关闭防火墙 $minutes 分钟吗? (y/n): " confirm
    
    if [[ "$confirm" != "y" ]]; then
        echo -e "${GREEN}操作已取消，防火墙保持开启状态${NC}"
        read -p "按任意键返回..." -n1
        firewall_menu
        return
    fi
    
    echo ""
    echo -e "${YELLOW}正在临时关闭防火墙，将在 $minutes 分钟后自动恢复...${NC}"
    echo ""
    
    # 保存当前时间作为开始时间
    start_time=$(date +%s)
    restore_time=$((start_time + minutes*60))
    restore_time_readable=$(date -d "@$restore_time" '+%H:%M:%S')
    
    # 临时关闭防火墙
    case $FIREWALL_TYPE in
        ufw)
            echo -e "${GREEN}执行: sudo ufw disable${NC}"
            sudo ufw disable
            ;;
        firewalld)
            echo -e "${GREEN}执行: sudo systemctl stop firewalld${NC}"
            sudo systemctl stop firewalld
            ;;
        iptables)
            echo -e "${GREEN}执行: sudo iptables -F${NC}"
            sudo iptables -F
            echo -e "${GREEN}执行: sudo iptables -X${NC}"
            sudo iptables -X
            echo -e "${GREEN}执行: sudo iptables -P INPUT ACCEPT${NC}"
            sudo iptables -P INPUT ACCEPT
            echo -e "${GREEN}执行: sudo iptables -P FORWARD ACCEPT${NC}"
            sudo iptables -P FORWARD ACCEPT
            echo -e "${GREEN}执行: sudo iptables -P OUTPUT ACCEPT${NC}"
            sudo iptables -P OUTPUT ACCEPT
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ 防火墙已临时关闭${NC}"
    echo -e "${YELLOW}将在 $restore_time_readable (${minutes}分钟后) 自动恢复${NC}"
    echo ""
    
    # 创建后台任务，在指定时间后恢复防火墙
    (
        # 等待指定的分钟数
        sleep $((minutes*60))
        
        # 根据防火墙类型执行相应的启用命令
        case $FIREWALL_TYPE in
            ufw)
                sudo ufw enable
                ;;
            firewalld)
                sudo systemctl start firewalld
                ;;
            iptables)
                # 如果有保存的规则，则恢复
                if [ -f "/etc/iptables/rules.v4" ]; then
                    sudo iptables-restore < /etc/iptables/rules.v4
                else
                    # 否则应用基本安全规则
                    sudo iptables -P INPUT DROP
                    sudo iptables -P FORWARD DROP
                    sudo iptables -A INPUT -i lo -j ACCEPT
                    sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
                    sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
                fi
                ;;
        esac
        
        # 发送桌面通知（如果系统支持）
        if command -v notify-send &> /dev/null; then
            notify-send "防火墙已自动恢复" "系统防火墙已于$(date '+%H:%M:%S')自动重新启用。"
        fi
    ) &
    
    # 显示倒计时
    remaining=$((minutes*60))
    echo -e "${YELLOW}防火墙将自动恢复，倒计时:${NC}"
    echo ""
    
    while [ $remaining -gt 0 ]; do
        mins=$((remaining / 60))
        secs=$((remaining % 60))
        
        # 清除当前行
        echo -ne "\r${GREEN}剩余时间: ${mins}分钟 ${secs}秒      ${NC}"
        sleep 1
        remaining=$((remaining - 1))
        
        # 检查是否按下了任意键
        read -t 0.1 -n 1 input
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${YELLOW}检测到按键，是否立即恢复防火墙? (y/n): ${NC}"
            read restore_now
            if [[ "$restore_now" == "y" ]]; then
                # 杀死之前的后台任务
                pkill -f "sleep $((minutes*60))"
                
                echo -e "${GREEN}立即恢复防火墙...${NC}"
                
                # 根据防火墙类型执行相应的启用命令
                case $FIREWALL_TYPE in
                    ufw)
                        sudo ufw enable
                        ;;
                    firewalld)
                        sudo systemctl start firewalld
                        ;;
                    iptables)
                        if [ -f "/etc/iptables/rules.v4" ]; then
                            sudo iptables-restore < /etc/iptables/rules.v4
                        else
                            sudo iptables -P INPUT DROP
                            sudo iptables -P FORWARD DROP
                            sudo iptables -A INPUT -i lo -j ACCEPT
                            sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
                            sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
                        fi
                        ;;
                esac
                
                echo -e "${GREEN}✅ 防火墙已手动恢复${NC}"
                break
            else
                echo -e "${YELLOW}继续倒计时...${NC}"
            fi
        fi
    done
    
    echo ""
    echo -e "${GREEN}操作完成${NC}"
    read -p "按任意键返回..." -n1
    firewall_menu
}

# 检查端口占用菜单
port_check_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}       端口占用检查       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} 检查特定端口"
    echo -e "${BLUE}2.${NC} 查看所有开放端口"
    echo -e "${BLUE}3.${NC} 查看所有已建立的连接"
    echo -e "${BLUE}0.${NC} 返回主菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-3]: " choice

    case $choice in
        1)
            check_specific_port
            ;;
        2)
            list_all_open_ports
            ;;
        3)
            list_all_connections
            ;;
        0)
            show_main_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            port_check_menu
            ;;
    esac
}

# 检查特定端口占用
check_specific_port() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      检查特定端口占用      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    read -p "请输入要检查的端口号: " port
    
    # 验证端口号是否有效
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}错误: 无效的端口号! 端口号必须是1-65535之间的整数。${NC}"
        read -p "按任意键返回..." -n1
        port_check_menu
        return
    fi
    
    echo -e "${YELLOW}正在检查端口 $port 的占用情况...${NC}"
    echo ""
    
    # 使用不同命令检查端口占用
    echo -e "${BLUE}使用 lsof 检查:${NC}"
    if command -v lsof &> /dev/null; then
        echo -e "${GREEN}执行: sudo lsof -i:$port${NC}"
        echo ""
        sudo lsof -i:$port
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}没有进程占用端口 $port${NC}"
        fi
    else
        echo -e "${RED}lsof 命令不可用${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}使用 netstat 检查:${NC}"
    if command -v netstat &> /dev/null; then
        echo -e "${GREEN}执行: sudo netstat -tuln | grep :$port${NC}"
        echo ""
        sudo netstat -tuln | grep ":$port"
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}netstat 未发现端口 $port 有活动${NC}"
        fi
    else
        echo -e "${RED}netstat 命令不可用${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}使用 ss 检查:${NC}"
    if command -v ss &> /dev/null; then
        echo -e "${GREEN}执行: sudo ss -tuln | grep :$port${NC}"
        echo ""
        sudo ss -tuln | grep ":$port"
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}ss 未发现端口 $port 有活动${NC}"
        fi
    else
        echo -e "${RED}ss 命令不可用${NC}"
    fi
    
    echo ""
    read -p "按任意键返回..." -n1
    port_check_menu
}

# 列出所有开放端口
list_all_open_ports() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}        所有开放端口        ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    echo -e "${YELLOW}正在获取所有开放的端口...${NC}"
    echo ""
    
    FOUND_CMD=false
    
    if command -v ss &> /dev/null; then
        FOUND_CMD=true
        echo -e "${BLUE}使用 ss 命令列出所有监听端口:${NC}"
        echo -e "${GREEN}执行: sudo ss -tuln${NC}"
        echo ""
        sudo ss -tuln
    elif command -v netstat &> /dev/null; then
        FOUND_CMD=true
        echo -e "${BLUE}使用 netstat 命令列出所有监听端口:${NC}"
        echo -e "${GREEN}执行: sudo netstat -tuln${NC}"
        echo ""
        sudo netstat -tuln
    elif command -v lsof &> /dev/null; then
        FOUND_CMD=true
        echo -e "${BLUE}使用 lsof 命令列出所有监听端口:${NC}"
        echo -e "${GREEN}执行: sudo lsof -i -P -n | grep LISTEN${NC}"
        echo ""
        sudo lsof -i -P -n | grep LISTEN
    fi
    
    if [ "$FOUND_CMD" = false ]; then
        echo -e "${RED}错误: 未找到可用于检查端口的命令 (ss, netstat, lsof)${NC}"
        echo -e "${YELLOW}请安装这些工具中的一个以使用此功能${NC}"
    fi
    
    echo ""
    read -p "按任意键返回..." -n1
    port_check_menu
}

# 列出所有已建立的连接
list_all_connections() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      所有已建立的连接      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    echo -e "${YELLOW}正在获取所有已建立的连接...${NC}"
    echo ""
    
    FOUND_CMD=false
    
    if command -v ss &> /dev/null; then
        FOUND_CMD=true
        echo -e "${BLUE}使用 ss 命令列出已建立的连接:${NC}"
        echo -e "${GREEN}执行: sudo ss -tu state established${NC}"
        echo ""
        sudo ss -tu state established
    elif command -v netstat &> /dev/null; then
        FOUND_CMD=true
        echo -e "${BLUE}使用 netstat 命令列出已建立的连接:${NC}"
        echo -e "${GREEN}执行: sudo netstat -tune | grep ESTABLISHED${NC}"
        echo ""
        sudo netstat -tune | grep ESTABLISHED
    elif command -v lsof &> /dev/null; then
        FOUND_CMD=true
        echo -e "${BLUE}使用 lsof 命令列出已建立的连接:${NC}"
        echo -e "${GREEN}执行: sudo lsof -i -P -n | grep ESTABLISHED${NC}"
        echo ""
        sudo lsof -i -P -n | grep ESTABLISHED
    fi
    
    if [ "$FOUND_CMD" = false ]; then
        echo -e "${RED}错误: 未找到可用于检查连接的命令 (ss, netstat, lsof)${NC}"
        echo -e "${YELLOW}请安装这些工具中的一个以使用此功能${NC}"
    fi
    
    echo ""
    read -p "按任意键返回..." -n1
    port_check_menu
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
