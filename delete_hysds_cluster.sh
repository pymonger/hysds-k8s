#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# delete mozart services
${BASE_PATH}/delete_mozart.sh

# delete metrics services
${BASE_PATH}/delete_metrics.sh

# delete grq services
${BASE_PATH}/delete_grq.sh
