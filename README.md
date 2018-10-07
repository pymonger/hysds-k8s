# hysds-k8s

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

### Create/start
```
./create_mozart.sh
./get_mozart_urls.sh
```

### Delete/stop
```
./delete_mozart.sh
```
