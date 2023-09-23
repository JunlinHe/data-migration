#!/bin/sh
#chkconfig:2345 30 80
#description: 构建flyway镜像

WORK_DIR=$(dirname $(readlink -f "$0"))
PROJECT_DIR=$(dirname $(dirname ${WORK_DIR}))

echo "加载环境变量"
source "${WORK_DIR}"/.env

set -ex

echo "构建flyway镜像"
cd $PROJECT_DIR
BASE_FLYWAY_IMG="${BASE_REGISTRY}/${BASE_PROJECT}/flyway:${BASE_TAG}"
rm -rf app/flyway/sql
cp -r ../sql app/flyway
docker build -t ${BASE_FLYWAY_IMG} -f app/flyway/Dockerfile app/flyway
rm -rf app/flyway/sql