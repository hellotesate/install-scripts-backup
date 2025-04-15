#!/bin/bash
# -------------------------
# Docker 自动安装脚本（增强版，适配多种启动方式）
# 支持: Ubuntu / Debian / CentOS / RHEL / Fedora 以及其他 init 系统
# 如系统中无 systemctl/service，则尝试安装 systemd
# 请以 root 用户或 sudo 执行此脚本
# -------------------------

# 检查是否以 root 执行
if [[ $EUID -ne 0 ]]; then
    echo "请使用 root 权限或使用 sudo 运行此脚本。"
    exit 1
fi

# 检查是否已安装 Docker，避免重复安装
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

        # 更新 apt 包索引，并安装支持 HTTPS 的依赖包
        apt-get update
        apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

        # 添加 Docker 官方 GPG 密钥
        curl -fsSL https://download.docker.com/linux/$OS_ID/gpg | apt-key add -

        # 获取发行版代号，优先使用 /etc/os-release 中的 VERSION_CODENAME
        if [ -n "$VERSION_CODENAME" ]; then
            codename=$VERSION_CODENAME
        else
            codename=$(lsb_release -cs)
        fi

        # 添加 Docker 稳定版仓库
        if [ "$OS_ID" == "ubuntu" ]; then
            add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $codename stable"
        elif [ "$OS_ID" == "debian" ]; then
            echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian $codename stable" \
                 > /etc/apt/sources.list.d/docker.list
        fi

        # 更新 apt 缓存
        apt-get update

        # 安装 Docker CE、Docker CE CLI 及 containerd.io
        apt-get install -y docker-ce docker-ce-cli containerd.io

        # 检查 apt 是否发现 docker-ce 的候选版本
        if ! apt-cache policy docker-ce | grep -q Candidate; then
            echo "错误：docker-ce 软件包没有候选版本，请检查源配置或系统版本是否受支持。"
            exit 1
        fi
        ;;
    centos|rhel|fedora)
        echo "正在为 $OS_ID 系统设置 Docker 安装环境..."

        # 安装所需依赖包
        yum install -y yum-utils device-mapper-persistent-data lvm2

        # 添加 Docker 仓库
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

        # 安装 Docker CE、Docker CE CLI 及 containerd.io
        yum install -y docker-ce docker-ce-cli containerd.io
        ;;
    *)
        echo "当前系统 ($OS_ID) 不在脚本支持的范围内。请参考 Docker 官方文档进行安装。"
        exit 1
        ;;
esac

# 启动 Docker 服务及设置开机自启
echo "正在启动 Docker 服务..."

if command -v systemctl &> /dev/null; then
    # 使用 systemctl 启动并设置自启
    systemctl start docker
    systemctl enable docker
elif command -v service &> /dev/null; then
    # 使用传统 service 启动，并尝试设置自启
    service docker start
    if [ -x /usr/sbin/update-rc.d ]; then
       update-rc.d docker defaults
    elif [ -x /sbin/chkconfig ]; then
       chkconfig docker on
    else
       echo "未找到设置开机自启的工具，请手动配置。"
    fi
else
    echo "未检测到 systemctl 或 service 命令。"
    echo "尝试自动安装 systemd 以获得 systemctl 功能..."

    # 根据包管理器安装 systemd（注意：这可能会切换系统 init 机制，建议先备份数据）
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y systemd systemd-sysv
    elif command -v yum &> /dev/null; then
        yum install -y systemd systemd-sysv
    else
        echo "未能识别包管理器，无法自动安装 systemd，请手动安装。"
        exit 1
    fi

    echo "systemd 已安装，系统可能需要重启以切换到 systemd init，请重启系统后再次启动 Docker 服务。"
    exit 0
fi

# 最终验证 Docker 是否安装成功，并输出版本信息
if command -v docker &> /dev/null; then
    echo "Docker 安装并启动成功！版本信息："
    docker --version
else
    echo "Docker 启动失败，请检查错误信息。"
    exit 1
fi
