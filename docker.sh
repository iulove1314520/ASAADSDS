#!/bin/bash

# Docker管理脚本

# 脚本版本号
SCRIPT_VERSION="1.0.0"
SCRIPT_UPDATE_URL="https://raw.githubusercontent.com/iulove1314520/ASAADSDS/refs/heads/main/docker.sh"

# 设置终端颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # 恢复默认颜色

# Docker-Compose管理菜单
docker_compose_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}    Docker-Compose 管理     ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} 安装 Docker-Compose"
    echo -e "${BLUE}2.${NC} 更新 Docker-Compose"
    echo -e "${BLUE}3.${NC} 查询 Docker-Compose 版本信息"
    echo -e "${BLUE}4.${NC} 卸载 Docker-Compose"
    echo -e "${BLUE}0.${NC} 返回主菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-4]: " choice

    case $choice in
        1)
            install_docker_compose
            ;;
        2)
            update_docker_compose
            ;;
        3)
            check_docker_compose_version
            ;;
        4)
            uninstall_docker_compose
            ;;
        0)
            show_main_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            docker_compose_menu
            ;;
    esac
}

# 安装Docker-Compose
install_docker_compose() {
    clear
    echo -e "${GREEN}正在安装 Docker-Compose...${NC}"
    
    # 检查Docker是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装。请先安装Docker。${NC}"
        read -p "按任意键返回..." -n1
        docker_compose_menu
        return
    fi
    
    # 获取最新版本
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '"' -f 4)
    
    echo -e "${YELLOW}最新版本: ${COMPOSE_VERSION}${NC}"
    echo -e "${YELLOW}开始下载 Docker-Compose...${NC}"
    
    # 下载Docker-Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # 设置可执行权限
    sudo chmod +x /usr/local/bin/docker-compose
    
    # 创建软链接
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo -e "${GREEN}Docker-Compose 安装完成!${NC}"
    echo -e "${GREEN}版本信息:${NC}"
    docker-compose --version
    
    read -p "按任意键返回..." -n1
    docker_compose_menu
}

# 更新Docker-Compose
update_docker_compose() {
    clear
    echo -e "${GREEN}正在更新 Docker-Compose...${NC}"
    
    # 检查Docker-Compose是否已安装
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}错误: Docker-Compose未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_compose_menu
        return
    fi
    
    # 获取当前版本
    CURRENT_VERSION=$(docker-compose --version | grep -o "[0-9]*\.[0-9]*\.[0-9]*")
    echo -e "${YELLOW}当前版本: ${CURRENT_VERSION}${NC}"
    
    # 获取最新版本
    LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '"' -f 4 | cut -c 2-)
    echo -e "${YELLOW}最新版本: ${LATEST_VERSION}${NC}"
    
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo -e "${GREEN}您已经使用最新版本的 Docker-Compose!${NC}"
    else
        echo -e "${YELLOW}开始更新 Docker-Compose...${NC}"
        
        # 下载最新版本
        sudo curl -L "https://github.com/docker/compose/releases/download/v${LATEST_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        
        # 设置可执行权限
        sudo chmod +x /usr/local/bin/docker-compose
        
        # 创建软链接
        sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
        
        echo -e "${GREEN}Docker-Compose 更新完成!${NC}"
        echo -e "${GREEN}新版本信息:${NC}"
        docker-compose --version
    fi
    
    read -p "按任意键返回..." -n1
    docker_compose_menu
}

# 检查Docker-Compose版本信息
check_docker_compose_version() {
    clear
    echo -e "${GREEN}正在检查 Docker-Compose 版本信息...${NC}"
    
    # 检查Docker-Compose是否已安装
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}错误: Docker-Compose未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_compose_menu
        return
    fi
    
    echo -e "${GREEN}Docker-Compose 版本信息:${NC}"
    docker-compose --version
    
    # 获取最新版本
    LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '"' -f 4)
    echo -e "${YELLOW}最新可用版本: ${LATEST_VERSION}${NC}"
    
    read -p "按任意键返回..." -n1
    docker_compose_menu
}

# 卸载Docker-Compose
uninstall_docker_compose() {
    clear
    echo -e "${GREEN}正在卸载 Docker-Compose...${NC}"
    
    # 检查Docker-Compose是否已安装
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}错误: Docker-Compose未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_compose_menu
        return
    fi
    
    # 确认卸载
    read -p "您确定要卸载 Docker-Compose 吗? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo -e "${YELLOW}卸载已取消${NC}"
        read -p "按任意键返回..." -n1
        docker_compose_menu
        return
    fi
    
    # 卸载Docker-Compose
    sudo rm -f /usr/local/bin/docker-compose
    sudo rm -f /usr/bin/docker-compose
    
    echo -e "${GREEN}Docker-Compose 已成功卸载!${NC}"
    read -p "按任意键返回..." -n1
    docker_compose_menu
}

# Docker容器管理菜单
docker_container_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      Docker 容器管理       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} 安装 Docker"
    echo -e "${BLUE}2.${NC} 更新 Docker"
    echo -e "${BLUE}3.${NC} 查询 Docker 版本信息"
    echo -e "${BLUE}4.${NC} 卸载 Docker"
    echo -e "${BLUE}5.${NC} 进入容器内部"
    echo -e "${BLUE}6.${NC} 容器启动/停止管理"
    echo -e "${BLUE}7.${NC} 删除容器"
    echo -e "${BLUE}0.${NC} 返回主菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-7]: " choice

    case $choice in
        1)
            install_docker
            ;;
        2)
            update_docker
            ;;
        3)
            check_docker_version
            ;;
        4)
            uninstall_docker
            ;;
        5)
            enter_container
            ;;
        6)
            manage_container
            ;;
        7)
            remove_container
            ;;
        0)
            show_main_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            docker_container_menu
            ;;
    esac
}

