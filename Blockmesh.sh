#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Blockmesh.sh"
LOG_FILE="$HOME/blockmesh/blockmesh.log"  # 日志文件路径

# 创建日志文件并重定向输出
exec > >(tee -a "$LOG_FILE") 2>&1

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 部署节点"
        echo "2. 查看日志"
        echo "3. 退出"

        read -p "请输入选项 (1-3): " option

        case $option in
            1)
                deploy_node
                ;;
            2)
                view_logs
                ;;
            3)
                echo "退出脚本。"
                exit 0
                ;;
            *)
                echo "无效选项，请重新输入。"
                read -p "按任意键继续..."
                ;;
        esac
    done
}

# 部署节点
function deploy_node() {
    echo "正在更新系统..."
    sudo apt update -y && sudo apt upgrade -y
    
    # 创建 blockmesh 目录
    BLOCKMESH_DIR="$HOME/blockmesh"
    LOG_FILE="$BLOCKMESH_DIR/blockmesh.log"
    
    # 检查并创建目录
    if [ -d "$BLOCKMESH_DIR" ]; then
        echo "目录 $BLOCKMESH_DIR 已存在，正在删除..."
        rm -rf "$BLOCKMESH_DIR"
    fi
    mkdir -p "$BLOCKMESH_DIR"
    echo "创建目录：$BLOCKMESH_DIR"
    
    # 切换到 blockmesh 目录
    cd "$BLOCKMESH_DIR"
    
    # 下载和解压
    echo "正在下载 blockmesh-cli..."
    wget -q "https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.321/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz" -O blockmesh-cli.tar.gz
    
    # 检查下载是否成功
    if [ ! -f "blockmesh-cli.tar.gz" ]; then
        echo "错误：下载失败"
        exit 1
    fi
    
    echo "正在解压缩 blockmesh-cli..."
    tar -xzvf blockmesh-cli.tar.gz  # 添加 v 参数查看解压过程
    
    # 检查解压后的文件
    echo "检查解压后的文件结构："
    ls -R
    
    # 尝试找到 blockmesh-cli
    echo "搜索 blockmesh-cli 文件："
    find . -name "blockmesh-cli" -type f
    
    # 如果找到文件，使用第一个匹配项
    FOUND_CLI=$(find . -name "blockmesh-cli" -type f | head -n 1)
    
    if [ -n "$FOUND_CLI" ]; then
        BLOCKMESH_CLI_PATH="$BLOCKMESH_DIR/$FOUND_CLI"
        echo "找到 blockmesh-cli：$BLOCKMESH_CLI_PATH"
        
        chmod +x "$BLOCKMESH_CLI_PATH"
        
        # 获取用户输入
        read -p "请输入您的 BlockMesh 邮箱: " BLOCKMESH_EMAIL
        read -sp "请输入您的 BlockMesh 密码: " BLOCKMESH_PASSWORD
        echo
        
        # 运行程序
        echo "正在启动 blockmesh-cli..."
        cd "$(dirname "$BLOCKMESH_CLI_PATH")"
        ./blockmesh-cli --email "$BLOCKMESH_EMAIL" --password "$BLOCKMESH_PASSWORD" > "$LOG_FILE" 2>&1 &
        
        echo "脚本执行完成。"
    else
        echo "错误：无法找到 blockmesh-cli 文件"
        echo "当前目录内容："
        ls -la
        exit 1
    fi
    
    read -p "按任意键返回主菜单..."
}

# 查看日志
function view_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "查看日志内容："
        cat "$LOG_FILE"
    else
        echo "日志文件不存在：$LOG_FILE"
    fi
    read -p "按任意键返回主菜单..."
}

# 启动主菜单
main_menu
