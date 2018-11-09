## Usage
1. Source your OpenStack rc file:
   ```
   source ~/TG-CDA180009-openrc-v3.sh 
   ```
1. Log into the IU Jetstream OpenStack [dashboard](https://iu.jetstream-cloud.org) and follow the instructions [here](https://iujetstream.atlassian.net/wiki/spaces/JWT/pages/44826638/Setup+for+Horizon+API+User+Instances) to create a network, security group, and upload you SSH key.
1. Init terraform plugins:
   ```
   terraform init
   ```
1. Apply:
   ```
   terraform apply -var "project_domain_id=${OS_PROJECT_DOMAIN_ID}" \
     -var "user_domain_name=${OS_USER_DOMAIN_NAME}" \
     -var "user_name=${OS_USERNAME}" -var "password=${OS_PASSWORD}" \
     -var "key_pair=hysds" -var "network_name=hysds_net" \
     -var "network_id=fb80d026-f5ed-41bb-8d62-922c6af2899e" \
     -var "security_group=hysds_sg" -var "count=2"
   ```
