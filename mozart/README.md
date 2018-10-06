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
1. Create the pod:
   ```
   kubectl create -f rabbitmq-pod.yaml
   ```
1. Verify pod is running:
   ```
   kubectl get pod mozart-rabbitmq
   NAME              READY   STATUS    RESTARTS   AGE
   mozart-rabbitmq   1/1     Running   0          48s
   ```
   Describe pods:
   ```
   kubectl describe pod mozart-rabbitmq
   Name:               mozart-rabbitmq
   Namespace:          default
   Priority:           0
   PriorityClassName:  <none>
   Node:               js-156-76.jetstream-cloud.org/172.28.26.11
   Start Time:         Sat, 06 Oct 2018 17:47:47 -0400
   Labels:             <none>
   Annotations:        <none>
   Status:             Running
   IP:                 10.36.0.1
   Containers:
     mozart-rabbitmq:
       Container ID:   docker://96dbb358956902a962d646dff87ecb513ee01f555d3a3f9dc3c2785daafdfdeb
       Image:          hysds/rabbitmq:latest
       Image ID:       docker-pullable://hysds/rabbitmq@sha256:8792a5cfca8ad7f6131145eb6f2cff1bd93be78fce580691d34d091a27f72a4a
       Ports:          5672/TCP, 15672/TCP
       Host Ports:     0/TCP, 0/TCP
       State:          Running
         Started:      Sat, 06 Oct 2018 17:48:03 -0400
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
     Type    Reason     Age    From                                    Message
     ----    ------     ----   ----                                    -------
     Normal  Scheduled  2m21s  default-scheduler                       Successfully assigned default/mozart-rabbitmq to js-156-76.jetstream-cloud.org
     Normal  Pulling    2m19s  kubelet, js-156-76.jetstream-cloud.org  pulling image "hysds/rabbitmq:latest"
     Normal  Pulled     2m6s   kubelet, js-156-76.jetstream-cloud.org  Successfully pulled image "hysds/rabbitmq:latest"
     Normal  Created    2m6s   kubelet, js-156-76.jetstream-cloud.org  Created container
     Normal  Started    2m5s   kubelet, js-156-76.jetstream-cloud.org  Started container
   ```
1. Use kubectl exec to enter the pod and run rabbitmqctl to verify that the configuration was correctly applied:
   ```
   kubectl exec -ti mozart-rabbitmq rabbitmqctl status
   Status of node rabbit@mozart-rabbitmq ...
   [{pid,168},
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
         {plugins,763392},
         {other_proc,26525648},
         {metrics,195072},
         {mgmt_db,142424},
         {mnesia,73720},
         {other_ets,2224552},
         {binary,161912},
         {msg_index,29296},
         {code,28588778},
         {atom,1131721},
         {other_system,10481213},
         {allocated_unused,5111368},
         {reserved_unallocated,524288},
         {strategy,rss},
         {total,[{erlang,70320568},{rss,75956224},{allocated,75431936}]}]},
    {alarms,[]},
    {listeners,[{clustering,25672,"::"},{amqp,5672,"::"},{http,15672,"::"}]},
    {vm_memory_calculation_strategy,rss},
    {vm_memory_high_watermark,100},
    {vm_memory_limit,3974053888},
    {disk_free_limit,50000000},
    {disk_free,13799059456},
    {file_descriptors,
        [{total_limit,65436},
         {total_used,2},
         {sockets_limit,58890},
         {sockets_used,0}]},
    {processes,[{limit,1048576},{used,371}]},
    {run_queue,0},
    {uptime,107},
    {kernel,{net_ticktime,60}}]
   ```
