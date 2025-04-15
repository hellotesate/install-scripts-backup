#!/bin/bash
# -------------------------
# Docker 自动安装脚本
# 支持: Ubuntu / Debian / CentOS / RHEL / Fedora
# 使用前请确保以 root 用户运行或使用 sudo 运行。
# -------------------------

# 检查是否以 root 执行
if [[ $EUID -ne 0 ]]; then
    echo "请使用 root 权限或使用 sudo 运行此脚本。"
    exit 1
fi

# 检查是否已经安装了 docker
if command -v docker &> /dev/null; then
    echo "检测到 Docker 已经安装，退出安装。"
    exit 0
fi

# 加载系统发行版信息
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    echo "无法检测系统发行版，退出。"
    exit 1
fi

echo "检测到的操作系统: $PRETTY_NAME"

case "$OS_ID" in
    ubuntu|debian)
        echo "正在为 $OS_ID 系统设置 Docker 安装环境..."
        # 更新 apt 包索引
        apt-get update
        # 安装必要的包
        apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        # 添加 Docker 官方 GPG 密钥
        curl -fsSL https://download.docker.com/linux/${OS_ID}/gpg | apt-key add -
        # 设置稳定版仓库; 获取发行版代号（例如: focal 或 buster）
        if command -v lsb_release &> /dev/null; then
            codename=$(lsb_release -cs)
        else
            # 若系统中没有 lsb_release，则尝试从 /etc/os-release 中获取
            codename=${VERSION_CODENAME}
        fi
        add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/${OS_ID} ${codename} stable"
        # 更新包索引并安装 Docker CE
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io
        ;;
    centos|rhel|fedora)
        echo "正在为 $OS_ID 系统设置 Docker 安装环境..."
        # 安装依赖包
        yum install -y yum-utils device-mapper-persistent-data lvm2
        # 添加 Docker 仓库
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        # 安装 Docker CE
        yum install -y docker-ce docker-ce-cli containerd.io
        ;;
    *)
        echo "当前系统 ($OS_ID) 不在脚本支持的范围内。请参考 Docker 官方文档进行安装。"
        exit 1
        ;;
esac

# 启动 Docker 服务并设置开机自启
systemctl start docker
systemctl enable docker

# 验证 Docker 是否安装成功
if command -v docker &> /dev/null; then
    echo "Docker 安装成功！"
    docker --version
else
    echo "Docker 安装失败，请检查错误信息。"
    exit 1
fi
