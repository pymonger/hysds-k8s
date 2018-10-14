#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# echo ci interfaces
CI_FQDN=$(kubectl get pod -l run=ci -o jsonpath="{.items[0].spec.nodeName}")
CI_IP=$(kubectl get pod -l run=ci -o jsonpath="{.items[0].status.hostIP}")
CI_PORT=$(kubectl get service ci -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
CI_JENKINS_PORT=$(kubectl get service ci -o jsonpath='{.spec.ports[?(@.name=="jenkins")].nodePort}')
CI_SSH_PORT=$(kubectl get service ci -o jsonpath='{.spec.ports[?(@.name=="ssh")].nodePort}')
echo "The ci interfaces will be accessible by one the urls below depending on how your Kubernetes cluster is setup:"
echo "HTTPS:           https://${CI_FQDN}:${CI_PORT}"
echo "                 https://${CI_IP}:${CI_PORT}"
echo "                 https://localhost:${CI_PORT}"
echo "Jenkins:         http://${CI_FQDN}:${CI_JENKINS_PORT}"
echo "                 http://${CI_IP}:${CI_JENKINS_PORT}"
echo "                 http://localhost:${CI_JENKINS_PORT}"
echo ""
echo "To ssh into metrics:"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${CI_SSH_PORT} ops@${CI_FQDN}"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${CI_SSH_PORT} ops@${CI_IP}"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${CI_SSH_PORT} ops@localhost"
