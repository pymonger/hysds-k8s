#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# list urls
${BASE_PATH}/get_mozart_urls.sh
${BASE_PATH}/get_metrics_urls.sh
${BASE_PATH}/get_grq_urls.sh
${BASE_PATH}/get_ci_urls.sh
${BASE_PATH}/get_minio_urls.sh
