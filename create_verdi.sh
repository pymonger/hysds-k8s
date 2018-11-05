#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# create global secrets
create_global_secrets

# create global configmap
create_global_config

# create verdi configmap
create_comp_config verdi

# deploy verdi services
kubectl create -f ${BASE_PATH}/verdi/verdi.yaml
