# Mozart

## Redis
1. Create ConfigMap for redis:
   ```
   $ kubectl create configmap mozart-redis-config --from-file=redis-config
   ```
1. Examine the ConfigMap:
   ```
   $ kubectl get configmap mozart-redis-config -o yaml
   apiVersion: v1
   data:
     redis-config: |
       bind 0.0.0.0
       protected-mode no
       port 6379
       tcp-backlog 65535
       unixsocket /tmp/redis.sock
       unixsocketperm 777
       timeout 300
       tcp-keepalive 300
       daemonize no
       supervised no
       pidfile /var/run/redis/redis.pid
       loglevel notice
       logfile /var/log/redis/redis.log
       databases 16
       save 900 1
       save 300 10
       save 60 10000
       stop-writes-on-bgsave-error yes
       rdbcompression yes
       rdbchecksum yes
       dbfilename dump.rdb
       dir /data/redis
       slave-serve-stale-data yes
       slave-read-only yes
       repl-diskless-sync no
       repl-diskless-sync-delay 5
       repl-disable-tcp-nodelay no
       slave-priority 100
       maxclients 65535
       appendonly no
       appendfilename "appendonly.aof"
       appendfsync everysec
       no-appendfsync-on-rewrite no
       auto-aof-rewrite-percentage 100
       auto-aof-rewrite-min-size 64mb
       aof-load-truncated yes
       lua-time-limit 5000
       slowlog-log-slower-than 10000
       slowlog-max-len 128
       latency-monitor-threshold 0
       notify-keyspace-events ""
       hash-max-ziplist-entries 512
       hash-max-ziplist-value 64
       list-max-ziplist-size -2
       list-compress-depth 0
       set-max-intset-entries 512
       zset-max-ziplist-entries 128
       zset-max-ziplist-value 64
       hll-sparse-max-bytes 3000
       activerehashing yes
       client-output-buffer-limit normal 0 0 0
       client-output-buffer-limit slave 256mb 64mb 60
       client-output-buffer-limit pubsub 32mb 8mb 60
       hz 10
       aof-rewrite-incremental-fsync yes
   kind: ConfigMap
   metadata:
     creationTimestamp: 2018-10-06T23:15:43Z
     name: mozart-redis-config
     namespace: default
     resourceVersion: "33134"
     selfLink: /api/v1/namespaces/default/configmaps/mozart-redis-config
     uid: bfa21fad-c9bd-11e8-af6e-fa163e051185
   ```
1. Create the `mozart-redis` service:
   ```
   $ kubectl create -f mozart-redis.yaml
   service/mozart-redis created
   deployment.apps/mozart-redis created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=mozart-redis
   NAME                            READY   STATUS    RESTARTS   AGE
   mozart-redis-5b785957b6-8bnbb   1/1     Running   0          2m16s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=mozart-redis
   Name:               mozart-redis-5b785957b6-8bnbb
   Namespace:          default
   Priority:           0
   PriorityClassName:  <none>
   Node:               js-170-15.jetstream-cloud.org/172.28.26.10
   Start Time:         Sat, 06 Oct 2018 18:23:03 -0400
   Labels:             pod-template-hash=5b785957b6
                       run=mozart-redis
   Annotations:        <none>
   Status:             Running
   IP:                 10.42.0.1
   Controlled By:      ReplicaSet/mozart-redis-5b785957b6
   Containers:
     mozart-redis:
       Container ID:  docker://7d46adaae66ad4438d584b0940c029e3d7801bdce87b904bad8ec9da36a69a1a
       Image:         hysds/redis:latest
       Image ID:      docker-pullable://hysds/redis@sha256:10bb284335c1650712f09d072026aef5861ea55a4eebbd62fb53f1b035239af5
       Port:          6379/TCP
       Host Port:     0/TCP
       Command:
         redis-server
       Args:
         /redis-master/redis.conf
       State:          Running
         Started:      Sat, 06 Oct 2018 18:23:07 -0400
       Ready:          True
       Restart Count:  0
       Limits:
         cpu:  100m
       Requests:
         cpu:  100m
       Environment:
         MASTER:  true
       Mounts:
         /data/redis from data (rw)
         /redis-master from config (rw)
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
     Type    Reason     Age    From                                    Message
     ----    ------     ----   ----                                    -------
     Normal  Scheduled  2m55s  default-scheduler                       Successfully assigned default/mozart-redis-5b785957b6-8bnbb to js-170-15.jetstream-cloud.org
     Normal  Pulling    2m53s  kubelet, js-170-15.jetstream-cloud.org  pulling image "hysds/redis:latest"
     Normal  Pulled     2m52s  kubelet, js-170-15.jetstream-cloud.org  Successfully pulled image "hysds/redis:latest"
     Normal  Created    2m52s  kubelet, js-170-15.jetstream-cloud.org  Created container
     Normal  Started    2m51s  kubelet, js-170-15.jetstream-cloud.org  Started container
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy mozart-redis
   NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   mozart-redis   1         1         1            1           4m43s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy mozart-redis
   Name:                   mozart-redis
   Namespace:              default
   CreationTimestamp:      Sat, 06 Oct 2018 18:23:03 -0400
   Labels:                 <none>
   Annotations:            deployment.kubernetes.io/revision: 1
   Selector:               run=mozart-redis
   Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
   StrategyType:           RollingUpdate
   MinReadySeconds:        0
   RollingUpdateStrategy:  25% max unavailable, 25% max surge
   Pod Template:
     Labels:  run=mozart-redis
     Containers:
      mozart-redis:
       Image:      hysds/redis:latest
       Port:       6379/TCP
       Host Port:  0/TCP
       Command:
         redis-server
       Args:
         /redis-master/redis.conf
       Limits:
         cpu:  100m
       Environment:
         MASTER:  true
       Mounts:
         /data/redis from data (rw)
         /redis-master from config (rw)
     Volumes:
      data:
       Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
       Medium:  
      config:
       Type:      ConfigMap (a volume populated by a ConfigMap)
       Name:      mozart-redis-config
       Optional:  false
   Conditions:
     Type           Status  Reason
     ----           ------  ------
     Available      True    MinimumReplicasAvailable
     Progressing    True    NewReplicaSetAvailable
   OldReplicaSets:  <none>
   NewReplicaSet:   mozart-redis-5b785957b6 (1/1 replicas created)
   Events:
     Type    Reason             Age    From                   Message
     ----    ------             ----   ----                   -------
     Normal  ScalingReplicaSet  5m22s  deployment-controller  Scaled up replica set mozart-redis-5b785957b6 to 1
   ```
