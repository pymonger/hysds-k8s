#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# deploy mozart services
${BASE_PATH}/create_mozart.sh

# deploy metrics services
${BASE_PATH}/create_metrics.sh

# deploy grq services
${BASE_PATH}/create_grq.sh

# deploy factotum services
${BASE_PATH}/create_factotum.sh

# deploy ci services
${BASE_PATH}/create_ci.sh

# sleep
sleep 5

# list urls
${BASE_PATH}/get_mozart_urls.sh
${BASE_PATH}/get_metrics_urls.sh
${BASE_PATH}/get_grq_urls.sh
${BASE_PATH}/get_ci_urls.sh