# 安装Docker
install_docker() {
    clear
    echo -e "${GREEN}正在安装 Docker...${NC}"
    
    # 检查Docker是否已安装
    if command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker 已经安装。版本信息:${NC}"
        docker --version
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    echo -e "${YELLOW}检测操作系统...${NC}"
    
    # 检测操作系统类型
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    else
        OS=$(uname -s)
    fi
    
    echo -e "${YELLOW}操作系统: ${OS}${NC}"
    
    # 根据操作系统安装Docker
    case "$OS" in
        "Ubuntu"|"Debian GNU/Linux")
            echo -e "${YELLOW}使用APT安装Docker...${NC}"
            
            # 更新软件包索引
            sudo apt-get update
            
            # 安装必要的软件包
            sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
            
            # 添加Docker的官方GPG密钥
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            
            # 设置Docker仓库
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            
            # 更新软件包索引
            sudo apt-get update
            
            # 安装Docker CE
            sudo apt-get install -y docker-ce
            ;;
            
        "CentOS Linux"|"Red Hat Enterprise Linux")
            echo -e "${YELLOW}使用YUM安装Docker...${NC}"
            
            # 安装必要的软件包
            sudo yum install -y yum-utils device-mapper-persistent-data lvm2
            
            # 设置Docker仓库
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            
            # 安装Docker CE
            sudo yum install -y docker-ce
            ;;
            
        "Fedora")
            echo -e "${YELLOW}使用DNF安装Docker...${NC}"
            
            # 安装必要的软件包
            sudo dnf -y install dnf-plugins-core
            
            # 设置Docker仓库
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            
            # 安装Docker CE
            sudo dnf install -y docker-ce
            ;;
            
        *)
            echo -e "${RED}不支持的操作系统: ${OS}${NC}"
            echo -e "${YELLOW}请访问Docker官方网站获取安装指南: https://docs.docker.com/engine/install/${NC}"
            read -p "按任意键返回..." -n1
            docker_container_menu
            return
            ;;
    esac
    
    # 启动Docker服务
    sudo systemctl start docker
    
    # 设置Docker服务开机自启
    sudo systemctl enable docker
    
    # 将当前用户添加到docker组
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}Docker 安装完成!${NC}"
    echo -e "${GREEN}版本信息:${NC}"
    docker --version
    
    echo -e "${YELLOW}注意: 您需要重新登录或重启系统以使用户组更改生效。${NC}"
    read -p "按任意键返回..." -n1
    docker_container_menu
}

# 更新Docker
update_docker() {
    clear
    echo -e "${GREEN}正在更新 Docker...${NC}"
    
    # 检查Docker是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 获取当前版本
    CURRENT_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    echo -e "${YELLOW}当前版本: ${CURRENT_VERSION}${NC}"
    
    # 检测操作系统类型
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    else
        OS=$(uname -s)
    fi
    
    echo -e "${YELLOW}操作系统: ${OS}${NC}"
    
    # 根据操作系统更新Docker
    case "$OS" in
        "Ubuntu"|"Debian GNU/Linux")
            echo -e "${YELLOW}使用APT更新Docker...${NC}"
            sudo apt-get update
            sudo apt-get upgrade -y docker-ce
            ;;
            
        "CentOS Linux"|"Red Hat Enterprise Linux")
            echo -e "${YELLOW}使用YUM更新Docker...${NC}"
            sudo yum update -y docker-ce
            ;;
            
        "Fedora")
            echo -e "${YELLOW}使用DNF更新Docker...${NC}"
            sudo dnf update -y docker-ce
            ;;
            
        *)
            echo -e "${RED}不支持的操作系统: ${OS}${NC}"
            echo -e "${YELLOW}请访问Docker官方网站获取更新指南: https://docs.docker.com/engine/install/${NC}"
            read -p "按任意键返回..." -n1
            docker_container_menu
            return
            ;;
    esac
    
    # 重启Docker服务
    sudo systemctl restart docker
    
    # 获取更新后的版本
    NEW_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    
    echo -e "${GREEN}Docker 更新完成!${NC}"
    echo -e "${GREEN}新版本信息: ${NEW_VERSION}${NC}"
    
    if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
        echo -e "${GREEN}您已经使用最新版本的 Docker!${NC}"
    fi
    
    read -p "按任意键返回..." -n1
    docker_container_menu
}

# 检查Docker版本信息
check_docker_version() {
    clear
    echo -e "${GREEN}正在检查 Docker 版本信息...${NC}"
    
    # 检查Docker是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    echo -e "${GREEN}Docker 版本信息:${NC}"
    docker --version
    
    echo -e "\n${GREEN}Docker 系统信息:${NC}"
    docker info | grep -E '^(Server Version|Storage Driver|Logging Driver|Cgroup Driver|Kernel Version|Operating System|OSType|Architecture)'
    
    echo -e "\n${GREEN}Docker 组件版本:${NC}"
    docker version
    
    read -p "按任意键返回..." -n1
    docker_container_menu
}

# 卸载Docker
uninstall_docker() {
    clear
    echo -e "${GREEN}正在卸载 Docker...${NC}"
    
    # 检查Docker是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 确认卸载
    read -p "您确定要卸载 Docker 吗? 这将删除所有容器、镜像和卷! (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo -e "${YELLOW}卸载已取消${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 停止所有运行中的容器
    echo -e "${YELLOW}停止所有运行中的容器...${NC}"
    docker stop $(docker ps -a -q) 2>/dev/null || true
    
    # 检测操作系统类型
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    else
        OS=$(uname -s)
    fi
    
    echo -e "${YELLOW}操作系统: ${OS}${NC}"
    
    # 根据操作系统卸载Docker
    case "$OS" in
        "Ubuntu"|"Debian GNU/Linux")
            echo -e "${YELLOW}使用APT卸载Docker...${NC}"
            sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
            sudo apt-get autoremove -y --purge docker-ce docker-ce-cli containerd.io
            ;;
            
        "CentOS Linux"|"Red Hat Enterprise Linux")
            echo -e "${YELLOW}使用YUM卸载Docker...${NC}"
            sudo yum remove -y docker-ce docker-ce-cli containerd.io
            ;;
            
        "Fedora")
            echo -e "${YELLOW}使用DNF卸载Docker...${NC}"
            sudo dnf remove -y docker-ce docker-ce-cli containerd.io
            ;;
            
        *)
            echo -e "${RED}不支持的操作系统: ${OS}${NC}"
            echo -e "${YELLOW}请访问Docker官方网站获取卸载指南: https://docs.docker.com/engine/install/${NC}"
            read -p "按任意键返回..." -n1
            docker_container_menu
            return
            ;;
    esac
    
    # 删除Docker数据目录
    echo -e "${YELLOW}删除Docker数据目录...${NC}"
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    
    echo -e "${GREEN}Docker 已成功卸载!${NC}"
    read -p "按任意键返回..." -n1
    docker_container_menu
}

