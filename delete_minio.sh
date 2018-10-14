#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# delete services
kubectl delete svc,deploy -l component=object-store

# delete pvc
kubectl delete pvc minio-pv-claim
