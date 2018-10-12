#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# delete services
kubectl delete svc,deploy -l component=mozart

# delete mozart configmap
kubectl get configmap hysds-mozart-config 2>/dev/null
if [ $? -eq 0 ]; then
  kubectl delete configmap hysds-mozart-config
fi

# delete global configmap
kubectl get configmap hysds-global-config 2>/dev/null
if [ $? -eq 0 ]; then
  kubectl delete configmap hysds-global-config
fi

# delete global secrets
kubectl get secret hysds-global-secrets 2>/dev/null
if [ $? -eq 0 ]; then
  kubectl delete secret hysds-global-secrets
fi

# delete secrets
rm -rf ${BASE_PATH}/secrets
