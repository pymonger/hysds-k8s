#!/bin/bash

# delete services
kubectl delete svc,deploy -l component=grq

# delete configmap
kubectl delete configmap hysds-grq-config
