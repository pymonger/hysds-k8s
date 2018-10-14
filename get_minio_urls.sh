#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# echo minio interfaces
MINIO_FQDN=$(kubectl get pod -l run=object-store -o jsonpath="{.items[0].spec.nodeName}")
MINIO_IP=$(kubectl get pod -l run=object-store -o jsonpath="{.items[0].status.hostIP}")
MINIO_PORT=$(kubectl get service minio-service -o jsonpath='{.spec.ports[?(@.name=="minio")].nodePort}')
echo "The minio interfaces will be accessible by one the urls below depending on how your Kubernetes cluster is setup:"
echo "Minio:           http://${MINIO_FQDN}:${MINIO_PORT}"
echo "                 http://${MINIO_IP}:${MINIO_PORT}"
echo "                 http://localhost:${MINIO_PORT}"
