#!/bin/bash

# delete services
kubectl delete svc,deploy -l component=mozart

# create configmaps
kubectl delete configmap hysds-global-config
kubectl delete configmap hysds-mozart-config
