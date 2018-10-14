#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# open mozart urls
MOZART_ELASTICSEARCH_PORT=$(kubectl get service mozart-elasticsearch -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
MOZART_RABBITMQ_PORT=$(kubectl get service mozart-rabbitmq -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
MOZART_PORT=$(kubectl get service mozart -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
MOZART_FLOWER_PORT=$(kubectl get service mozart -o jsonpath='{.spec.ports[?(@.name=="flower")].nodePort}')
python -m webbrowser -n https://localhost:${MOZART_PORT}/figaro; sleep 3
python -m webbrowser -t https://localhost:${MOZART_PORT}/mozart/api/v0.1/
python -m webbrowser -t http://localhost:${MOZART_ELASTICSEARCH_PORT}/_plugin/head
python -m webbrowser -t http://localhost:${MOZART_FLOWER_PORT}
python -m webbrowser -t http://localhost:${MOZART_RABBITMQ_PORT}

# open metrics urls
METRICS_PORT=$(kubectl get service metrics -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
python -m webbrowser -t https://localhost:${METRICS_PORT}/metrics

# open grq urls
GRQ_ELASTICSEARCH_PORT=$(kubectl get service grq-elasticsearch -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
GRQ_PORT=$(kubectl get service grq -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
GRQ_REST_PORT=$(kubectl get service grq -o jsonpath='{.spec.ports[?(@.name=="grq2")].nodePort}')
python -m webbrowser -t https://localhost:${GRQ_PORT}/search
python -m webbrowser -t http://localhost:${GRQ_REST_PORT}/api/v0.1/
python -m webbrowser -t http://localhost:${GRQ_ELASTICSEARCH_PORT}/_plugin/head

# open ci urls
CI_JENKINS_PORT=$(kubectl get service ci -o jsonpath='{.spec.ports[?(@.name=="jenkins")].nodePort}')
python -m webbrowser -t http://localhost:${CI_JENKINS_PORT}
