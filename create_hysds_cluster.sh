#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# create global configmap
kubectl create configmap hysds-global-config --from-file=${BASE_PATH}/config

# deploy mozart services
${BASE_PATH}/create_mozart.sh

# deploy grq services
${BASE_PATH}/create_grq.sh

# sleep
sleep 5

# list urls
${BASE_PATH}/get_mozart_urls.sh
${BASE_PATH}/get_grq_urls.sh