1. Verify service is running:
   ```
   $ kubectl get service mozart-redis
   NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
   mozart-redis   ClusterIP   10.108.202.234   <none>        6379/TCP   6m20s
   ```
   Describe service:
   ```
   $ kubectl describe service mozart-redis
   Name:              mozart-redis
   Namespace:         default
   Labels:            run=mozart-redis
   Annotations:       <none>
   Selector:          run=mozart-redis
   Type:              ClusterIP
   IP:                10.108.202.234
   Port:              <unset>  6379/TCP
   TargetPort:        6379/TCP
   Endpoints:         10.42.0.1:6379
   Session Affinity:  None
   Events:            <none>
   ```
1. Use kubectl exec to enter the pod and run the redis-cli tool to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=mozart-redis | grep -v NAME | awk '{print $1}') redis-cli
   127.0.0.1:6379> CONFIG GET dir
   1) "dir"
   2) "/data/redis"
   127.0.0.1:6379> quit
   ```
1. Verify that service is reachable from any pod in the cluster:
   ```
   $ kubectl run -i -t test-verdi --image=hysds/verdi:latest bash
   kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
   If you don't see a command prompt, try pressing enter.
   ops@test-verdi-79cc7bb54d-p7wgm:~$ nslookup mozart-redis
   Server:         10.96.0.10
   Address:        10.96.0.10#53
   
   Name:   mozart-redis.default.svc.cluster.local
   Address: 10.107.221.228

   ops@test-verdi-79cc7bb54d-p7wgm:~$ sudo yum install -y redis
   ops@test-verdi-79cc7bb54d-p7wgm:~$ redis-cli -h mozart-redis
   mozart-redis:6379> CONFIG GET dir
   1) "dir"
   2) "/data/redis"
   mozart-redis:6379> set test_key 12345
   OK
   mozart-redis:6379> quit
   ops@test-verdi-79cc7bb54d-p7wgm:~$ exit
   exit
   Session ended, resume using 'kubectl attach test-verdi-79cc7bb54d-p7wgm -c test-verdi -i -t' command when the pod is running

   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```

## Elasticsearch
1. Create the `mozart-elasticsearch` service:
   ```
   $ kubectl create -f mozart-elasticsearch.yaml
   service/mozart-elasticsearch created
   deployment.apps/mozart-elasticsearch created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=mozart-elasticsearch
   NAME                                    READY   STATUS    RESTARTS   AGE
   mozart-elasticsearch-7f4f8fd8f9-zj4g6   1/1     Running   0          13s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=mozart-elasticsearch
   Name:               mozart-elasticsearch-7f4f8fd8f9-zj4g6
   Namespace:          default
   Priority:           0
   PriorityClassName:  <none>
   Node:               js-156-120.jetstream-cloud.org/172.28.26.9
   Start Time:         Sat, 06 Oct 2018 22:31:28 -0400
   Labels:             pod-template-hash=7f4f8fd8f9
                       run=mozart-elasticsearch
   Annotations:        <none>
   Status:             Running
   IP:                 10.44.0.1
   Controlled By:      ReplicaSet/mozart-elasticsearch-7f4f8fd8f9
   Containers:
     mozart-elasticsearch:
       Container ID:  docker://e95548c627a33878514a2ff6a100ffe0ff489deef1edd9011e77d30c76cd00c1
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
         Started:      Sat, 06 Oct 2018 22:31:31 -0400
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
     Type    Reason     Age   From                                     Message
     ----    ------     ----  ----                                     -------
     Normal  Scheduled  35s   default-scheduler                        Successfully assigned default/mozart-elasticsearch-7f4f8fd8f9-zj4g6 to js-156-120.jetstream-cloud.org
     Normal  Pulled     33s   kubelet, js-156-120.jetstream-cloud.org  Container image "hysds/elasticsearch:1.7" already present on machine
     Normal  Created    32s   kubelet, js-156-120.jetstream-cloud.org  Created container
     Normal  Started    32s   kubelet, js-156-120.jetstream-cloud.org  Started container
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy mozart-elasticsearch
   NAME                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   mozart-elasticsearch   1         1         1            1           86s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy mozart-elasticsearch
   Name:                   mozart-elasticsearch
   Namespace:              default
   CreationTimestamp:      Sat, 06 Oct 2018 22:31:27 -0400
   Labels:                 <none>
   Annotations:            deployment.kubernetes.io/revision: 1
   Selector:               run=mozart-elasticsearch
   Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
   StrategyType:           RollingUpdate
   MinReadySeconds:        0
   RollingUpdateStrategy:  25% max unavailable, 25% max surge
   Pod Template:
     Labels:  run=mozart-elasticsearch
     Containers:
      mozart-elasticsearch:
       Image:       hysds/elasticsearch:1.7
       Ports:       9200/TCP, 9300/TCP
       Host Ports:  0/TCP, 0/TCP
       Command:
         elasticsearch
       Args:
         -Des.node.name='mozart-elasticsearch'
         -Des.cluster.name='resource_cluster'
         -Des.bootstrap.mlockall=true
         -Des.network.host=0
       Limits:
         cpu:  100m
       Environment:
         ES_HEAP_SIZE:       100m
         MAX_LOCKED_MEMORY:  unlimited
       Mounts:
         /usr/share/elasticsearch/config from config (rw)
         /usr/share/elasticsearch/data from data (rw)
     Volumes:
      data:
       Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
       Medium:  
      config:
       Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
       Medium:  
   Conditions:
     Type           Status  Reason
     ----           ------  ------
     Available      True    MinimumReplicasAvailable
     Progressing    True    NewReplicaSetAvailable
   OldReplicaSets:  mozart-elasticsearch-7f4f8fd8f9 (1/1 replicas created)
   NewReplicaSet:   <none>
   Events:
     Type    Reason             Age   From                   Message
     ----    ------             ----  ----                   -------
     Normal  ScalingReplicaSet  109s  deployment-controller  Scaled up replica set mozart-elasticsearch-7f4f8fd8f9 to 1
   ```
1. Verify service is running:
   ```
   $ kubectl get service mozart-elasticsearch
   NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
   mozart-elasticsearch   NodePort   10.100.88.102   <none>        9200:32440/TCP,9300:31251/TCP   2m32s
   ```
   Describe service:
   ```
   $ kubectl describe service mozart-elasticsearch
   Name:                     mozart-elasticsearch
   Namespace:                default
   Labels:                   run=mozart-elasticsearch
   Annotations:              <none>
   Selector:                 run=mozart-elasticsearch
   Type:                     NodePort
   IP:                       10.100.88.102
   Port:                     http  9200/TCP
   TargetPort:               9200/TCP
   NodePort:                 http  32440/TCP
   Endpoints:                10.44.0.1:9200
   Port:                     tcp  9300/TCP
   TargetPort:               9300/TCP
   NodePort:                 tcp  31251/TCP
   Endpoints:                10.44.0.1:9300
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:                   <none>
   ```
1. Use kubectl exec to enter the pod and run curl to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=mozart-elasticsearch | grep -v NAME | awk '{print $1}') bash
   root@mozart-elasticsearch-7f4f8fd8f9-zj4g6:/usr/share/elasticsearch# curl localhost:9200
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
   root@mozart-elasticsearch-7f4f8fd8f9-zj4g6:/usr/share/elasticsearch# curl -XPUT 'http://localhost:9200/twitter/tweet/1' -d '{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }'
   
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"created":true}root@mozart-elasticsearch-7f4f8fd8f9-zj4g6:/usr/share/elasticsearch# 
   root@mozart-elasticsearch-7f4f8fd8f9-zj4g6:/usr/share/elasticsearch# curl http://localhost:9200/twitter/tweet/1
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"found":true,"_source":{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }}
   $ exit
   ```