# 进入容器内部
enter_container() {
    clear
    echo -e "${GREEN}进入Docker容器内部${NC}"
    echo -e "${GREEN}=============================${NC}"
    
    # 检查Docker是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 获取所有容器（包括已停止的）
    echo -e "${YELLOW}获取所有容器...${NC}"
    
    # 检查是否有容器
    if [ -z "$(docker ps -a -q)" ]; then
        echo -e "${RED}错误: 没有找到任何Docker容器。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 使用数组存储容器ID
    container_ids=()
    
    # 显示容器列表（格式化输出）
    echo -e "\n${GREEN}容器列表:${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "序号\t状态\t\t容器ID\t\t\t镜像\t\t\t名称"
    echo -e "${GREEN}=============================${NC}"
    
    # 获取容器信息并显示
    count=1
    while read -r line; do
        container_id=$(echo "$line" | awk '{print $1}')
        container_ids+=("$container_id")
        container_image=$(echo "$line" | awk '{print $2}')
        container_name=$(echo "$line" | awk '{print $NF}')
        container_status=$(echo "$line" | awk '{print $3}')
        
        # 根据状态使用不同颜色
        if [[ "$container_status" == "Up"* ]]; then
            status_color="${GREEN}"
        else
            status_color="${RED}"
        fi
        
        echo -e "${BLUE}$count)${NC}\t${status_color}$container_status${NC}\t$container_id\t$container_image\t$container_name"
        ((count++))
    done < <(docker ps -a --format "{{.ID}} {{.Image}} {{.Status}} {{.Names}}")
    
    echo -e "${GREEN}=============================${NC}"
    
    # 让用户选择要进入的容器
    echo ""
    read -p "请选择要进入的容器序号 [1-$((count-1))], 或输入 'q' 返回: " choice
    
    # 处理用户选择
    if [[ "$choice" == "q" ]]; then
        docker_container_menu
        return
    fi
    
    # 验证输入是否是数字
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}错误: 无效输入，请输入数字。${NC}"
        read -p "按任意键继续..." -n1
        enter_container
        return
    fi
    
    # 检查输入数字是否有效
    if [ "$choice" -lt 1 ] || [ "$choice" -gt $((count-1)) ]; then
        echo -e "${RED}错误: 无效的容器序号。${NC}"
        read -p "按任意键继续..." -n1
        enter_container
        return
    fi
    
    # 获取选中的容器ID
    selected_container=${container_ids[$((choice-1))]}
    
    # 检查容器是否在运行中
    container_status=$(docker inspect --format='{{.State.Status}}' "$selected_container")
    
    if [ "$container_status" != "running" ]; then
        echo -e "${YELLOW}容器未运行，正在启动容器...${NC}"
        docker start "$selected_container"
        sleep 2
    fi
    
    # 进入容器
    echo -e "${GREEN}正在进入容器 $selected_container...${NC}"
    echo -e "${YELLOW}提示: 输入 'exit' 可退出容器${NC}"
    echo -e "${GREEN}=============================${NC}"
    
    # 使用exec命令进入容器
    docker exec -it "$selected_container" /bin/bash || docker exec -it "$selected_container" /bin/sh
    
    # 返回后显示消息
    echo -e "${GREEN}已退出容器${NC}"
    read -p "按任意键返回..." -n1
    docker_container_menu
}

# 容器启动/停止管理
manage_container() {
    clear
    echo -e "${GREEN}容器启动/停止管理${NC}"
    echo -e "${GREEN}=============================${NC}"
    
    # 检查Docker是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 获取所有容器（包括已停止的）
    echo -e "${YELLOW}获取所有容器...${NC}"
    
    # 检查是否有容器
    if [ -z "$(docker ps -a -q)" ]; then
        echo -e "${RED}错误: 没有找到任何Docker容器。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 使用数组存储容器ID
    container_ids=()
    
    # 显示容器列表（格式化输出）
    echo -e "\n${GREEN}容器列表:${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "序号\t状态\t\t容器ID\t\t\t镜像\t\t\t名称"
    echo -e "${GREEN}=============================${NC}"
    
    # 获取容器信息并显示
    count=1
    while read -r line; do
        container_id=$(echo "$line" | awk '{print $1}')
        container_ids+=("$container_id")
        container_image=$(echo "$line" | awk '{print $2}')
        container_name=$(echo "$line" | awk '{print $NF}')
        container_status=$(echo "$line" | awk '{print $3}')
        
        # 根据状态使用不同颜色
        if [[ "$container_status" == "Up"* ]]; then
            status_color="${GREEN}"
        else
            status_color="${RED}"
        fi
        
        echo -e "${BLUE}$count)${NC}\t${status_color}$container_status${NC}\t$container_id\t$container_image\t$container_name"
        ((count++))
    done < <(docker ps -a --format "{{.ID}} {{.Image}} {{.Status}} {{.Names}}")
    
    echo -e "${GREEN}=============================${NC}"
    
    # 让用户选择要管理的容器
    echo ""
    read -p "请选择要管理的容器序号 [1-$((count-1))], 或输入 'q' 返回: " choice
    
    # 处理用户选择
    if [[ "$choice" == "q" ]]; then
        docker_container_menu
        return
    fi
    
    # 验证输入是否是数字
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}错误: 无效输入，请输入数字。${NC}"
        read -p "按任意键继续..." -n1
        manage_container
        return
    fi
    
    # 检查输入数字是否有效
    if [ "$choice" -lt 1 ] || [ "$choice" -gt $((count-1)) ]; then
        echo -e "${RED}错误: 无效的容器序号。${NC}"
        read -p "按任意键继续..." -n1
        manage_container
        return
    fi
    
    # 获取选中的容器ID
    selected_container=${container_ids[$((choice-1))]}
    
    # 获取容器信息
    container_name=$(docker inspect --format='{{.Name}}' "$selected_container" | sed 's/^\///')
    container_status=$(docker inspect --format='{{.State.Status}}' "$selected_container")
    
    # 显示管理选项
    clear
    echo -e "${GREEN}容器管理: ${container_name} (${selected_container})${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "当前状态: $(if [[ "$container_status" == "running" ]]; then echo -e "${GREEN}运行中${NC}"; else echo -e "${RED}已停止${NC}"; fi)"
    echo ""
    
    # 根据当前状态显示不同选项
    if [[ "$container_status" == "running" ]]; then
        echo -e "${BLUE}1.${NC} 停止容器"
        echo -e "${BLUE}2.${NC} 重启容器"
    else
        echo -e "${BLUE}1.${NC} 启动容器"
    fi
    echo -e "${BLUE}3.${NC} 删除容器"
    echo -e "${BLUE}0.${NC} 返回上级菜单"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    read -p "请选择操作: " op_choice
    
    case $op_choice in
        1)
            if [[ "$container_status" == "running" ]]; then
                # 停止容器
                echo -e "${YELLOW}正在停止容器 ${container_name}...${NC}"
                docker stop "$selected_container"
                echo -e "${GREEN}容器已停止${NC}"
            else
                # 启动容器
                echo -e "${YELLOW}正在启动容器 ${container_name}...${NC}"
                docker start "$selected_container"
                echo -e "${GREEN}容器已启动${NC}"
            fi
            ;;
        2)
            if [[ "$container_status" == "running" ]]; then
                # 重启容器
                echo -e "${YELLOW}正在重启容器 ${container_name}...${NC}"
                docker restart "$selected_container"
                echo -e "${GREEN}容器已重启${NC}"
            else
                echo -e "${RED}错误: 无效选择${NC}"
            fi
            ;;
        3)
            # 删除容器
            echo -e "${RED}警告: 您即将删除容器 ${container_name}${NC}"
            read -p "确定要删除此容器吗? (y/n): " confirm
            
            if [[ "$confirm" == "y" ]]; then
                if [[ "$container_status" == "running" ]]; then
                    echo -e "${YELLOW}容器正在运行，先停止容器...${NC}"
                    docker stop "$selected_container"
                fi
                
                echo -e "${YELLOW}正在删除容器 ${container_name}...${NC}"
                docker rm "$selected_container"
                echo -e "${GREEN}容器已删除${NC}"
            else
                echo -e "${YELLOW}取消删除操作${NC}"
            fi
            ;;
        0)
            manage_container
            return
            ;;
        *)
            echo -e "${RED}错误: 无效选择${NC}"
            ;;
    esac
    
    read -p "按任意键返回..." -n1
    manage_container
}

