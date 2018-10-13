#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# create global secrets
create_global_secrets

# create global configmap
create_global_config

# create mozart configmap
create_comp_config mozart

# deploy mozart services
kubectl create -f ${BASE_PATH}/mozart/mozart-redis.yaml \
               -f ${BASE_PATH}/mozart/mozart-elasticsearch.yaml \
               -f ${BASE_PATH}/mozart/mozart-rabbitmq.yaml \
               -f ${BASE_PATH}/mozart/mozart.yaml
