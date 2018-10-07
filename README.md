# hysds-k8s
Hybrid Cloud Science Data System deployment on Kubernetes

## Requirements
- Kubernetes cluster
- `kubectl`

## Deploy HySDS cluster
```
./create_hysds_cluster.sh
```

## Tear down HySDS cluster
```
./delete_hysds_cluster.sh
```

## Mozart component services and deployments

- mozart
  - Mozart REST API
  - Figaro
  - Flower
  - Orchestrator
  - Apache httpd
- mozart-redis
  - Redis
- mozart-rabbitmq
  - RabbitMQ Server
  - RabbitMQ Admin
- mozart-elasticsearch
  - Elasticsearch
  - ES Plugins
    - head
    - kopf

## GRQ component services and deployments

- grq
  - GRQ2 REST API
  - Tosca
  - Apache httpd
- grq-redis
  - Redis
- grq-elasticsearch
  - Elasticsearch
  - ES Plugins
    - head
    - kopf