# 删除容器
remove_container() {
    clear
    echo -e "${GREEN}删除 Docker 容器${NC}"
    echo -e "${GREEN}=============================${NC}"
    
    # 检查Docker是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 获取所有容器（包括已停止的）
    echo -e "${YELLOW}获取所有容器...${NC}"
    
    # 检查是否有容器
    if [ -z "$(docker ps -a -q)" ]; then
        echo -e "${RED}错误: 没有找到任何Docker容器。${NC}"
        read -p "按任意键返回..." -n1
        docker_container_menu
        return
    fi
    
    # 使用数组存储容器信息
    container_ids=()
    container_names=()
    container_images=()
    container_statuses=()
    
    # 显示容器列表（格式化输出）
    echo -e "\n${GREEN}容器列表:${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "序号\t状态\t\t容器ID\t\t\t镜像\t\t\t名称"
    echo -e "${GREEN}=============================${NC}"
    
    # 获取容器信息并显示
    count=1
    while read -r line; do
        container_id=$(echo "$line" | awk '{print $1}')
        container_ids+=("$container_id")
        
        container_image=$(echo "$line" | awk '{print $2}')
        container_images+=("$container_image")
        
        container_name=$(echo "$line" | awk '{print $NF}')
        container_names+=("$container_name")
        
        container_status=$(echo "$line" | awk '{print $3}')
        container_statuses+=("$container_status")
        
        # 根据状态使用不同颜色
        if [[ "$container_status" == "Up"* ]]; then
            status_color="${GREEN}"
        else
            status_color="${RED}"
        fi
        
        echo -e "${BLUE}$count)${NC}\t${status_color}$container_status${NC}\t$container_id\t$container_image\t$container_name"
        ((count++))
    done < <(docker ps -a --format "{{.ID}} {{.Image}} {{.Status}} {{.Names}}")
    
    echo -e "${GREEN}=============================${NC}"
    echo -e "${YELLOW}提示: 您也可以选择多个容器删除 (例如: 1 3 5)${NC}"
    echo -e "${RED}警告: 运行中的容器将先被停止然后删除${NC}"
    echo ""
    
    # 让用户选择要删除的容器
    read -p "请选择要删除的容器序号 [1-$((count-1))], 使用空格分隔，或输入 'q' 返回: " choice
    
    # 处理用户选择
    if [[ "$choice" == "q" ]]; then
        docker_container_menu
        return
    fi
    
    # 解析用户输入的序号
    selected_indices=()
    for num in $choice; do
        # 验证输入是否是数字
        if ! [[ "$num" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}错误: '$num' 不是有效的数字。${NC}"
            read -p "按任意键继续..." -n1
            remove_container
            return
        fi
        
        # 检查输入数字是否有效
        if [ "$num" -lt 1 ] || [ "$num" -gt $((count-1)) ]; then
            echo -e "${RED}错误: '$num' 不是有效的容器序号。${NC}"
            read -p "按任意键继续..." -n1
            remove_container
            return
        fi
        
        selected_indices+=($num)
    done
    
    # 显示要删除的容器信息并确认
    echo ""
    echo -e "${YELLOW}您选择了以下容器:${NC}"
    echo -e "${GREEN}=============================${NC}"
    for idx in "${selected_indices[@]}"; do
        container_idx=$((idx-1))
        cid=${container_ids[$container_idx]}
        cname=${container_names[$container_idx]}
        cstatus=${container_statuses[$container_idx]}
        
        # 根据状态使用不同颜色
        if [[ "$cstatus" == "Up"* ]]; then
            status_color="${GREEN}"
        else
            status_color="${RED}"
        fi
        
        echo -e "- ${BLUE}$cid${NC} (${YELLOW}$cname${NC}) - 状态: ${status_color}$cstatus${NC}"
    done
    echo -e "${GREEN}=============================${NC}"
    
    # 确认删除
    echo ""
    read -p "确认删除这些容器吗? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo -e "${YELLOW}删除操作已取消${NC}"
        read -p "按任意键返回..." -n1
        remove_container
        return
    fi
    
    # 执行删除操作
    echo ""
    for idx in "${selected_indices[@]}"; do
        container_idx=$((idx-1))
        cid=${container_ids[$container_idx]}
        cname=${container_names[$container_idx]}
        cstatus=${container_statuses[$container_idx]}
        
        # 如果容器正在运行，先停止
        if [[ "$cstatus" == "Up"* ]]; then
            echo -e "${YELLOW}正在停止容器 $cname ($cid)...${NC}"
            docker stop "$cid" > /dev/null
            sleep 1
        fi
        
        # 删除容器
        echo -e "${YELLOW}正在删除容器 $cname ($cid)...${NC}"
        if docker rm "$cid" > /dev/null; then
            echo -e "${GREEN}容器 $cname 删除成功!${NC}"
        else
            echo -e "${RED}删除容器 $cname 失败，请检查错误信息。${NC}"
        fi
        echo ""
    done
    
    echo -e "${GREEN}删除操作已完成${NC}"
    read -p "按任意键返回..." -n1
    remove_container
}

# 常见项目安装菜单
common_projects_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      常见项目安装       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} Nginx Proxy Manager"
    echo -e "${BLUE}2.${NC} Watchtower (自动更新容器)"
    echo -e "${BLUE}0.${NC} 返回主菜单"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-2]: " choice

    case $choice in
        1)
            install_nginx_proxy_manager
            ;;
        2)
            install_watchtower
            ;;
        0)
            show_main_menu
            ;;
        *)
            echo -e "${RED}无效选择，请重试${NC}"
            sleep 1
            common_projects_menu
            ;;
    esac
}

