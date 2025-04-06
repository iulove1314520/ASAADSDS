#!/bin/bash

# Docker管理脚本

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

# 显示主菜单
show_main_menu() {
    clear
    echo -e "${GREEN}=============================${NC}"
    echo -e "${GREEN}      Docker 管理工具       ${NC}"
    echo -e "${GREEN}=============================${NC}"
    echo ""
    echo -e "${BLUE}1.${NC} Docker-Compose 管理"
    echo -e "${BLUE}2.${NC} Docker 容器管理"
    echo -e "${BLUE}0.${NC} 退出"
    echo ""
    echo -e "${GREEN}=============================${NC}"
    echo ""
    read -p "请选择操作 [0-2]: " choice

    case $choice in
        1)
            docker_compose_menu
            ;;
        2)
            echo "Docker 容器管理功能暂未实现"
            read -p "按任意键返回主菜单..." -n1
            show_main_menu
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
