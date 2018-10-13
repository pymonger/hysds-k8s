#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# create global secrets
create_global_secrets

# create global configmap
create_global_config

# create grq configmap
create_comp_config grq

# deploy grq services
kubectl create -f ${BASE_PATH}/grq/grq-redis.yaml \
               -f ${BASE_PATH}/grq/grq-elasticsearch.yaml \
               -f ${BASE_PATH}/grq/grq.yaml