# 安装Nginx Proxy Manager
install_nginx_proxy_manager() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}   安装 Nginx Proxy Manager  ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检查Docker和Docker Compose是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装，请先安装Docker。${NC}"
        read -p "按任意键返回..." -n1
        common_projects_menu
        return
    fi
    
    if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker Compose未安装，请先安装Docker Compose。${NC}"
        read -p "按任意键返回..." -n1
        common_projects_menu
        return
    fi

    # 项目信息
    echo -e "${BLUE}Nginx Proxy Manager${NC} 是一个易于使用的反向代理工具，带有漂亮的界面，支持Let's Encrypt SSL证书。"
    echo -e "项目地址: ${BLUE}https://github.com/NginxProxyManager/nginx-proxy-manager${NC}"
    echo ""
    
    # 配置安装参数
    configure_npm_installation
}

# 配置Nginx Proxy Manager安装参数
configure_npm_installation() {
    echo -e "${GREEN}请配置安装参数:${NC}"
    echo -e "${YELLOW}(按Enter使用默认值)${NC}"
    echo ""
    
    # 选择安装目录
    default_install_dir="$HOME/nginx-proxy-manager"
    read -p "安装目录 [$default_install_dir]: " install_dir
    install_dir=${install_dir:-$default_install_dir}
    
    # 端口配置和检查
    configure_npm_ports
}

# 配置并检查Nginx Proxy Manager端口
configure_npm_ports() {
    # 默认端口
    default_http_port="80"
    default_https_port="443"
    default_ui_port="81"
    
    # 获取用户输入的端口
    read -p "HTTP端口 [$default_http_port]: " http_port
    http_port=${http_port:-$default_http_port}
    
    read -p "HTTPS端口 [$default_https_port]: " https_port
    https_port=${https_port:-$default_https_port}
    
    read -p "管理界面端口 [$default_ui_port]: " ui_port
    ui_port=${ui_port:-$default_ui_port}
    
    echo -e "${YELLOW}正在检查端口占用情况...${NC}"
    
    # 检查端口是否被占用
    local port_in_use=false
    local used_ports=""
    
    # 检查HTTP端口
    if check_port_in_use "$http_port"; then
        port_in_use=true
        used_ports="$used_ports HTTP端口($http_port)"
    fi
    
    # 检查HTTPS端口
    if check_port_in_use "$https_port"; then
        if [ "$port_in_use" = true ]; then
            used_ports="$used_ports, "
        fi
        port_in_use=true
        used_ports="$used_ports HTTPS端口($https_port)"
    fi
    
    # 检查UI端口
    if check_port_in_use "$ui_port"; then
        if [ "$port_in_use" = true ]; then
            used_ports="$used_ports, "
        fi
        port_in_use=true
        used_ports="$used_ports 管理界面端口($ui_port)"
    fi
    
    # 如果有端口被占用，提示用户并返回端口配置界面
    if [ "$port_in_use" = true ]; then
        echo -e "${RED}错误: 以下端口已被占用: ${used_ports}${NC}"
        echo -e "${YELLOW}请选择其他可用端口${NC}"
        echo ""
        configure_npm_ports
        return
    else
        echo -e "${GREEN}所有端口检查通过，可以使用${NC}"
        echo ""
        
        # 继续安装流程
        continue_npm_installation
    fi
}

# 检查端口是否被占用
check_port_in_use() {
    local port=$1
    
    # 使用不同命令检查端口占用
    # 方法1: 使用netstat (如果可用)
    if command -v netstat &> /dev/null; then
        if netstat -tuln | grep -q ":$port "; then
            return 0 # 端口被占用
        fi
    fi
    
    # 方法2: 使用lsof (如果可用)
    if command -v lsof &> /dev/null; then
        if lsof -i :$port -P -n | grep -q "LISTEN"; then
            return 0 # 端口被占用
        fi
    fi
    
    # 方法3: 使用ss (如果可用)
    if command -v ss &> /dev/null; then
        if ss -tuln | grep -q ":$port "; then
            return 0 # 端口被占用
        fi
    fi
    
    # 方法4: 尝试绑定到该端口 (最通用的方法)
    (echo >/dev/tcp/localhost/$port) 2>/dev/null
    if [ $? -eq 0 ]; then
        return 0 # 端口被占用
    fi
    
    return 1 # 端口未被占用
}

