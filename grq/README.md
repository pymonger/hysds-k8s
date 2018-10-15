# GRQ

## Create ConfigMaps
1. If not yet done, create ConfigMap for global HysDS configuration:
   ```
   $ kubectl create configmap hysds-global-config --from-file=../config
   ```
1. Examine the ConfigMap:
   ```
   $ kubectl get configmap hysds-global-config -o yaml
   ``` 
1. Create ConfigMap for all grq services:
   ```
   $ kubectl create configmap hysds-grq-config --from-file=config
   ```
1. Examine the ConfigMap:
   ```
   $ kubectl get configmap hysds-grq-config -o yaml
   ```

## Redis
1. Create the `grq-redis` service:
   ```
   $ kubectl create -f grq-redis.yaml
   service/grq-redis created
   deployment.apps/grq-redis created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=grq-redis
   NAME                         READY   STATUS    RESTARTS   AGE
   grq-redis-7b458bf58d-js4cg   1/1     Running   0          97s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=grq-redis
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy grq-redis
   NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   grq-redis   1         1         1            1           4m43s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy grq-redis
   ```
1. Verify service is running:
   ```
   $ kubectl get service grq-redis
   NAME        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
   grq-redis   ClusterIP   10.111.142.173   <none>        6379/TCP   2m16s
   ```
   Describe service:
   ```
   $ kubectl describe service grq-redis
   Name:              grq-redis
   Namespace:         default
   Labels:            component=grq
                      run=grq-redis
   Annotations:       <none>
   Selector:          component=grq,run=grq-redis
   Type:              ClusterIP
   IP:                10.111.142.173
   Port:              <unset>  6379/TCP
   TargetPort:        6379/TCP
   Endpoints:         10.38.0.1:6379
   Session Affinity:  None
   Events:            <none>
   ```
1. Use kubectl exec to enter the pod and run the redis-cli tool to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=grq-redis -o jsonpath="{.items[0].metadata.name}") redis-cli
   127.0.0.1:6379> CONFIG GET dir
   1) "dir"
   2) "/data/redis"
   127.0.0.1:6379> quit
   ```
1. Use a test pod to verify that service is reachable from any pod in the cluster:
   ```
   $ kubectl run -i -t test-verdi --image=hysds/verdi:latest bash
   kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
   If you don't see a command prompt, try pressing enter.
   ops@test-verdi-79cc7bb54d-p7wgm:~$ nslookup grq-redis
   Server:         10.96.0.10
   Address:        10.96.0.10#53
   
   Name:   grq-redis.default.svc.cluster.local
   Address: 10.107.221.228

   ops@test-verdi-79cc7bb54d-p7wgm:~$ sudo yum install -y redis
   ops@test-verdi-79cc7bb54d-p7wgm:~$ redis-cli -h grq-redis
   grq-redis:6379> CONFIG GET dir
   1) "dir"
   2) "/data/redis"
   grq-redis:6379> set test_key 12345
   OK
   grq-redis:6379> quit
   ops@test-verdi-79cc7bb54d-p7wgm:~$ exit
   exit
   Session ended, resume using 'kubectl attach test-verdi-79cc7bb54d-p7wgm -c test-verdi -i -t' command when the pod is running
   ```
   Delete test pod:
   ```
   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```

## Elasticsearch
1. Create the `grq-elasticsearch` service:
   ```
   $ kubectl create -f grq-elasticsearch.yaml
   service/grq-elasticsearch created
   deployment.apps/grq-elasticsearch created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=grq-elasticsearch
   NAME                                 READY   STATUS    RESTARTS   AGE
   grq-elasticsearch-79d46b7ffd-lqhph   1/1     Running   0          23s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=grq-elasticsearch
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy grq-elasticsearch
   NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   grq-elasticsearch   1         1         1            1           86s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy grq-elasticsearch
   ```
1. Verify service is running:
   ```
   $ kubectl get service grq-elasticsearch
   NAME                TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
   grq-elasticsearch   NodePort   10.104.237.244   <none>        9200:30239/TCP,9300:32714/TCP   63s
   ```
   Describe service:
   ```
   $ kubectl describe service grq-elasticsearch
   Name:                     grq-elasticsearch
   Namespace:                default
   Labels:                   component=grq
                             run=grq-elasticsearch
   Annotations:              <none>
   Selector:                 component=grq,run=grq-elasticsearch
   Type:                     NodePort
   IP:                       10.104.237.244
   Port:                     http  9200/TCP
   TargetPort:               9200/TCP
   NodePort:                 http  30239/TCP
   Endpoints:                10.32.0.2:9200
   Port:                     tcp  9300/TCP
   TargetPort:               9300/TCP
   NodePort:                 tcp  32714/TCP
   Endpoints:                10.32.0.2:9300
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:                   <none>
   ```
1. Use kubectl exec to enter the pod and run curl to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=grq-elasticsearch -o jsonpath="{.items[0].metadata.name}") bash
   root@grq-elasticsearch-79d46b7ffd-lqhph:/usr/share/elasticsearch# curl localhost:9200
   {
     "status" : 200,
     "name" : "grq-elasticsearch",
     "cluster_name" : "products_cluster",
     "version" : {
       "number" : "1.7.6",
       "build_hash" : "c730b59357f8ebc555286794dcd90b3411f517c9",
       "build_timestamp" : "2016-11-18T15:21:16Z",
       "build_snapshot" : false,
       "lucene_version" : "4.10.4"
     },
     "tagline" : "You Know, for Search"
   }
   root@grq-elasticsearch-79d46b7ffd-lqhph:/usr/share/elasticsearch# curl -XPUT 'http://localhost:9200/twitter/tweet/1' -d '{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }'
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"created":true}
   root@grq-elasticsearch-79d46b7ffd-lqhph:/usr/share/elasticsearch# curl http://localhost:9200/twitter/tweet/1
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"found":true,"_source":{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }}
   root@grq-elasticsearch-79d46b7ffd-lqhph:/usr/share/elasticsearch# exit
   ```