1. Verify that service is reachable from any pod in the cluster:
   ```
   $ kubectl run -i -t test-verdi --image=hysds/verdi:latest bash
   kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
   If you don't see a command prompt, try pressing enter.
   ops@test-verdi-79cc7bb54d-wnbf2:~$ nslookup mozart-elasticsearch
   Server:         10.96.0.10
   Address:        10.96.0.10#53
   
   Name:   mozart-elasticsearch.default.svc.cluster.local
   Address: 10.100.88.102
   
   ops@test-verdi-79cc7bb54d-wnbf2:~$ curl mozart-elasticsearch:9200/twitter/tweet/1
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"found":true,"_source":{
              "user" : "kimchy",
              "post_date" : "2009-11-15T14:12:12",
              "message" : "trying out Elasticsearch"
   }}
   ops@test-verdi-79cc7bb54d-wnbf2:~$ exit
   exit
   Session ended, resume using 'kubectl attach test-verdi-79cc7bb54d-wnbf2 -c test-verdi -i -t' command when the pod is running

   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```
1. Verify that service is reachable from an instance outside of the cluster:
   ```
   $ MOZART_ELASTICSEARCH_IP=$(kubectl describe pod -l run=mozart-elasticsearch | grep '^Node:' | cut -d/ -f2)
   $ MOZART_ELASTICSEARCH_PORT=$(kubectl describe service mozart-elasticsearch | grep 'NodePort:' | head -1 | awk '{print $3}' | cut -d/ -f1)
   $ curl ${MOZART_ELASTICSEARCH_IP}:${MOZART_ELASTICSEARCH_PORT}/twitter/tweet/1
   {"_index":"twitter","_type":"tweet","_id":"1","_version":1,"found":true,"_source":{
       "user" : "kimchy",
       "post_date" : "2009-11-15T14:12:12",
       "message" : "trying out Elasticsearch"
   }}
   ```

