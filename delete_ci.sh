#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# delete services
kubectl delete svc,deploy -l component=ci

# delete ci configmap
delete_comp_config ci

# delete global configmap
delete_global_config

# delete global secrets
delete_global_secrets
