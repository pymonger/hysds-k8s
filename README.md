# hysds-k8s
Hybrid Cloud Science Data System deployment on Kubernetes

## Requirements
- Kubernetes cluster
- `kubectl`

## Deploy HySDS cluster
```
./create_hysds_cluster.sh
```
Wait until all pods are running:
```
kubectl get po --all-namespaces -w
```
Open up browser interfaces:
```
./open_urls_localhost.sh
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
