#!/bin/sh
#chkconfig:2345 30 80
#description: 运行docker-compose服务

WORK_DIR=$(dirname $(readlink -f "$0"))

# 加载环境变量
source "$WORK_DIR"/.env

set -ex

#使用说明，用来提示输入参数
usage() {
  echo "
  Usage: sh run.sh [init|up|ps|stop|down]
    init 初始化安装docker
    up 启动全部服务
    ps 查看运行状态
    stop 停止全部服务
    down 移除全部服务
  "
  exit 1
}

install_docker() {
  curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
  mkdir -p /etc/docker
  cat > /etc/docker/daemon.json <<EOF
  {
    "registry-mirrors": [
      "https://ustc-edu-cn.mirror.aliyuncs.com"
    ],
    "insecure-registries": [
      "${BASE_REGISTRY}"
    ],
    "experimental": true
  }
EOF

  systemctl enable docker && \
  systemctl daemon-reload && \
  systemctl restart docker

  # 开启 ip 转发
  sed -i 's/^net.ipv4.ip_forward.*$/net.ipv4.ip_forward=1/' /etc/sysctl.conf
  sed -i 's/^net.bridge.bridge-nf-call-iptables.*$/net.bridge.bridge-nf-call-iptables=1/' /etc/sysctl.conf
  sed -i 's/^net.bridge.bridge-nf-call-ip6tables.*$/net.bridge.bridge-nf-call-ip6tables=1/' /etc/sysctl.conf

  sysctl -p

  [ ! -x "$(command -v docker)" ] || echo 'docker安装完成'
}

# 初始化
init() {
    [ -x "$(command -v docker)" ] || install_docker
}

# 启动全部服务
up() {
  docker compose up -d
}

# 查看运行状态
ps() {
  docker compose ps
}

# 停止全部服务
stop() {
  docker compose stop
}

# 移除全部服务
down() {
  docker compose down
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
"up")
  up
  ;;
"ps")
  ps
  ;;
"stop")
  stop
  ;;
"down")
  down
  ;;
*)
  usage
  ;;
esac