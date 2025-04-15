#!/bin/bash
set -e

#---------------------------------------------------
# 配置部分：修改以下变量，根据你的系统版本和架构要求进行设置
#---------------------------------------------------

# Debian 发行版本：例如 bullseye、buster 或 bookworm
DEBIAN_RELEASE="bullseye"

# 系统架构：例如 amd64, armhf, arm64, s390x
ARCH="amd64"

# 以下变量中的版本号仅为示例，请根据需要更新为当前最新版本
CONTAINERD_VERSION="1.6.21-1"
DOCKER_CE_VERSION="5:23.0.3~3-0~debian-bullseye"
DOCKER_CE_CLI_VERSION="5:23.0.3~3-0~debian-bullseye"
DOCKER_BUILDX_PLUGIN_VERSION="0.10.5~debian-bullseye"
DOCKER_COMPOSE_PLUGIN_VERSION="2.20.2~debian-bullseye"

# Docker deb 文件所在的基础 URL
BASE_URL="https://download.docker.com/linux/debian/dists/${DEBIAN_RELEASE}/pool/stable/${ARCH}"

#---------------------------------------------------
# 构造各个包的文件名
#---------------------------------------------------

FILE_CONTAINERD="containerd.io_${CONTAINERD_VERSION}_${ARCH}.deb"
FILE_DOCKER_CE="docker-ce_${DOCKER_CE_VERSION}_${ARCH}.deb"
FILE_DOCKER_CE_CLI="docker-ce-cli_${DOCKER_CE_CLI_VERSION}_${ARCH}.deb"
FILE_DOCKER_BUILDX_PLUGIN="docker-buildx-plugin_${DOCKER_BUILDX_PLUGIN_VERSION}_${ARCH}.deb"
FILE_DOCKER_COMPOSE_PLUGIN="docker-compose-plugin_${DOCKER_COMPOSE_PLUGIN_VERSION}_${ARCH}.deb"

echo "将从以下路径下载 Docker 包："
echo "${BASE_URL}"
echo ""

#---------------------------------------------------
# 下载所有所需的 deb 文件
#---------------------------------------------------
echo "下载 ${FILE_CONTAINERD} ..."
curl -L -o "${FILE_CONTAINERD}" "${BASE_URL}/${FILE_CONTAINERD}"

echo "下载 ${FILE_DOCKER_CE} ..."
curl -L -o "${FILE_DOCKER_CE}" "${BASE_URL}/${FILE_DOCKER_CE}"

echo "下载 ${FILE_DOCKER_CE_CLI} ..."
curl -L -o "${FILE_DOCKER_CE_CLI}" "${BASE_URL}/${FILE_DOCKER_CE_CLI}"

echo "下载 ${FILE_DOCKER_BUILDX_PLUGIN} ..."
curl -L -o "${FILE_DOCKER_BUILDX_PLUGIN}" "${BASE_URL}/${FILE_DOCKER_BUILDX_PLUGIN}"

echo "下载 ${FILE_DOCKER_COMPOSE_PLUGIN} ..."
curl -L -o "${FILE_DOCKER_COMPOSE_PLUGIN}" "${BASE_URL}/${FILE_DOCKER_COMPOSE_PLUGIN}"

#---------------------------------------------------
# 安装下载的 deb 文件
#---------------------------------------------------
echo ""
echo "开始安装 Docker 相关包..."
sudo dpkg -i ./"${FILE_CONTAINERD}" ./"${FILE_DOCKER_CE}" ./"${FILE_DOCKER_CE_CLI}" ./"${FILE_DOCKER_BUILDX_PLUGIN}" ./"${FILE_DOCKER_COMPOSE_PLUGIN}"

#---------------------------------------------------
# 启动 Docker 服务并测试
#---------------------------------------------------
echo ""
echo "启动 Docker 服务..."
sudo service docker start

echo "运行 hello-world 测试容器..."
sudo docker run hello-world

echo ""
echo "Docker 安装与测试完毕！"
