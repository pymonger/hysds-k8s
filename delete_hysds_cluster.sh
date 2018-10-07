#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# delete mozart services
${BASE_PATH}/delete_mozart.sh

# delete grq services
${BASE_PATH}/delete_grq.sh

# delete global configmap
kubectl delete configmap hysds-global-config
