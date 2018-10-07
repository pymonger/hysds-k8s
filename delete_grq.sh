#!/bin/bash

# delete services
kubectl delete svc,deploy -l component=grq

# create configmaps
kubectl delete configmap hysds-global-config
kubectl delete configmap hysds-grq-config
