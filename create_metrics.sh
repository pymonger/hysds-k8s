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

# create metrics configmap
kubectl get configmap hysds-metrics-config 2>/dev/null
if [ $? -ne 0 ]; then
  kubectl create configmap hysds-metrics-config --from-file=${BASE_PATH}/metrics/config
fi

# deploy metrics services
kubectl create -f ${BASE_PATH}/metrics/metrics-redis.yaml \
               -f ${BASE_PATH}/metrics/metrics-elasticsearch.yaml \
               -f ${BASE_PATH}/metrics/metrics.yaml
