# Mozart

## Redis
1. Create ConfigMap for redis:
   ```
   kubectl create configmap mozart-redis-config --from-file=redis-config
   ```
1. Examine the ConfigMap:
   ```
   kubectl get configmap mozart-redis-config -o yaml
   apiVersion: v1
   data:
     redis-config: |
       maxmemory 2mb
       maxmemory-policy allkeys-lru
   kind: ConfigMap
   metadata:
     creationTimestamp: 2018-10-06T19:06:24Z
     name: mozart-redis-config
     namespace: default
     resourceVersion: "10211"
     selfLink: /api/v1/namespaces/default/configmaps/mozart-redis-config
     uid: eb8c9bd5-c99a-11e8-af6e-fa163e051185
   ```
1. Create the pod:
   ```
   kubectl create -f redis-pod.yaml
   ```
1. Verify pod is running:
   ```
   kubectl get pods
   NAME           READY   STATUS    RESTARTS   AGE
   mozart-redis   1/1     Running   0          44s
   ```
   Describe pods:
   ```
   kubectl describe pods
   Name:               mozart-redis
   Namespace:          default
   Priority:           0
   PriorityClassName:  <none>
   Node:               js-170-15.jetstream-cloud.org/172.28.26.10
   Start Time:         Sat, 06 Oct 2018 15:22:21 -0400
   Labels:             <none>
   Annotations:        <none>
   Status:             Running
   IP:                 10.42.0.1
   Containers:
     mozart-redis:
       Container ID:   docker://5af2f75baf6dbdeaa2b51d1efed0bee241ec8a033365536052dde33f71fffd48
       Image:          kubernetes/redis:v1
       Image ID:       docker-pullable://kubernetes/redis@sha256:8da3f7cbe05e3446215a6931f1c125c38bde03383145fcc3292319bab5b1a6cf
       Port:           6379/TCP
       Host Port:      0/TCP
       State:          Running
         Started:      Sat, 06 Oct 2018 15:22:42 -0400
       Ready:          True
       Restart Count:  0
       Limits:
         cpu:  100m
       Requests:
         cpu:  100m
       Environment:
         MASTER:  true
       Mounts:
         /redis-master from config (rw)
         /redis-master-data from data (rw)
         /var/run/secrets/kubernetes.io/serviceaccount from default-token-jc59x (ro)
   Conditions:
     Type              Status
     Initialized       True 
     Ready             True 
     ContainersReady   True 
     PodScheduled      True 
   Volumes:
     data:
       Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
       Medium:  
     config:
       Type:      ConfigMap (a volume populated by a ConfigMap)
       Name:      mozart-redis-config
       Optional:  false
     default-token-jc59x:
       Type:        Secret (a volume populated by a Secret)
       SecretName:  default-token-jc59x
       Optional:    false
   QoS Class:       Burstable
   Node-Selectors:  <none>
   Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                    node.kubernetes.io/unreachable:NoExecute for 300s
   Events:
     Type    Reason     Age   From                                    Message
     ----    ------     ----  ----                                    -------
     Normal  Scheduled  72s   default-scheduler                       Successfully assigned default/mozart-redis to js-170-15.jetstream-cloud.org
     Normal  Pulling    70s   kubelet, js-170-15.jetstream-cloud.org  pulling image "kubernetes/redis:v1"
     Normal  Pulled     52s   kubelet, js-170-15.jetstream-cloud.org  Successfully pulled image "kubernetes/redis:v1"
     Normal  Created    51s   kubelet, js-170-15.jetstream-cloud.org  Created container
     Normal  Started    51s   kubelet, js-170-15.jetstream-cloud.org  Started container
   ```
1. Use kubectl exec to enter the pod and run the redis-cli tool to verify that the configuration was correctly applied:
   ```
   kubectl exec -it mozart-redis redis-cli
   127.0.0.1:6379> CONFIG GET maxmemory
   1) "maxmemory"
   2) "2097152"
   127.0.0.1:6379> CONFIG GET maxmemory-policy
   1) "maxmemory-policy"
   2) "allkeys-lru"
   127.0.0.1:6379> quit
   ```

