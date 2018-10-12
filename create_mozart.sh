#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# create global secrets
kubectl get secret hysds-global-secrets 2>/dev/null
if [ $? -ne 0 ]; then
  mkdir -p ${BASE_PATH}/secrets
  ssh-keygen -f ${BASE_PATH}/secrets/id_rsa -t rsa -N ''
  kubectl create secret generic hysds-global-secrets --from-file=${BASE_PATH}/secrets
fi

# create global configmap
kubectl get configmap hysds-global-config 2>/dev/null
if [ $? -ne 0 ]; then
  kubectl create configmap hysds-global-config --from-file=${BASE_PATH}/config
fi

# create mozart configmap
kubectl get configmap hysds-mozart-config 2>/dev/null
if [ $? -ne 0 ]; then
  kubectl create configmap hysds-mozart-config --from-file=${BASE_PATH}/mozart/config
fi

# deploy mozart services
kubectl create -f ${BASE_PATH}/mozart/mozart-redis.yaml \
               -f ${BASE_PATH}/mozart/mozart-elasticsearch.yaml \
               -f ${BASE_PATH}/mozart/mozart-rabbitmq.yaml \
               -f ${BASE_PATH}/mozart/mozart.yaml
