#!/bin/bash
BASE_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
source ${BASE_PATH}/utils.sh


# get access secret keys
if [ "$#" -ne 4 ]; then
  echo "Enter AWS and Swift access and secret keys as args: $0 <aws access key> <aws secret key> <swift access key> <swift secret key>"
  echo "e.g.: $0 12345 54321 asdf fdsa"
  exit 1
fi
AWS_ACCESS_KEY=$1
AWS_SECRET_KEY=$2
SWIFT_ACCESS_KEY=$3
SWIFT_SECRET_KEY=$4


cat ${BASE_PATH}/config/aws_credentials.tmpl | \
  sed "s#__AWS_ACCESS_KEY__#${AWS_ACCESS_KEY}#" | \
  sed "s#__AWS_SECRET_KEY__#${AWS_SECRET_KEY}#" | \
  sed "s#__SWIFT_ACCESS_KEY__#${SWIFT_ACCESS_KEY}#" | \
  sed "s#__SWIFT_SECRET_KEY__#${SWIFT_SECRET_KEY}#" > \
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

# deploy verdi services
${BASE_PATH}/create_verdi.sh