# 继续Nginx Proxy Manager安装流程
continue_npm_installation() {
    # 创建安装目录
    mkdir -p "$install_dir/data"
    mkdir -p "$install_dir/letsencrypt"
    
    echo ""
    echo -e "${GREEN}正在创建docker-compose.yml文件...${NC}"
    
    # 创建docker-compose.yml文件，不包含version属性
    cat > "$install_dir/docker-compose.yml" << EOF
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '$http_port:80'
      - '$ui_port:81'
      - '$https_port:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    environment:
      # 可选环境变量
      DB_MYSQL_HOST: ${DB_MYSQL_HOST:-""}
      DB_MYSQL_PORT: ${DB_MYSQL_PORT:-""}
      DB_MYSQL_USER: ${DB_MYSQL_USER:-""}
      DB_MYSQL_PASSWORD: ${DB_MYSQL_PASSWORD:-""}
      DB_MYSQL_NAME: ${DB_MYSQL_NAME:-""}
EOF
    
    echo -e "${GREEN}docker-compose.yml文件创建完成${NC}"
    echo ""
    
    # 询问是否配置外部数据库
    read -p "是否使用外部MySQL数据库? (y/n) [n]: " use_external_db
    use_external_db=${use_external_db:-n}
    
    if [[ "$use_external_db" == "y" ]]; then
        echo -e "${GREEN}请配置MySQL数据库连接信息:${NC}"
        read -p "数据库主机: " DB_MYSQL_HOST
        read -p "数据库端口 [3306]: " DB_MYSQL_PORT
        DB_MYSQL_PORT=${DB_MYSQL_PORT:-3306}
        read -p "数据库用户名: " DB_MYSQL_USER
        read -p "数据库密码: " DB_MYSQL_PASSWORD
        read -p "数据库名: " DB_MYSQL_NAME
        
        # 更新环境变量
        sed -i "s|DB_MYSQL_HOST: \"\"|DB_MYSQL_HOST: \"$DB_MYSQL_HOST\"|g" "$install_dir/docker-compose.yml"
        sed -i "s|DB_MYSQL_PORT: \"\"|DB_MYSQL_PORT: \"$DB_MYSQL_PORT\"|g" "$install_dir/docker-compose.yml"
        sed -i "s|DB_MYSQL_USER: \"\"|DB_MYSQL_USER: \"$DB_MYSQL_USER\"|g" "$install_dir/docker-compose.yml"
        sed -i "s|DB_MYSQL_PASSWORD: \"\"|DB_MYSQL_PASSWORD: \"$DB_MYSQL_PASSWORD\"|g" "$install_dir/docker-compose.yml"
        sed -i "s|DB_MYSQL_NAME: \"\"|DB_MYSQL_NAME: \"$DB_MYSQL_NAME\"|g" "$install_dir/docker-compose.yml"
    fi
    
    # 询问是否自定义其他环境变量
    read -p "是否添加其他自定义环境变量? (y/n) [n]: " add_custom_env
    add_custom_env=${add_custom_env:-n}
    
    if [[ "$add_custom_env" == "y" ]]; then
        echo -e "${GREEN}请添加自定义环境变量 (格式: KEY=VALUE)${NC}"
        echo -e "${YELLOW}输入 'done' 完成添加${NC}"
        
        # 临时文件
        temp_file=$(mktemp)
        
        # 添加环境变量
        while true; do
            read -p "环境变量 (或 'done' 结束): " env_var
            
            if [[ "$env_var" == "done" ]]; then
                break
            fi
            
            if [[ "$env_var" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
                key=$(echo $env_var | cut -d= -f1)
                value=$(echo $env_var | cut -d= -f2-)
                echo "      $key: \"$value\"" >> $temp_file
            else
                echo -e "${RED}无效的环境变量格式，请使用 KEY=VALUE 格式${NC}"
            fi
        done
        
        # 添加到docker-compose.yml
        if [ -s "$temp_file" ]; then
            # 在environment部分的末尾添加新的环境变量
            sed -i "/DB_MYSQL_NAME:/r $temp_file" "$install_dir/docker-compose.yml"
        fi
        
        # 删除临时文件
        rm -f $temp_file
    fi
    
    echo ""
    echo -e "${GREEN}配置完成，请确认以下信息:${NC}"
    echo "安装目录: $install_dir"
    echo "HTTP端口: $http_port"
    echo "HTTPS端口: $https_port"
    echo "管理界面端口: $ui_port"
    echo ""
    echo -e "${YELLOW}docker-compose.yml内容预览:${NC}"
    echo "----------------------------------------"
    cat "$install_dir/docker-compose.yml"
    echo "----------------------------------------"
    echo ""
    
    # 确认安装
    read -p "确认安装? (y/n) [y]: " confirm_install
    confirm_install=${confirm_install:-y}
    
    if [[ "$confirm_install" != "y" ]]; then
        echo -e "${YELLOW}安装已取消${NC}"
        read -p "按任意键返回..." -n1
        common_projects_menu
        return
    fi
    
    # 开始安装
    echo -e "${GREEN}开始安装 Nginx Proxy Manager...${NC}"
    
    # 进入安装目录
    cd "$install_dir"
    
    # 启动容器
    echo -e "${YELLOW}正在启动容器...${NC}"
    
    # 使用正确的docker-compose命令
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    # 检查是否成功启动
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Nginx Proxy Manager 安装成功!${NC}"
        echo -e "${GREEN}请使用以下信息登录:${NC}"
        echo -e "地址: ${BLUE}http://localhost:$ui_port${NC}"
        echo -e "邮箱: ${BLUE}admin@example.com${NC}"
        echo -e "密码: ${BLUE}changeme${NC}"
        echo -e "${YELLOW}首次登录后，系统会要求您更改默认邮箱和密码。${NC}"
    else
        echo -e "${RED}安装失败，请检查错误信息。${NC}"
    fi
    
    echo ""
    read -p "按任意键返回..." -n1
    common_projects_menu
}

# 安装Watchtower
install_watchtower() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      安装 Watchtower       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    
    # 检查Docker是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker未安装，请先安装Docker。${NC}"
        read -p "按任意键返回..." -n1
        common_projects_menu
        return
    fi
    
    # 项目信息
    echo -e "${BLUE}Watchtower${NC} 是一个自动更新Docker容器的工具。"
    echo -e "它会监控运行中的容器并在发现容器镜像有更新时自动更新容器。"
    echo -e "项目地址: ${BLUE}https://github.com/containrrr/watchtower${NC}"
    echo ""
    
    # 配置安装参数
    echo -e "${GREEN}请配置安装参数:${NC}"
    echo -e "${YELLOW}(按Enter使用默认值)${NC}"
    echo ""
    
    # 选择安装目录
    default_install_dir="$HOME/watchtower"
    read -p "安装目录 [$default_install_dir]: " install_dir
    install_dir=${install_dir:-$default_install_dir}
    
    # 配置监控间隔
    default_interval="86400" # 默认24小时
    echo -e "${YELLOW}监控间隔时间 (单位: 秒)${NC}"
    echo -e "${YELLOW}推荐值: 3600(1小时), 43200(12小时), 86400(24小时)${NC}"
    read -p "监控间隔 [$default_interval]: " interval
    interval=${interval:-$default_interval}
    
    # 配置是否清理旧镜像
    default_cleanup="false"
    read -p "是否自动清理旧镜像? (true/false) [$default_cleanup]: " cleanup
    cleanup=${cleanup:-$default_cleanup}
    
    # 配置通知选项
    read -p "是否配置邮件通知? (y/n) [n]: " setup_notifications
    setup_notifications=${setup_notifications:-n}
    
    # 邮件通知配置
    if [[ "$setup_notifications" == "y" ]]; then
        read -p "SMTP服务器: " SMTP_HOST
        read -p "SMTP端口 [25]: " SMTP_PORT
        SMTP_PORT=${SMTP_PORT:-25}
        read -p "SMTP用户名: " SMTP_USER
        read -p "SMTP密码: " SMTP_PASS
        read -p "通知发件人: " NOTIFICATION_EMAIL_FROM
        read -p "通知收件人: " NOTIFICATION_EMAIL_TO
    fi
    
    # 创建安装目录
    mkdir -p "$install_dir"
    
    echo ""
    echo -e "${GREEN}正在创建docker-compose.yml文件...${NC}"
    
    # 创建docker-compose.yml文件
    cat > "$install_dir/docker-compose.yml" << EOF
services:
  watchtower:
    image: containrrr/watchtower:latest
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - TZ=Asia/Shanghai
      - WATCHTOWER_CLEANUP=$cleanup
      - WATCHTOWER_POLL_INTERVAL=$interval
EOF
    
    # 如果配置了邮件通知，添加相关环境变量
    if [[ "$setup_notifications" == "y" ]]; then
        cat >> "$install_dir/docker-compose.yml" << EOF
      - WATCHTOWER_NOTIFICATIONS=email
      - WATCHTOWER_NOTIFICATION_EMAIL_FROM=$NOTIFICATION_EMAIL_FROM
      - WATCHTOWER_NOTIFICATION_EMAIL_TO=$NOTIFICATION_EMAIL_TO
      - WATCHTOWER_NOTIFICATION_EMAIL_SERVER=$SMTP_HOST
      - WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PORT=$SMTP_PORT
      - WATCHTOWER_NOTIFICATION_EMAIL_SERVER_USER=$SMTP_USER
      - WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PASSWORD=$SMTP_PASS
EOF
    fi
    
    echo -e "${GREEN}docker-compose.yml文件创建完成${NC}"
    echo ""
    
    # 询问监控特定容器
    read -p "是否只监控特定容器? (y/n) [n]: " monitor_specific
    monitor_specific=${monitor_specific:-n}
    
    if [[ "$monitor_specific" == "y" ]]; then
        echo -e "${YELLOW}获取所有容器...${NC}"
        
        if [ -z "$(docker ps -q)" ]; then
            echo -e "${RED}错误: 没有找到任何运行中的Docker容器。${NC}"
            echo -e "${YELLOW}将监控所有容器。${NC}"
        else
            # 使用数组存储容器信息
            container_ids=()
            container_names=()
            
            # 显示容器列表
            echo -e "\n${GREEN}容器列表:${NC}"
            echo -e "${GREEN}=============================${NC}"
            echo -e "序号\t容器ID\t\t\t名称"
            echo -e "${GREEN}=============================${NC}"
            
            # 获取运行中容器信息并显示
            count=1
            while read -r line; do
                container_id=$(echo "$line" | awk '{print $1}')
                container_ids+=("$container_id")
                container_name=$(echo "$line" | awk '{print $2}')
                container_names+=("$container_name")
                
                echo -e "${BLUE}$count)${NC}\t$container_id\t$container_name"
                ((count++))
            done < <(docker ps --format "{{.ID}} {{.Names}}")
            
            echo -e "${GREEN}=============================${NC}"
            echo -e "${YELLOW}提示: 您可以选择多个容器 (例如: 1 3 5)${NC}"
            
            # 让用户选择要监控的容器
            read -p "请选择要监控的容器序号 [1-$((count-1))], 使用空格分隔，或输入 'a' 监控所有容器: " choice
            
            if [[ "$choice" != "a" ]]; then
                monitored_containers=""
                
                # 解析用户输入的序号
                for num in $choice; do
                    # 验证输入是否是数字
                    if ! [[ "$num" =~ ^[0-9]+$ ]]; then
                        echo -e "${RED}错误: '$num' 不是有效的数字。将监控所有容器。${NC}"
                        break
                    fi
                    
                    # 检查输入数字是否有效
                    if [ "$num" -lt 1 ] || [ "$num" -gt $((count-1)) ]; then
                        echo -e "${RED}错误: '$num' 不是有效的容器序号。将监控所有容器。${NC}"
                        break
                    fi
                    
                    # 添加到监控列表
                    container_idx=$((num-1))
                    cname=${container_names[$container_idx]}
                    
                    if [ -z "$monitored_containers" ]; then
                        monitored_containers="$cname"
                    else
                        monitored_containers="$monitored_containers $cname"
                    fi
                done
                
                # 如果有选择容器，添加到docker-compose配置
                if [ ! -z "$monitored_containers" ]; then
                    echo "      - WATCHTOWER_SCOPE=$monitored_containers" >> "$install_dir/docker-compose.yml"
                    echo -e "${GREEN}Watchtower 将只监控以下容器: $monitored_containers${NC}"
                fi
            else
                echo -e "${GREEN}Watchtower 将监控所有容器${NC}"
            fi
        fi
    else
        echo -e "${GREEN}Watchtower 将监控所有容器${NC}"
    fi
    
    # 添加命令行参数
    read -p "是否添加其他命令行参数? (y/n) [n]: " add_cmd_args
    add_cmd_args=${add_cmd_args:-n}
    
    if [[ "$add_cmd_args" == "y" ]]; then
        echo -e "${YELLOW}常用的命令行参数:${NC}"
        echo -e "  --debug                  启用调试模式"
        echo -e "  --no-restart             更新后不重启容器"
        echo -e "  --run-once               运行一次后退出"
        echo -e "  --include-stopped        包含已停止的容器"
        echo -e "  --revive-stopped         恢复曾经运行过的容器"
        
        read -p "请输入要添加的命令行参数: " cmd_args
        
        if [ ! -z "$cmd_args" ]; then
            # 添加命令行参数到配置
            echo "    command: $cmd_args" >> "$install_dir/docker-compose.yml"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}配置完成，请确认以下信息:${NC}"
    echo "安装目录: $install_dir"
    echo "监控间隔: $interval 秒"
    echo "自动清理旧镜像: $cleanup"
    echo ""
    echo -e "${YELLOW}docker-compose.yml内容预览:${NC}"
    echo "----------------------------------------"
    cat "$install_dir/docker-compose.yml"
    echo "----------------------------------------"
    echo ""
    
    # 确认安装
    read -p "确认安装? (y/n) [y]: " confirm_install
    confirm_install=${confirm_install:-y}
    
    if [[ "$confirm_install" != "y" ]]; then
        echo -e "${YELLOW}安装已取消${NC}"
        read -p "按任意键返回..." -n1
        common_projects_menu
        return
    fi
    
    # 开始安装
    echo -e "${GREEN}开始安装 Watchtower...${NC}"
    
    # 进入安装目录
    cd "$install_dir"
    
    # 启动容器
    echo -e "${YELLOW}正在启动容器...${NC}"
    
    # 使用正确的docker-compose命令
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    # 检查是否成功启动
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Watchtower 安装成功!${NC}"
        echo -e "${YELLOW}Watchtower 将按配置的时间间隔($interval秒)自动检查并更新容器。${NC}"
        
        if [[ "$cleanup" == "true" ]]; then
            echo -e "${YELLOW}自动清理已启用，更新后将自动删除旧的镜像。${NC}"
        fi
    else
        echo -e "${RED}安装失败，请检查错误信息。${NC}"
    fi
    
    echo ""
    read -p "按任意键返回..." -n1
    common_projects_menu
}

