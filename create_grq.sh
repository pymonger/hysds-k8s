#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# create configmap
kubectl create configmap hysds-grq-config --from-file=${BASE_PATH}/grq/config

# deploy grq services
kubectl create -f ${BASE_PATH}/grq/grq-redis.yaml \
               -f ${BASE_PATH}/grq/grq-elasticsearch.yaml \
               -f ${BASE_PATH}/grq/grq.yaml
