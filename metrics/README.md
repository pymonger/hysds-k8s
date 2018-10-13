# Metrics

## Create ConfigMaps
1. If not yet done, create ConfigMap for global HysDS configuration:
   ```
   $ kubectl create configmap hysds-global-config --from-file=../config
   ```
1. Examine the ConfigMap:
   ```
   $ kubectl get configmap hysds-global-config -o yaml
   ``` 
1. Create ConfigMap for all metrics services:
   ```
   $ kubectl create configmap hysds-metrics-config --from-file=config
   ```
1. Examine the ConfigMap:
   ```
   $ kubectl get configmap hysds-metrics-config -o yaml
   ```

## Redis
1. Create the `metrics-redis` service:
   ```
   $ kubectl create -f metrics-redis.yaml
   service/metrics-redis created
   deployment.apps/metrics-redis created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=metrics-redis
   NAME                            READY   STATUS    RESTARTS   AGE
   metrics-redis-5b785957b6-8bnbb   1/1     Running   0          2m16s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=metrics-redis
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy metrics-redis
   NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   metrics-redis   1         1         1            1           4m43s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy metrics-redis
   ```
1. Verify service is running:
   ```
   $ kubectl get service metrics-redis
   NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
   metrics-redis   ClusterIP   10.108.202.234   <none>        6379/TCP   6m20s
   ```
   Describe service:
   ```
   $ kubectl describe service metrics-redis
   Name:              metrics-redis
   Namespace:         default
   Labels:            component=metrics
                      run=metrics-redis
   Annotations:       <none>
   Selector:          component=metrics,run=metrics-redis
   Type:              ClusterIP
   IP:                10.100.225.218
   Port:              <unset>  6379/TCP
   TargetPort:        6379/TCP
   Endpoints:         10.42.0.1:6379
   Session Affinity:  None
   Events:            <none>
   ```
1. Use kubectl exec to enter the pod and run the redis-cli tool to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=metrics-redis -o jsonpath="{.items[0].metadata.name}") redis-cli
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
   ops@test-verdi-79cc7bb54d-p7wgm:~$ nslookup metrics-redis
   Server:         10.96.0.10
   Address:        10.96.0.10#53
   
   Name:   metrics-redis.default.svc.cluster.local
   Address: 10.107.221.228

   ops@test-verdi-79cc7bb54d-p7wgm:~$ sudo yum install -y redis
   ops@test-verdi-79cc7bb54d-p7wgm:~$ redis-cli -h metrics-redis
   metrics-redis:6379> CONFIG GET dir
   1) "dir"
   2) "/data/redis"
   metrics-redis:6379> set test_key 12345
   OK
   metrics-redis:6379> quit
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
1. Create the `metrics-elasticsearch` service:
   ```
   $ kubectl create -f metrics-elasticsearch.yaml
   service/metrics-elasticsearch created
   deployment.apps/metrics-elasticsearch created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=metrics-elasticsearch
   NAME                                    READY   STATUS    RESTARTS   AGE
   metrics-elasticsearch-7f4f8fd8f9-zj4g6   1/1     Running   0          13s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=metrics-elasticsearch
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy metrics-elasticsearch
   NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   metrics-elasticsearch   1         1         1            1           86s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy metrics-elasticsearch
   ```
1. Verify service is running:
   ```
   $ kubectl get service metrics-elasticsearch
   NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
   metrics-elasticsearch   NodePort   10.100.88.102   <none>        9200:32440/TCP,9300:31251/TCP   2m32s
   ```
   Describe service:
   ```
   $ kubectl describe service metrics-elasticsearch
   Name:                     metrics-elasticsearch
   Namespace:                default
   Labels:                   component=metrics
                             run=metrics-elasticsearch
   Annotations:              <none>
   Selector:                 component=metrics,run=metrics-elasticsearch
   Type:                     NodePort
   IP:                       10.111.172.47
   Port:                     http  9200/TCP
   TargetPort:               9200/TCP
   NodePort:                 http  30299/TCP
   Endpoints:                10.44.0.1:9200
   Port:                     tcp  9300/TCP
   TargetPort:               9300/TCP
   NodePort:                 tcp  31264/TCP
   Endpoints:                10.44.0.1:9300
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:                   <none>
   ```
1. Use kubectl exec to enter the pod and run curl to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=metrics-elasticsearch -o jsonpath="{.items[0].metadata.name}") bash
   root@metrics-elasticsearch-7f4f8fd8f9-zj4g6:/usr/share/elasticsearch# curl localhost:9200
   {
     "status" : 200,
     "name" : "metrics-elasticsearch",
     "cluster_name" : "resource_cluster",
     "version" : {
       "number" : "1.7.6",
       "build_hash" : "c730b59357f8ebc555286794dcd90b3411f517c9",
       "build_timestamp" : "2016-11-18T15:21:16Z",
       "build_snapshot" : false,
       "lucene_version" : "4.10.4"
     },
     "tagline" : "You Know, for Search"
   }
   root@metrics-elasticsearch-7f4f8fd8f9-zj4g6:/usr/share/elasticsearch# curl -XPUT 'http://localhost:9200/twitter/tweet/1' -d '{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }'
   
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"created":true}root@metrics-elasticsearch-7f4f8fd8f9-zj4g6:/usr/share/elasticsearch# 
   root@metrics-elasticsearch-7f4f8fd8f9-zj4g6:/usr/share/elasticsearch# curl http://localhost:9200/twitter/tweet/1
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"found":true,"_source":{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }}
   $ exit
   ```
1. Use a test pod to verify that service is reachable from any pod in the cluster:
   ```
   $ kubectl run -i -t test-verdi --image=hysds/verdi:latest bash
   kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
   If you don't see a command prompt, try pressing enter.
   ops@test-verdi-79cc7bb54d-wnbf2:~$ nslookup metrics-elasticsearch
   Server:         10.96.0.10
   Address:        10.96.0.10#53
   
   Name:   metrics-elasticsearch.default.svc.cluster.local
   Address: 10.100.88.102
   
   ops@test-verdi-79cc7bb54d-wnbf2:~$ curl metrics-elasticsearch:9200/twitter/tweet/1
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"found":true,"_source":{
              "user" : "kimchy",
              "post_date" : "2009-11-15T14:12:12",
              "message" : "trying out Elasticsearch"
   }}
   ops@test-verdi-79cc7bb54d-wnbf2:~$ exit
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
   $ MOZART_ELASTICSEARCH_IP=$(kubectl get pod -l run=metrics-elasticsearch -o jsonpath="{.items[0].status.hostIP}")
   $ MOZART_ELASTICSEARCH_PORT=$(kubectl get service metrics-elasticsearch -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
   $ echo "curl ${MOZART_ELASTICSEARCH_IP}:${MOZART_ELASTICSEARCH_PORT}/twitter/tweet/1"
   ```
   On an instance outside of the cluster, copy the output from the `echo` command above and execute. Output should match that of the previous step.