# 更新脚本
update_script() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      更新 Docker 管理工具      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${YELLOW}当前版本: ${SCRIPT_VERSION}${NC}"
    echo -e "${YELLOW}正在检查更新...${NC}"
    
    # 创建临时文件
    TMP_FILE=$(mktemp)
    
    # 下载新脚本
    if curl -s "$SCRIPT_UPDATE_URL" -o "$TMP_FILE"; then
        # 检查下载的脚本是否包含版本号
        NEW_VERSION=$(grep "SCRIPT_VERSION=" "$TMP_FILE" | head -n 1 | cut -d'"' -f2)
        
        if [ -z "$NEW_VERSION" ]; then
            echo -e "${RED}错误: 无法获取新版本信息。${NC}"
            rm -f "$TMP_FILE"
            read -p "按任意键返回..." -n1
            show_main_menu
            return
        fi
        
        echo -e "${GREEN}发现新版本: ${NEW_VERSION}${NC}"
        
        # 比较版本号
        if [ "$SCRIPT_VERSION" = "$NEW_VERSION" ]; then
            echo -e "${GREEN}您已经使用最新版本!${NC}"
            rm -f "$TMP_FILE"
            read -p "按任意键返回..." -n1
            show_main_menu
            return
        fi
        
        # 确认更新
        read -p "是否更新到新版本? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            echo -e "${YELLOW}更新已取消${NC}"
            rm -f "$TMP_FILE"
            read -p "按任意键返回..." -n1
            show_main_menu
            return
        fi
        
        # 备份当前脚本
        BACKUP_FILE="docker.sh.bak.$(date +%Y%m%d%H%M%S)"
        cp "$(readlink -f "$0")" "$BACKUP_FILE"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}错误: 无法创建备份文件。${NC}"
            rm -f "$TMP_FILE"
            read -p "按任意键返回..." -n1
            show_main_menu
            return
        fi
        
        echo -e "${GREEN}已创建备份文件: ${BACKUP_FILE}${NC}"
        
        # 替换当前脚本
        cat "$TMP_FILE" > "$(readlink -f "$0")"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}错误: 无法更新脚本。尝试使用sudo权限。${NC}"
            sudo cat "$TMP_FILE" > "$(readlink -f "$0")"
            
            if [ $? -ne 0 ]; then
                echo -e "${RED}更新失败，将恢复备份。${NC}"
                cp "$BACKUP_FILE" "$(readlink -f "$0")"
                rm -f "$TMP_FILE"
                read -p "按任意键返回..." -n1
                show_main_menu
                return
            fi
        fi
        
        # 设置执行权限
        chmod +x "$(readlink -f "$0")"
        
        echo -e "${GREEN}脚本已更新到版本 ${NEW_VERSION}!${NC}"
        echo -e "${YELLOW}请重新启动脚本以应用更改。${NC}"
        
        # 清理临时文件
        rm -f "$TMP_FILE"
        
        # 询问用户是否立即重启脚本
        read -p "是否立即重启脚本? (y/n): " restart
        if [ "$restart" = "y" ]; then
            exec "$(readlink -f "$0")"
            exit 0
        else
            read -p "按任意键退出..." -n1
            exit 0
        fi
    else
        echo -e "${RED}错误: 无法连接到更新服务器。${NC}"
        rm -f "$TMP_FILE"
        read -p "按任意键返回..." -n1
        show_main_menu
    fi
}

