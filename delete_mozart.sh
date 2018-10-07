#!/bin/bash

# delete services
kubectl delete svc,deploy -l component=mozart

# delete configmap
kubectl delete configmap hysds-mozart-config
