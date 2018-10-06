# Mozart

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