## RabbitMQ
1. Create ConfigMap for rabbitmq:
   ```
   kubectl create configmap mozart-rabbitmq-config --from-file=rabbitmq-config \
     --from-file=rabbitmq-server
   ```
1. Examine the ConfigMap:
   ```
   kubectl get configmap mozart-rabbitmq-config -o yaml
   apiVersion: v1
   data:
     rabbitmq-config: |
       [
         { rabbit,
           [
             { loopback_users, [] },
             { heartbeat, 300 },
             { vm_memory_high_watermark, 100 },
             { tcp_listen_options, [ binary,
                                     { packet, raw },
                                     { reuseaddr, true },
                                     { backlog, 128 },
                                     { nodelay, true },
                                     { exit_on_close, false },
                                     { keepalive, true }
                                  ]
             }
           ]
         }
       ].
     rabbitmq-server: |
       # This file is sourced by /etc/init.d/rabbitmq-server. Its primary
       # reason for existing is to allow adjustment of system limits for the
       # rabbitmq-server process.
       #
       # Maximum number of open file handles. This will need to be increased
       # to handle many simultaneous connections. Refer to the system
       # documentation for ulimit (in man bash) for more information.
       #
       ulimit -n 102400
   kind: ConfigMap
   metadata:
     creationTimestamp: 2018-10-06T21:28:08Z
     name: mozart-rabbitmq-config
     namespace: default
     resourceVersion: "23163"
     selfLink: /api/v1/namespaces/default/configmaps/mozart-rabbitmq-config
     uid: b807fa29-c9ae-11e8-af6e-fa163e051185
   ```
1. Create the `mozart-rabbitmq` service:
   ```
   $ kubectl create -f mozart-rabbitmq.yaml
   service/mozart-rabbitmq created
   deployment.apps/mozart-rabbitmq created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=mozart-rabbitmq
   NAME                              READY   STATUS    RESTARTS   AGE
   mozart-rabbitmq-c5fb88f6c-2hf9g   1/1     Running   0          35s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=mozart-rabbitmq
   Name:               mozart-rabbitmq-c5fb88f6c-2hf9g
   Namespace:          default
   Priority:           0
   PriorityClassName:  <none>
   Node:               js-156-120.jetstream-cloud.org/172.28.26.9
   Start Time:         Sat, 06 Oct 2018 21:25:39 -0400
   Labels:             pod-template-hash=c5fb88f6c
                       run=mozart-rabbitmq
   Annotations:        <none>
   Status:             Running
   IP:                 10.44.0.2
   Controlled By:      ReplicaSet/mozart-rabbitmq-c5fb88f6c
   Containers:
     mozart-rabbitmq:
       Container ID:   docker://84b28152334061d27d1d0207da69b51889b158b774a5d5df7a3901a33d029120
       Image:          hysds/rabbitmq:latest
       Image ID:       docker-pullable://hysds/rabbitmq@sha256:8792a5cfca8ad7f6131145eb6f2cff1bd93be78fce580691d34d091a27f72a4a
       Ports:          5672/TCP, 15672/TCP
       Host Ports:     0/TCP, 0/TCP
       State:          Running
         Started:      Sat, 06 Oct 2018 21:25:42 -0400
       Ready:          True
       Restart Count:  0
       Limits:
         cpu:  100m
       Requests:
         cpu:        100m
       Environment:  <none>
       Mounts:
         /etc/default/rabbitmq-server from config (rw)
         /etc/rabbitmq/rabbitmq.config from config (rw)
         /var/lib/rabbitmq from data (rw)
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
       Name:      mozart-rabbitmq-config
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
     Type    Reason     Age   From                                     Message
     ----    ------     ----  ----                                     -------
     Normal  Scheduled  61s   default-scheduler                        Successfully assigned default/mozart-rabbitmq-c5fb88f6c-2hf9g to js-156-120.jetstream-cloud.org
     Normal  Pulling    59s   kubelet, js-156-120.jetstream-cloud.org  pulling image "hysds/rabbitmq:latest"
     Normal  Pulled     58s   kubelet, js-156-120.jetstream-cloud.org  Successfully pulled image "hysds/rabbitmq:latest"
     Normal  Created    57s   kubelet, js-156-120.jetstream-cloud.org  Created container
     Normal  Started    57s   kubelet, js-156-120.jetstream-cloud.org  Started container
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy mozart-rabbitmq
   NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   mozart-rabbitmq   1         1         1            1           113s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy mozart-rabbitmq
   Name:                   mozart-rabbitmq
   Namespace:              default
   CreationTimestamp:      Sat, 06 Oct 2018 21:25:38 -0400
   Labels:                 <none>
   Annotations:            deployment.kubernetes.io/revision: 1
   Selector:               run=mozart-rabbitmq
   Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
   StrategyType:           RollingUpdate
   MinReadySeconds:        0
   RollingUpdateStrategy:  25% max unavailable, 25% max surge
   Pod Template:
     Labels:  run=mozart-rabbitmq
     Containers:
      mozart-rabbitmq:
       Image:       hysds/rabbitmq:latest
       Ports:       5672/TCP, 15672/TCP
       Host Ports:  0/TCP, 0/TCP
       Limits:
         cpu:        100m
       Environment:  <none>
       Mounts:
         /etc/default/rabbitmq-server from config (rw)
         /etc/rabbitmq/rabbitmq.config from config (rw)
         /var/lib/rabbitmq from data (rw)
     Volumes:
      data:
       Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
       Medium:  
      config:
       Type:      ConfigMap (a volume populated by a ConfigMap)
       Name:      mozart-rabbitmq-config
       Optional:  false
   Conditions:
     Type           Status  Reason
     ----           ------  ------
     Available      True    MinimumReplicasAvailable
     Progressing    True    NewReplicaSetAvailable
   OldReplicaSets:  mozart-rabbitmq-c5fb88f6c (1/1 replicas created)
   NewReplicaSet:   <none>
   Events:
     Type    Reason             Age    From                   Message
     ----    ------             ----   ----                   -------
     Normal  ScalingReplicaSet  2m32s  deployment-controller  Scaled up replica set mozart-rabbitmq-c5fb88f6c to 1
   ```
