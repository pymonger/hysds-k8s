#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# echo mozart interfaces
MOZART_ELASTICSEARCH_FQDN=$(kubectl get pod -l run=mozart-elasticsearch -o jsonpath="{.items[0].spec.nodeName}")
MOZART_ELASTICSEARCH_IP=$(kubectl get pod -l run=mozart-elasticsearch -o jsonpath="{.items[0].status.hostIP}")
MOZART_ELASTICSEARCH_PORT=$(kubectl get service mozart-elasticsearch -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
MOZART_RABBITMQ_FQDN=$(kubectl get pod -l run=mozart-rabbitmq -o jsonpath="{.items[0].spec.nodeName}")
MOZART_RABBITMQ_IP=$(kubectl get pod -l run=mozart-rabbitmq -o jsonpath="{.items[0].status.hostIP}")
MOZART_RABBITMQ_PORT=$(kubectl get service mozart-rabbitmq -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
MOZART_FQDN=$(kubectl get pod -l run=mozart -o jsonpath="{.items[0].spec.nodeName}")
MOZART_IP=$(kubectl get pod -l run=mozart -o jsonpath="{.items[0].status.hostIP}")
MOZART_PORT=$(kubectl get service mozart -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
MOZART_FLOWER_PORT=$(kubectl get service mozart -o jsonpath='{.spec.ports[?(@.name=="flower")].nodePort}')
MOZART_SSH_PORT=$(kubectl get service mozart -o jsonpath='{.spec.ports[?(@.name=="ssh")].nodePort}')
echo "The mozart interfaces will be accessible by one the urls below depending on how your Kubernetes cluster is setup:"
echo "Figaro:          https://${MOZART_FQDN}:${MOZART_PORT}/figaro"
echo "                 https://${MOZART_IP}:${MOZART_PORT}/figaro"
echo "                 https://localhost:${MOZART_PORT}/figaro"
echo "Mozart REST API: https://${MOZART_FQDN}:${MOZART_PORT}/mozart/api/v0.1/"
echo "                 https://${MOZART_IP}:${MOZART_PORT}/mozart/api/v0.1/"
echo "                 https://localhost:${MOZART_PORT}/mozart/api/v0.1/"
echo "Mozart ES:       http://${MOZART_ELASTICSEARCH_FQDN}:${MOZART_ELASTICSEARCH_PORT}/_plugin/head"
echo "                 http://${MOZART_ELASTICSEARCH_IP}:${MOZART_ELASTICSEARCH_PORT}/_plugin/head"
echo "                 http://localhost:${MOZART_ELASTICSEARCH_PORT}/_plugin/head"
echo "Flower:          http://${MOZART_FQDN}:${MOZART_FLOWER_PORT}"
echo "                 http://${MOZART_IP}:${MOZART_FLOWER_PORT}"
echo "                 http://localhost:${MOZART_FLOWER_PORT}"
echo "RabbitMQ Admin:  http://${MOZART_RABBITMQ_FQDN}:${MOZART_RABBITMQ_PORT}"
echo "                 http://${MOZART_RABBITMQ_IP}:${MOZART_RABBITMQ_PORT}"
echo "                 http://localhost:${MOZART_RABBITMQ_PORT}"
echo ""
echo "To ssh into mozart:"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${MOZART_SSH_PORT} ops@${MOZART_FQDN}"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${MOZART_SSH_PORT} ops@${MOZART_IP}"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${MOZART_SSH_PORT} ops@localhost"
