#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# get access secret keys
if [ "$#" -ne 2 ]; then
  echo "Enter access and secret keys as args: $0 <access key> <secret key>"
  echo "e.g.: $0 12345 54321"
  exit 1
fi
ACCESS_KEY=$1
SECRET_KEY=$2


cat ${BASE_PATH}/config/aws_credentials.tmpl | \
  sed "s#__ACCESS_KEY__#${ACCESS_KEY}#" | \
  sed "s#__SECRET_KEY__#${SECRET_KEY}#" > \
  ${BASE_PATH}/config/aws_credentials


# deploy minio services
#${BASE_PATH}/create_minio.sh

# deploy mozart services
${BASE_PATH}/create_mozart.sh

# deploy metrics services
${BASE_PATH}/create_metrics.sh

# deploy grq services
${BASE_PATH}/create_grq.sh

# deploy factotum services
${BASE_PATH}/create_factotum.sh

# deploy ci services
${BASE_PATH}/create_ci.sh
