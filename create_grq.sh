#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# create global secrets
create_global_secrets

# create global configmap
create_global_config

# create grq configmap
create_comp_config grq

# create cinder storage class
create_cinder_sc standard \
  ${BASE_PATH}/globals/cinder_storageclass.yaml

# create grq elasticsearch pvc
create_pvc grq-elasticsearch-pvc \
  ${BASE_PATH}/grq/grq-elasticsearch-pvc.yaml

# give time for persistentvolume creation
sleep 10

# deploy grq services
kubectl create -f ${BASE_PATH}/grq/grq-redis.yaml \
               -f ${BASE_PATH}/grq/grq-elasticsearch.yaml \
               -f ${BASE_PATH}/grq/grq.yaml