1. Verify service is running:
   ```
   $ kubectl get service mozart-rabbitmq
   NAME              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                          AGE
   mozart-rabbitmq   NodePort   10.110.13.72   <none>        5672:30941/TCP,15672:30173/TCP   4m9s
   ```
   Describe service:
   ```
   $ kubectl describe service mozart-rabbitmq
   Name:                     mozart-rabbitmq
   Namespace:                default
   Labels:                   run=mozart-rabbitmq
   Annotations:              <none>
   Selector:                 run=mozart-rabbitmq
   Type:                     NodePort
   IP:                       10.110.13.72
   Port:                     amqp  5672/TCP
   TargetPort:               5672/TCP
   NodePort:                 amqp  30941/TCP
   Endpoints:                10.44.0.2:5672
   Port:                     http  15672/TCP
   TargetPort:               15672/TCP
   NodePort:                 http  30173/TCP
   Endpoints:                10.44.0.2:15672
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:                   <none>
   ```
1. Use kubectl exec to enter the pod and run rabbitmqctl to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=mozart-rabbitmq | grep -v NAME | awk '{print $1}') rabbitmqctl status
   Status of node rabbit@mozart-rabbitmq-c5fb88f6c-2hf9g ...
   [{pid,167},
    {running_applications,
        [{rabbitmq_management,"RabbitMQ Management Console","3.7.8"},
         {rabbitmq_web_dispatch,"RabbitMQ Web Dispatcher","3.7.8"},
         {rabbitmq_management_agent,"RabbitMQ Management Agent","3.7.8"},
         {amqp_client,"RabbitMQ AMQP Client","3.7.8"},
         {rabbit,"RabbitMQ","3.7.8"},
         {mnesia,"MNESIA  CXC 138 12","4.15.3.1"},
         {rabbit_common,
             "Modules shared by rabbitmq-server and rabbitmq-erlang-client",
             "3.7.8"},
         {cowboy,"Small, fast, modern HTTP server.","2.2.2"},
         {ranch_proxy_protocol,"Ranch Proxy Protocol Transport","1.5.0"},
         {ranch,"Socket acceptor pool for TCP protocols.","1.5.0"},
         {ssl,"Erlang/OTP SSL application","8.2.6.2"},
         {public_key,"Public key infrastructure","1.5.2"},
         {asn1,"The Erlang ASN1 compiler version 5.0.5.1","5.0.5.1"},
         {cowlib,"Support library for manipulating Web protocols.","2.1.0"},
         {jsx,"a streaming, evented json parsing toolkit","2.8.2"},
         {inets,"INETS  CXC 138 49","6.5.2.2"},
         {os_mon,"CPO  CXC 138 46","2.4.4"},
         {recon,"Diagnostic tools for production use","2.3.2"},
         {xmerl,"XML parser","1.3.16"},
         {crypto,"CRYPTO","4.2.2.1"},
         {lager,"Erlang logging framework","3.6.3"},
         {goldrush,"Erlang event stream processor","0.1.9"},
         {compiler,"ERTS  CXC 138 10","7.1.5.1"},
         {syntax_tools,"Syntax tools","2.1.4.1"},
         {syslog,"An RFC 3164 and RFC 5424 compliant logging framework.","3.4.3"},
         {sasl,"SASL  CXC 138 11","3.1.2"},
         {stdlib,"ERTS  CXC 138 10","3.4.5"},
         {kernel,"ERTS  CXC 138 10","5.4.3.2"}]},
    {os,{unix,linux}},
    {erlang_version,
        "Erlang/OTP 20 [erts-9.3.3.3] [source] [64-bit] [smp:2:2] [ds:2:2:10] [async-threads:64] [hipe] [kernel-poll:true]\n"},
    {memory,
        [{connection_readers,0},
         {connection_writers,0},
         {connection_channels,0},
         {connection_other,2840},
         {queue_procs,0},
         {queue_slave_procs,0},
         {plugins,938776},
         {other_proc,22079856},
         {metrics,195088},
         {mgmt_db,150768},
         {mnesia,74488},
         {other_ets,2270256},
         {binary,82928},
         {msg_index,30320},
         {code,28588778},
         {atom,1131721},
         {other_system,10478845},
         {allocated_unused,8092456},
         {reserved_unallocated,0},
         {strategy,rss},
         {total,[{erlang,66024664},{rss,66498560},{allocated,74117120}]}]},
    {alarms,[]},
    {listeners,[{clustering,25672,"::"},{amqp,5672,"::"},{http,15672,"::"}]},
    {vm_memory_calculation_strategy,rss},
    {vm_memory_high_watermark,100},
    {vm_memory_limit,3974053888},
    {disk_free_limit,50000000},
    {disk_free,13771042816},
    {file_descriptors,
        [{total_limit,65436},
         {total_used,2},
         {sockets_limit,58890},
         {sockets_used,0}]},
    {processes,[{limit,1048576},{used,371}]},
    {run_queue,0},
    {uptime,522},
    {kernel,{net_ticktime,60}}]
   ```
1. Verify that service is reachable from any pod in the cluster:
   ```
   $ kubectl run -i -t test-verdi --image=hysds/verdi:latest bash
   kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
   If you don't see a command prompt, try pressing enter.
   ops@test-verdi-79cc7bb54d-8sll6:~$ nslookup mozart-rabbitmq
   Server:         10.96.0.10
   Address:        10.96.0.10#53
   
   Name:   mozart-rabbitmq.default.svc.cluster.local
   Address: 10.110.13.72
   
   ops@test-verdi-79cc7bb54d-8sll6:~$ curl mozart-rabbitmq:15672
   <!doctype html>
   <meta http-equiv="X-UA-Compatible" content="IE=edge" />
   <html>
     <head>
       <title>RabbitMQ Management</title>
       <script src="js/ejs-1.0.min.js" type="text/javascript"></script>
       <script src="js/jquery-1.12.4.min.js" type="text/javascript"></script>
       <script src="js/jquery.flot-0.8.1.min.js" type="text/javascript"></script>
       <script src="js/jquery.flot-0.8.1.time.min.js" type="text/javascript"></script>
       <script src="js/sammy-0.7.6.min.js" type="text/javascript"></script>
       <script src="js/json2-2016.10.28.js" type="text/javascript"></script>
       <script src="js/base64.js" type="text/javascript"></script>
       <script src="js/global.js" type="text/javascript"></script>
       <script src="js/main.js" type="text/javascript"></script>
       <script src="js/prefs.js" type="text/javascript"></script>
       <script src="js/formatters.js" type="text/javascript"></script>
       <script src="js/charts.js" type="text/javascript"></script>
   
       <link href="css/main.css" rel="stylesheet" type="text/css"/>
       <link href="favicon.ico" rel="shortcut icon" type="image/x-icon"/>
   
   <!--[if lte IE 8]>
       <script src="js/excanvas.min.js" type="text/javascript"></script>
       <link href="css/evil.css" rel="stylesheet" type="text/css"/>
   <![endif]-->
     </head>
     <body>
       <div id="outer"></div>
       <div id="debug"></div>
       <div id="scratch"></div>
     </body>
   </html>
   ops@test-verdi-79cc7bb54d-8sll6:~$ exit
   exit
   Session ended, resume using 'kubectl attach test-verdi-79cc7bb54d-8sll6 -c test-verdi -i -t' command when the pod is running

   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```
1. Verify that service is reachable from an instance outside of the cluster:
   ```
   $ MOZART_RABBITMQ_IP=$(kubectl describe pod -l run=mozart-rabbitmq | grep '^Node:' | cut -d/ -f2)
   $ MOZART_RABBITMQ_PORT=$(kubectl describe service mozart-rabbitmq | grep 'NodePort:' | tail -1 | awk '{print $3}' | cut -d/ -f1)
   $ curl ${MOZART_RABBITMQ_IP}:${MOZART_RABBITMQ_PORT}
   <!doctype html>
   <meta http-equiv="X-UA-Compatible" content="IE=edge" />
   <html>
     <head>
       <title>RabbitMQ Management</title>
       <script src="js/ejs-1.0.min.js" type="text/javascript"></script>
       <script src="js/jquery-1.12.4.min.js" type="text/javascript"></script>
       <script src="js/jquery.flot-0.8.1.min.js" type="text/javascript"></script>
       <script src="js/jquery.flot-0.8.1.time.min.js" type="text/javascript"></script>
       <script src="js/sammy-0.7.6.min.js" type="text/javascript"></script>
       <script src="js/json2-2016.10.28.js" type="text/javascript"></script>
       <script src="js/base64.js" type="text/javascript"></script>
       <script src="js/global.js" type="text/javascript"></script>
       <script src="js/main.js" type="text/javascript"></script>
       <script src="js/prefs.js" type="text/javascript"></script>
       <script src="js/formatters.js" type="text/javascript"></script>
       <script src="js/charts.js" type="text/javascript"></script>
   
       <link href="css/main.css" rel="stylesheet" type="text/css"/>
       <link href="favicon.ico" rel="shortcut icon" type="image/x-icon"/>
   
   <!--[if lte IE 8]>
       <script src="js/excanvas.min.js" type="text/javascript"></script>
       <link href="css/evil.css" rel="stylesheet" type="text/css"/>
   <![endif]-->
     </head>
     <body>
       <div id="outer"></div>
       <div id="debug"></div>
       <div id="scratch"></div>
     </body>
   </html>
   ```

## Mozart
1. Create ConfigMap for mozart:
   ```
   $ kubectl create configmap mozart-config --from-file=../celeryconfig.py \
     --from-file=event_status.template --from-file=indexer.conf \
     --from-file=job_status.template --from-file=orchestrator_datasets.json \
     --from-file=orchestrator_jobs.json --from-file=settings.cfg \
     --from-file=supervisord.conf --from-file=task_status.template \
     --from-file=worker_status.template
   ```
1. Examine the ConfigMap:
   ```
   $ kubectl get configmap mozart-config -o yaml
   ```
1. Create the `mozart` service:
   ```
   $ kubectl create -f mozart.yaml
   service/mozart created
   deployment.apps/mozart created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=mozart
   NAME                      READY   STATUS    RESTARTS   AGE
   mozart-59d74fd96f-f7rtm   1/1     Running   0          93s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=mozart
   NAME                      READY   STATUS    RESTARTS   AGE
   mozart-59d74fd96f-f7rtm   1/1     Running   0          93s
   gmanipon@js-157-99:~/dev/hysds-k8s/mozart$ kc describe pod -l run=mozart
   Name:               mozart-59d74fd96f-f7rtm
   Namespace:          default
   Priority:           0
   PriorityClassName:  <none>
   Node:               js-170-15.jetstream-cloud.org/172.28.26.10
   Start Time:         Sun, 07 Oct 2018 02:01:09 -0400
   Labels:             pod-template-hash=59d74fd96f
                       run=mozart
   Annotations:        <none>
   Status:             Running
   IP:                 10.42.0.2
   Controlled By:      ReplicaSet/mozart-59d74fd96f
   Containers:
     mozart:
       Container ID:   docker://2c65904e811eb5e96fe704051c187bd169d9002f233c87412c3a8b86ead08d8f
       Image:          hysds/mozart:latest
       Image ID:       docker-pullable://hysds/mozart@sha256:4ef18bf46d2832e8f3104be62f4004b51cc9ee26bc9a97367a626d316d3dde5c
       Ports:          80/TCP, 443/TCP, 5555/TCP, 8888/TCP, 8898/TCP, 9001/TCP
       Host Ports:     0/TCP, 0/TCP, 0/TCP, 0/TCP, 0/TCP, 0/TCP
       State:          Running
         Started:      Sun, 07 Oct 2018 02:01:13 -0400
       Ready:          True
       Restart Count:  0
       Limits:
         cpu:  100m
       Requests:
         cpu:        100m
       Environment:  <none>
       Mounts:
         /home/ops/mozart/etc/celeryconfig.py from config (rw)
         /home/ops/mozart/etc/event_status.template from config (rw)
         /home/ops/mozart/etc/indexer.conf from config (rw)
         /home/ops/mozart/etc/job_status.template from config (rw)
         /home/ops/mozart/etc/orchestrator_datasets.json from config (rw)
         /home/ops/mozart/etc/orchestrator_jobs.json from config (rw)
         /home/ops/mozart/etc/settings.cfg from config (rw)
         /home/ops/mozart/etc/supervisord.conf from config (rw)
         /home/ops/mozart/etc/task_status.template from config (rw)
         /home/ops/mozart/etc/worker_status.template from config (rw)
         /home/ops/mozart/log from log (rw)
         /var/run/secrets/kubernetes.io/serviceaccount from default-token-jc59x (ro)
   Conditions:
     Type              Status
     Initialized       True 
     Ready             True 
     ContainersReady   True 
     PodScheduled      True 
   Volumes:
     config:
       Type:      ConfigMap (a volume populated by a ConfigMap)
       Name:      mozart-config
       Optional:  false
     log:
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
     Type    Reason     Age   From                                    Message
     ----    ------     ----  ----                                    -------
     Normal  Scheduled  115s  default-scheduler                       Successfully assigned default/mozart-59d74fd96f-f7rtm to js-170-15.jetstream-cloud.org
     Normal  Pulling    113s  kubelet, js-170-15.jetstream-cloud.org  pulling image "hysds/mozart:latest"
     Normal  Pulled     112s  kubelet, js-170-15.jetstream-cloud.org  Successfully pulled image "hysds/mozart:latest"
     Normal  Created    111s  kubelet, js-170-15.jetstream-cloud.org  Created container
     Normal  Started    111s  kubelet, js-170-15.jetstream-cloud.org  Started container
   ```
1. Verify deployment is running:
   ```
   $ kubectl get deploy mozart
   NAME     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   mozart   1         1         1            1           3m10s
   ```
   Describe deployment:
   ```
   $ kubectl describe deploy mozart
   Name:                   mozart
   Namespace:              default
   CreationTimestamp:      Sun, 07 Oct 2018 02:01:09 -0400
   Labels:                 <none>
   Annotations:            deployment.kubernetes.io/revision: 1
   Selector:               run=mozart
   Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
   StrategyType:           RollingUpdate
   MinReadySeconds:        0
   RollingUpdateStrategy:  25% max unavailable, 25% max surge
   Pod Template:
     Labels:  run=mozart
     Containers:
      mozart:
       Image:       hysds/mozart:latest
       Ports:       80/TCP, 443/TCP, 5555/TCP, 8888/TCP, 8898/TCP, 9001/TCP
       Host Ports:  0/TCP, 0/TCP, 0/TCP, 0/TCP, 0/TCP, 0/TCP
       Limits:
         cpu:        100m
       Environment:  <none>
       Mounts:
         /home/ops/mozart/etc/celeryconfig.py from config (rw)
         /home/ops/mozart/etc/event_status.template from config (rw)
         /home/ops/mozart/etc/indexer.conf from config (rw)
         /home/ops/mozart/etc/job_status.template from config (rw)
         /home/ops/mozart/etc/orchestrator_datasets.json from config (rw)
         /home/ops/mozart/etc/orchestrator_jobs.json from config (rw)
         /home/ops/mozart/etc/settings.cfg from config (rw)
         /home/ops/mozart/etc/supervisord.conf from config (rw)
         /home/ops/mozart/etc/task_status.template from config (rw)
         /home/ops/mozart/etc/worker_status.template from config (rw)
         /home/ops/mozart/log from log (rw)
     Volumes:
      config:
       Type:      ConfigMap (a volume populated by a ConfigMap)
       Name:      mozart-config
       Optional:  false
      log:
       Type:    EmptyDir (a temporary directory that shares a pod's lifetime)
       Medium:  
   Conditions:
     Type           Status  Reason
     ----           ------  ------
     Available      True    MinimumReplicasAvailable
     Progressing    True    NewReplicaSetAvailable
   OldReplicaSets:  <none>
   NewReplicaSet:   mozart-59d74fd96f (1/1 replicas created)
   Events:
     Type    Reason             Age    From                   Message
     ----    ------             ----   ----                   -------
     Normal  ScalingReplicaSet  3m39s  deployment-controller  Scaled up replica set mozart-59d74fd96f to 1
   ```
1. Verify service is running:
   ```
   $ kubectl get service mozart
   NAME     TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                                                  AGE
   mozart   NodePort   10.103.117.0   <none>        80:31104/TCP,443:32374/TCP,5555:31117/TCP,8888:30011/TCP,8898:30350/TCP,9001:31418/TCP   4m32s
   ```
   Describe service:
   ```
   $ kubectl describe service mozart
   Name:                     mozart
   Namespace:                default
   Labels:                   run=mozart
   Annotations:              <none>
   Selector:                 run=mozart
   Type:                     NodePort
   IP:                       10.103.117.0
   Port:                     http  80/TCP
   TargetPort:               80/TCP
   NodePort:                 http  31104/TCP
   Endpoints:                10.42.0.2:80
   Port:                     https  443/TCP
   TargetPort:               443/TCP
   NodePort:                 https  32374/TCP
   Endpoints:                10.42.0.2:443
   Port:                     flower  5555/TCP
   TargetPort:               5555/TCP
   NodePort:                 flower  31117/TCP
   Endpoints:                10.42.0.2:5555
   Port:                     mozart  8888/TCP
   TargetPort:               8888/TCP
   NodePort:                 mozart  30011/TCP
   Endpoints:                10.42.0.2:8888
   Port:                     figaro  8898/TCP
   TargetPort:               8898/TCP
   NodePort:                 figaro  30350/TCP
   Endpoints:                10.42.0.2:8898
   Port:                     supervisord  9001/TCP
   TargetPort:               9001/TCP
   NodePort:                 supervisord  31418/TCP
   Endpoints:                10.42.0.2:9001
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:                   <none>
   ```
1. Use kubectl exec to enter the pod and run curl to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=mozart | grep -v NAME | awk '{print $1}') bash
   ops@mozart-59d74fd96f-f7rtm:~$ curl -k https://localhost/mozart/api/v0.1/swagger.json
   ```
1. Verify that service is reachable from any pod in the cluster:
   ```
   $ kubectl run -i -t test-verdi --image=hysds/verdi:latest bash
   kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
   If you don't see a command prompt, try pressing enter.
   ops@test-verdi-79cc7bb54d-6d6j7:~$ nslookup mozart
   Server:         10.96.0.10
   Address:        10.96.0.10#53
   
   Name:   mozart.default.svc.cluster.local
   Address: 10.102.133.142
   
   ops@test-verdi-79cc7bb54d-6d6j7:~$ curl -k https://mozart/mozart/api/v0.1/swagger.json 
   exit
   Session ended, resume using 'kubectl attach test-verdi-79cc7bb54d-wnbf2 -c test-verdi -i -t' command when the pod is running

   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```
1. Verify that service is reachable from an instance outside of the cluster:
   ```
   $ MOZART_IP=$(kubectl describe pod -l run=mozart | grep '^Node:' | cut -d/ -f2)
   $ MOZART_PORT=$(kubectl describe service mozart | grep 'NodePort:' | head -2 | tail -1 | awk '{print $3}' | cut -d/ -f1)
   $ curl -k https://${MOZART_IP}:${MOZART_PORT}/mozart/api/v0.1/swagger.json
