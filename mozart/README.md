# Mozart

## Create ConfigMaps
1. If not yet done, create ConfigMap for global HysDS configuration:
   ```
   $ kubectl create configmap hysds-global-config --from-file=../config
   ```
1. Examine the ConfigMap:
   ```
   $ kubectl get configmap hysds-global-config -o yaml
   ``` 
1. Create ConfigMap for all mozart services:
   ```
   $ kubectl create configmap hysds-mozart-config --from-file=config
   ```
1. Examine the ConfigMap:
   ```
   $ kubectl get configmap hysds-mozart-config -o yaml
   ```

## Redis
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
   Labels:            component=mozart
                      run=mozart-redis
   Annotations:       <none>
   Selector:          component=mozart,run=mozart-redis
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
   $ kubectl exec -ti $(kubectl get pod -l run=mozart-redis -o jsonpath="{.items[0].metadata.name}") redis-cli
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
   ```
   Delete test pod:
   ```
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
   Labels:                   component=mozart
                             run=mozart-elasticsearch
   Annotations:              <none>
   Selector:                 component=mozart,run=mozart-elasticsearch
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
   $ kubectl exec -ti $(kubectl get pod -l run=mozart-elasticsearch -o jsonpath="{.items[0].metadata.name}") bash
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
1. Use a test pod to verify that service is reachable from any pod in the cluster:
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
   $ MOZART_ELASTICSEARCH_IP=$(kubectl get pod -l run=mozart-elasticsearch -o jsonpath="{.items[0].status.hostIP}")
   $ MOZART_ELASTICSEARCH_PORT=$(kubectl get service mozart-elasticsearch -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
   $ echo "curl ${MOZART_ELASTICSEARCH_IP}:${MOZART_ELASTICSEARCH_PORT}/twitter/tweet/1"
   ```
   On an instance outside of the cluster, copy the output from the `echo` command above and execute. Output should match that of the previous step.

## RabbitMQ
1. Create the `mozart-rabbitmq` service:
   ```
   $ kubectl create -f mozart-rabbitmq.yaml
   service/mozart-rabbitmq created
   deployment.apps/mozart-rabbitmq created
   ```
1. Verify pods are running:
   ```
   $ kubectl get pod -l run=mozart-rabbitmq
   NAME                               READY   STATUS              RESTARTS   AGE
   mozart-rabbitmq-54df494494-w22vm   0/1     ContainerCreating   0          23s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=mozart-rabbitmq
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
   ```
1. Verify service is running:
   ```
   $ kubectl get service mozart-rabbitmq
   NAME              TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                          AGE
   mozart-rabbitmq   NodePort   10.106.200.116   <none>        5672:31954/TCP,15672:32406/TCP   68s
   ```
   Describe service:
   ```
   $ kubectl describe service mozart-rabbitmq
   Name:                     mozart-rabbitmq
   Namespace:                default
   Labels:                   component=mozart
                             run=mozart-rabbitmq
   Annotations:              <none>
   Selector:                 component=mozart,run=mozart-rabbitmq
   Type:                     NodePort
   IP:                       10.106.200.116
   Port:                     amqp  5672/TCP
   TargetPort:               5672/TCP
   NodePort:                 amqp  31954/TCP
   Endpoints:                10.42.0.2:5672
   Port:                     http  15672/TCP
   TargetPort:               15672/TCP
   NodePort:                 http  32406/TCP
   Endpoints:                10.42.0.2:15672
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:                   <none>
   ```
1. Use kubectl exec to enter the pod and run rabbitmqctl to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=mozart-rabbitmq -o jsonpath="{.items[0].metadata.name}") rabbitmqctl status
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
1. Use a test pod to verify that service is reachable from any pod in the cluster:
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
   ```
   Delete test pod:
   ```
   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```
1. Verify that service is reachable from an instance outside of the cluster:
   ```
   $ MOZART_RABBITMQ_IP=$(kubectl get pod -l run=mozart-rabbitmq -o jsonpath="{.items[0].status.hostIP}")
   $ MOZART_RABBITMQ_PORT=$(kubectl get service mozart-rabbitmq -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
   $ echo "curl ${MOZART_RABBITMQ_IP}:${MOZART_RABBITMQ_PORT}"
   ```
   On an instance outside of the cluster, copy the output from the `echo` command above and execute. Output should match that of the previous step.

## Mozart
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
   mozart-555974758c-dt6ml   1/1     Running   0          14s
   ```
   Describe pods:
   ```
   $ kubectl describe pod -l run=mozart
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
   ```
1. Verify service is running:
   ```
   $ kubectl get service mozart
   NAME     TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                                  AGE
   mozart   NodePort   10.108.23.244   <none>        80:30110/TCP,443:31418/TCP,5555:31753/TCP,8888:30633/TCP,8898:32730/TCP,9001:31233/TCP   103s
   ```
   Describe service:
   ```
   $ kubectl describe service mozart
   Name:                     mozart
   Namespace:                default
   Labels:                   component=mozart
                             run=mozart
   Annotations:              <none>
   Selector:                 component=mozart,run=mozart
   Type:                     NodePort
   IP:                       10.108.23.244
   Port:                     http  80/TCP
   TargetPort:               80/TCP
   NodePort:                 http  30110/TCP
   Endpoints:                10.42.0.3:80
   Port:                     https  443/TCP
   TargetPort:               443/TCP
   NodePort:                 https  31418/TCP
   Endpoints:                10.42.0.3:443
   Port:                     flower  5555/TCP
   TargetPort:               5555/TCP
   NodePort:                 flower  31753/TCP
   Endpoints:                10.42.0.3:5555
   Port:                     mozart  8888/TCP
   TargetPort:               8888/TCP
   NodePort:                 mozart  30633/TCP
   Endpoints:                10.42.0.3:8888
   Port:                     figaro  8898/TCP
   TargetPort:               8898/TCP
   NodePort:                 figaro  32730/TCP
   Endpoints:                10.42.0.3:8898
   Port:                     supervisord  9001/TCP
   TargetPort:               9001/TCP
   NodePort:                 supervisord  31233/TCP
   Endpoints:                10.42.0.3:9001
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:                   <none>
   ```
1. Use kubectl exec to enter the pod and run curl to verify that the configuration was correctly applied:
   ```
   $ kubectl exec -ti $(kubectl get pod -l run=mozart -o jsonpath="{.items[0].metadata.name}") bash
   ops@mozart-59d74fd96f-f7rtm:~$ curl -k https://localhost/mozart/api/v0.1/swagger.json
   ```
1. Use a test pod to verify that service is reachable from any pod in the cluster:
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
   ```
   Delete test pod:
   ```
   $ kubectl delete deploy test-verdi
   deployment.extensions "test-verdi" deleted
   ```
1. Verify that service is reachable from an instance outside of the cluster:
   ```
   $ MOZART_IP=$(kubectl get pod -l run=mozart -o jsonpath="{.items[0].status.hostIP}")
   $ MOZART_PORT=$(kubectl get service mozart -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
   $ echo "curl -k https://${MOZART_IP}:${MOZART_PORT}/mozart/api/v0.1/swagger.json"
   ```
   On an instance outside of the cluster, copy the output from the `echo` command above and execute. Output should match that of the previous step.