1. Use a test pod to verify that service is reachable from any pod in the cluster:
   ```
   $ kubectl run -i -t test-verdi --image=hysds/verdi:latest bash
   kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
   If you don't see a command prompt, try pressing enter.
   ops@test-verdi-79cc7bb54d-h2hrx:~$ curl grq-elasticsearch:9200/twitter/tweet/1
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"found":true,"_source":{
          "user" : "kimchy",
          "post_date" : "2009-11-15T14:12:12",
          "message" : "trying out Elasticsearch"
      }}ops@test-verdi-79cc7bb54d-h2hrx:~$ exit
   exit
   Session ended, resume using 'kubectl attach test-verdi-79cc7bb54d-h2hrx -c test-verdi -i -t' command when the pod is running
   ```
   Delete test pod:
   ```
   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```
1. Verify that service is reachable from an instance outside of the cluster:
   lq`
   $ GRQ_ELASTICSEARCH_IP=$(kubectl get pod -l run=grq-elasticsearch -o jsonpath="{.items[0].status.hostIP}")
   $ GRQ_ELASTICSEARCH_PORT=$(kubectl get service grq-elasticsearch -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
   $ echo "curl ${GRQ_ELASTICSEARCH_IP}:${GRQ_ELASTICSEARCH_PORT}/twitter/tweet/1"
   ```
   On an instance outside of the cluster, copy the output from the `echo` command above and execute. Output should match that of the previous step.

## GRQ
1. Create the `grq` service:
   ```
   $ kubectl create -f grq.yaml
   service/grq created
   deployment.apps/grq created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=grq
   NAME                   READY   STATUS              RESTARTS   AGE
   grq-586b57f56c-26h88   0/1     ContainerCreating   0          10s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=grq
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy grq
   NAME   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   grq    1         1         1            1           96s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy grq
   ```
1. Verify service is running:
   ```
   $ kubectl get service grq
   NAME   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                   AGE
   grq    NodePort   10.105.135.187   <none>        80:32644/TCP,443:30222/TCP,8878:31722/TCP,8879:31668/TCP,9001:30981/TCP   2m13s
   ```
   Describe service:
   ```
   $ kubectl describe service grq
   Name:                     grq
   Namespace:                default
   Labels:                   component=grq
                             run=grq
   Annotations:              <none>
   Selector:                 component=grq,run=grq
   Type:                     NodePort
   IP:                       10.105.135.187
   Port:                     http  80/TCP
   TargetPort:               80/TCP
   NodePort:                 http  32644/TCP
   Endpoints:                10.38.0.0:80
   Port:                     https  443/TCP
   TargetPort:               443/TCP
   NodePort:                 https  30222/TCP
   Endpoints:                10.38.0.0:443
   Port:                     grq2  8878/TCP
   TargetPort:               8878/TCP
   NodePort:                 grq2  31722/TCP
   Endpoints:                10.38.0.0:8878
   Port:                     tosca  8879/TCP
   TargetPort:               8879/TCP
   NodePort:                 tosca  31668/TCP
   Endpoints:                10.38.0.0:8879
   Port:                     supervisord  9001/TCP
   TargetPort:               9001/TCP
   NodePort:                 supervisord  30981/TCP
   Endpoints:                10.38.0.0:9001
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:                   <none>
   ```
1. Use kubectl exec to enter the pod and run curl to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=grq -o jsonpath="{.items[0].metadata.name}") bash
   ops@grq-59d74fd96f-f7rtm:~$ curl -k https://localhost/grq/api/v0.1/swagger.json
   ```
1. Use a test pod to verify that service is reachable from any pod in the cluster:
   ```
   $ kubectl run -i -t test-verdi --image=hysds/verdi:latest bash
   kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
   If you don't see a command prompt, try pressing enter.
   ops@test-verdi-79cc7bb54d-6d6j7:~$ nslookup grq
   Server:         10.96.0.10
   Address:        10.96.0.10#53
   
   Name:   grq.default.svc.cluster.local
   Address: 10.102.133.142
   
   ops@test-verdi-79cc7bb54d-6d6j7:~$ curl -k https://grq/grq/api/v0.1/swagger.json 
   exit
   Session ended, resume using 'kubectl attach test-verdi-79cc7bb54d-wnbf2 -c test-verdi -i -t' command when the pod is running
   ```
   Delete test pod:
   ```
   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```
1. Verify that service is reachable from an instance outside of the cluster:
   ```
   $ GRQ_IP=$(kubectl get pod -l run=grq -o jsonpath="{.items[0].status.hostIP}")
   $ GRQ_PORT=$(kubectl get service grq -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
   $ echo "curl -k https://${GRQ_IP}:${GRQ_PORT}/grq/api/v0.1/swagger.json"
   ```
   On an instance outside of the cluster, copy the output from the `echo` command above and execute. Output should match that of the previous step.
