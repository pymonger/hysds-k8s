#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# create global configmap
kubectl get configmap hysds-global-config
if [ $? -ne 0 ]; then
  kubectl create configmap hysds-global-config --from-file=${BASE_PATH}/config
fi

# create mozart configmap
kubectl create configmap hysds-mozart-config --from-file=${BASE_PATH}/mozart/config

# deploy mozart services
kubectl create -f ${BASE_PATH}/mozart/mozart-redis.yaml \
               -f ${BASE_PATH}/mozart/mozart-elasticsearch.yaml \
               -f ${BASE_PATH}/mozart/mozart-rabbitmq.yaml \
               -f ${BASE_PATH}/mozart/mozart.yaml
