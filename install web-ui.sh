#!/bin/bash
set -e

echo "更新软件包列表..."
sudo apt update

echo "安装 Python3.11、venv 及开发包（如果尚未安装）..."
sudo apt install -y python3.11 python3.11-venv python3.11-dev

VENV_DIR="open-webui-env"
if [ ! -d "$VENV_DIR" ]; then
    echo "正在创建名为 '$VENV_DIR' 的虚拟环境..."
    python3.11 -m venv "$VENV_DIR"
fi

echo "激活虚拟环境..."
source "$VENV_DIR/bin/activate"

echo "升级 pip..."
pip install --upgrade pip

echo "安装 open-webui..."
pip install open-webui

echo "open-webui 安装完成！"
echo "以后使用时，请通过以下命令激活虚拟环境："
echo "source $VENV_DIR/bin/activate"
