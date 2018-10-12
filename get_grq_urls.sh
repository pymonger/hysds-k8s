#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)

# echo grq interfaces
GRQ_ELASTICSEARCH_FQDN=$(kubectl get pod -l run=grq-elasticsearch -o jsonpath="{.items[0].spec.nodeName}")
GRQ_ELASTICSEARCH_IP=$(kubectl get pod -l run=grq-elasticsearch -o jsonpath="{.items[0].status.hostIP}")
GRQ_ELASTICSEARCH_PORT=$(kubectl get service grq-elasticsearch -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
GRQ_FQDN=$(kubectl get pod -l run=grq -o jsonpath="{.items[0].spec.nodeName}")
GRQ_IP=$(kubectl get pod -l run=grq -o jsonpath="{.items[0].status.hostIP}")
GRQ_PORT=$(kubectl get service grq -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
GRQ_REST_PORT=$(kubectl get service grq -o jsonpath='{.spec.ports[?(@.name=="grq2")].nodePort}')
GRQ_SSH_PORT=$(kubectl get service grq -o jsonpath='{.spec.ports[?(@.name=="ssh")].nodePort}')
echo "The grq interfaces will be accessible by one the urls below depending on how your Kubernetes cluster is setup:"
echo "Tosca:           https://${GRQ_FQDN}:${GRQ_PORT}/search"
echo "                 https://${GRQ_IP}:${GRQ_PORT}/search"
echo "                 https://localhost:${GRQ_PORT}/search"
echo "GRQ REST API:    http://${GRQ_FQDN}:${GRQ_REST_PORT}/api/v0.1/"
echo "                 http://${GRQ_IP}:${GRQ_REST_PORT}/api/v0.1/"
echo "                 http://localhost:${GRQ_REST_PORT}/api/v0.1/"
echo "GRQ ES:          http://${GRQ_ELASTICSEARCH_FQDN}:${GRQ_ELASTICSEARCH_PORT}/_plugin/head"
echo "                 http://${GRQ_ELASTICSEARCH_IP}:${GRQ_ELASTICSEARCH_PORT}/_plugin/head"
echo "                 http://localhost:${GRQ_ELASTICSEARCH_PORT}/_plugin/head"
echo ""
echo "To ssh into grq:"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${GRQ_SSH_PORT} ops@${GRQ_FQDN}"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${GRQ_SSH_PORT} ops@${GRQ_IP}"
echo "                 ssh -i ${BASE_PATH}/secrets/id_rsa -p ${GRQ_SSH_PORT} ops@localhost"
