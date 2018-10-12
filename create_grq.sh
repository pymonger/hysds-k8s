#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# create global configmap
kubectl get configmap hysds-global-config
if [ $? -ne 0 ]; then
  kubectl create configmap hysds-global-config --from-file=${BASE_PATH}/config
fi

# create grq configmap
kubectl create configmap hysds-grq-config --from-file=${BASE_PATH}/grq/config

# deploy grq services
kubectl create -f ${BASE_PATH}/grq/grq-redis.yaml \
               -f ${BASE_PATH}/grq/grq-elasticsearch.yaml \
               -f ${BASE_PATH}/grq/grq.yaml
