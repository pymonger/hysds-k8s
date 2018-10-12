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

# create grq configmap
kubectl get configmap hysds-grq-config 2>/dev/null
if [ $? -ne 0 ]; then
  kubectl create configmap hysds-grq-config --from-file=${BASE_PATH}/grq/config
fi

# deploy grq services
kubectl create -f ${BASE_PATH}/grq/grq-redis.yaml \
               -f ${BASE_PATH}/grq/grq-elasticsearch.yaml \
               -f ${BASE_PATH}/grq/grq.yaml
