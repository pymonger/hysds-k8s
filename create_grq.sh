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

# create grq elasticsearch pv and pvc
mkdir -p ${BASE_PATH}/grq/data
cat ${BASE_PATH}/grq/grq-elasticsearch-pv_singlenode.yaml.tmpl | \
  sed "s#__HOSTPATH__#${BASE_PATH}/grq/data/elasticsearch#" > \
  ${BASE_PATH}/grq/grq-elasticsearch-pv.yaml
create_pv grq-elasticsearch-pv \
  ${BASE_PATH}/grq/grq-elasticsearch-pv.yaml \
  ${BASE_PATH}/grq/grq-elasticsearch-pvc.yaml
rm -rf ${BASE_PATH}/grq/grq-elasticsearch-pv.yaml

# deploy grq services
kubectl create -f ${BASE_PATH}/grq/grq-redis.yaml \
               -f ${BASE_PATH}/grq/grq-elasticsearch.yaml \
               -f ${BASE_PATH}/grq/grq.yaml
