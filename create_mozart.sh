#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# create configmaps
kubectl create configmap hysds-global-config --from-file=${BASE_PATH}/config
kubectl create configmap hysds-mozart-config --from-file=${BASE_PATH}/mozart/config

# start services
kubectl create -f ${BASE_PATH}/mozart/mozart-redis.yaml \
               -f ${BASE_PATH}/mozart/mozart-elasticsearch.yaml \
               -f ${BASE_PATH}/mozart/mozart-rabbitmq.yaml \
               -f ${BASE_PATH}/mozart/mozart.yaml
sleep 5

# echo mozart interfaces
${BASE_PATH}/get_mozart_urls.sh
