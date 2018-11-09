## Usage
1. Source your OpenStack rc file:
   ```
   source ~/TG-CDA180009-openrc-v3.sh 
   ```
1. Log into the IU Jetstream OpenStack [dashboard](https://iu.jetstream-cloud.org) and follow the instructions [here](https://iujetstream.atlassian.net/wiki/spaces/JWT/pages/44826638/Setup+for+Horizon+API+User+Instances) to create a network, security group, and upload you SSH key.
1. Export the key pair name, network name and ID, security group and number of instances to create. For example:
   ```
   export key_pair=hysds
   export network_name=hysds_net
   export network_id=fb80d026-f5ed-41bb-8d62-922c6af2899e
   export security_group=hysds_sg
   export count=2
   ```
1. Init terraform plugins:
   ```
   terraform init
   ```
1. Apply:
   ```
   terraform apply -var "project_domain_id=${OS_PROJECT_DOMAIN_ID}" \
     -var "user_domain_name=${OS_USER_DOMAIN_NAME}" \
     -var "user_name=${OS_USERNAME}" -var "password=${OS_PASSWORD}" \
     -var "key_pair=${key_pair}" -var "network_name=${network_name}" \
     -var "network_id=${network_id}" -var "security_group=${security_group}" \
     -var "count=${count}"
   ```
