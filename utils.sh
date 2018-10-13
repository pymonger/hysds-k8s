#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)


# create global secrets
create_global_secrets() {
  kubectl get secret hysds-global-secrets 2>/dev/null
  if [ $? -ne 0 ]; then
    mkdir -p ${BASE_PATH}/secrets
    ssh-keygen -f ${BASE_PATH}/secrets/id_rsa -t rsa -N ''
    kubectl create secret generic hysds-global-secrets --from-file=${BASE_PATH}/secrets
  fi
}


# delete global secrets
delete_global_secrets() {
  kubectl get secret hysds-global-secrets 2>/dev/null
  if [ $? -eq 0 ]; then
    kubectl delete secret hysds-global-secrets
  fi
  rm -rf ${BASE_PATH}/secrets
}


# create global configmap
create_global_config() {
  kubectl get configmap hysds-global-config 2>/dev/null
  if [ $? -ne 0 ]; then
    kubectl create configmap hysds-global-config --from-file=${BASE_PATH}/config
  fi
}


# delete global configmap
delete_global_config() {
  kubectl get configmap hysds-global-config 2>/dev/null
  if [ $? -eq 0 ]; then
    kubectl delete configmap hysds-global-config
  fi       
}


# create component configmap
create_comp_config() {
  comp=$1
  kubectl get configmap hysds-${comp}-config 2>/dev/null
  if [ $? -ne 0 ]; then
    kubectl create configmap hysds-${comp}-config --from-file=${BASE_PATH}/${comp}/config
  fi
}


# delete component configmap
delete_comp_config() {
  comp=$1
  kubectl get configmap hysds-${comp}-config 2>/dev/null
  if [ $? -eq 0 ]; then
    kubectl delete configmap hysds-${comp}-config
  fi
}