# 删除脚本
delete_script() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${RED}      删除 Docker 管理工具      ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${RED}警告: 此操作将永久删除此脚本文件!${NC}"
    echo -e "${YELLOW}脚本路径: $(readlink -f "$0")${NC}"
    echo ""
    
    # 确认删除
    read -p "确定要删除此脚本吗? 此操作不可恢复! (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}删除操作已取消${NC}"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    # 再次确认
    read -p "再次确认: 您确定要删除此脚本吗? (yes/no): " confirm2
    if [ "$confirm2" != "yes" ]; then
        echo -e "${YELLOW}删除操作已取消${NC}"
        read -p "按任意键返回..." -n1
        show_main_menu
        return
    fi
    
    # 删除脚本
    echo -e "${YELLOW}正在删除脚本...${NC}"
    rm -f "$(readlink -f "$0")"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}脚本已成功删除!${NC}"
        echo -e "${YELLOW}感谢您使用 Docker 管理工具，再见!${NC}"
        sleep 2
        exit 0
    else
        echo -e "${RED}删除失败，尝试使用sudo权限...${NC}"
        sudo rm -f "$(readlink -f "$0")"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}脚本已成功删除!${NC}"
            echo -e "${YELLOW}感谢您使用 Docker 管理工具，再见!${NC}"
            sleep 2
            exit 0
        else
            echo -e "${RED}删除失败，请手动删除脚本。${NC}"
            echo -e "${YELLOW}脚本路径: $(readlink -f "$0")${NC}"
            read -p "按任意键返回..." -n1
            show_main_menu
        fi
    fi
}

# 显示主菜单
show_main_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      Docker 管理工具       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo -e "${YELLOW}      版本: ${SCRIPT_VERSION}      ${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} Docker-Compose 管理"
    echo -e "${BLUE}2.${NC} Docker 容器管理"
    echo -e "${BLUE}3.${NC} 常见项目安装"
    echo -e "${BLUE}4.${NC} 更新脚本"
    echo -e "${BLUE}5.${NC} 删除脚本"
    echo -e "${BLUE}0.${NC} 退出"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-5]: " choice

    case $choice in
        1)
            docker_compose_menu
            ;;
        2)
            docker_container_menu
            ;;
        3)
            common_projects_menu
            ;;
        4)
            update_script
            ;;
        5)
            delete_script
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

# 启动脚本
show_main_menu