## Elasticsearch
1. Create the pod:
   ```
   kubectl create -f es-pod.yaml
   ```
1. Verify pod is running:
   ```
   kubectl get pod mozart-es
   NAME        READY   STATUS    RESTARTS   AGE
   mozart-es   1/1     Running   0          2m50s
   ```
   Describe pods:
   ```
   kubectl describe pod mozart-es
   Name:               mozart-es
   Namespace:          default
   Priority:           0
   PriorityClassName:  <none>
   Node:               js-156-120.jetstream-cloud.org/172.28.26.9
   Start Time:         Sat, 06 Oct 2018 16:08:46 -0400
   Labels:             <none>
   Annotations:        <none>
   Status:             Running
   IP:                 10.44.0.1
   Containers:
     mozart-es:
       Container ID:  docker://7a5dd217d8acc22002877a4e9a5ee59495dadd7bcf5a68edf87a86a06fd3bba0
       Image:         hysds/elasticsearch:1.7
       Image ID:      docker-pullable://hysds/elasticsearch@sha256:5173fd6d7356e2f8f619860d41d3d9b8c0e66de40dfab38dbc95d7f919072898
       Ports:         9200/TCP, 9300/TCP
       Host Ports:    0/TCP, 0/TCP
       Command:
         elasticsearch
       Args:
         -Des.node.name='mozart-elasticsearch'
         -Des.cluster.name='resource_cluster'
         -Des.bootstrap.mlockall=true
         -Des.network.host=0
       State:          Running
         Started:      Sat, 06 Oct 2018 16:09:09 -0400
       Ready:          True
       Restart Count:  0
       Limits:
         cpu:  100m
       Requests:
         cpu:  100m
       Environment:
         ES_HEAP_SIZE:       100m
         MAX_LOCKED_MEMORY:  unlimited
       Mounts:
         /usr/share/elasticsearch/config from config (rw)
         /usr/share/elasticsearch/data from data (rw)
         /var/run/secrets/kubernetes.io/serviceaccount from default-token-jc59x (ro)
   Conditions:
     Type              Status
     Initialized       True 
     Ready             True 
     ContainersReady   True 
     PodScheduled      True 
   Volumes:
     data:
       Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
       Medium:  
     config:
       Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
       Medium:  
     default-token-jc59x:
       Type:        Secret (a volume populated by a Secret)
       SecretName:  default-token-jc59x
       Optional:    false
   QoS Class:       Burstable
   Node-Selectors:  <none>
   Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                    node.kubernetes.io/unreachable:NoExecute for 300s
   Events:
     Type    Reason     Age    From                                     Message
     ----    ------     ----   ----                                     -------
     Normal  Scheduled  3m25s  default-scheduler                        Successfully assigned default/mozart-es to js-156-120.jetstream-cloud.org
     Normal  Pulling    3m23s  kubelet, js-156-120.jetstream-cloud.org  pulling image "hysds/elasticsearch:1.7"
     Normal  Pulled     3m3s   kubelet, js-156-120.jetstream-cloud.org  Successfully pulled image "hysds/elasticsearch:1.7"
     Normal  Created    3m2s   kubelet, js-156-120.jetstream-cloud.org  Created container
     Normal  Started    3m2s   kubelet, js-156-120.jetstream-cloud.org  Started container
   ```
1. Use kubectl exec to enter the pod and run curl to verify that the configuration was correctly applied:
   ```
   kubectl exec -it mozart-es bash
   root@mozart-es:/usr/share/elasticsearch# curl localhost:9200
   {
     "status" : 200,
     "name" : "mozart-elasticsearch",
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
   root@mozart-es:/usr/share/elasticsearch# curl -XPUT 'http://localhost:9200/twitter/tweet/1' -d '{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }'
   
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"created":true}
   root@mozart-es:/usr/share/elasticsearch# curl http://localhost:9200/twitter/tweet/1
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"found":true,"_source":{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }}
   ```
