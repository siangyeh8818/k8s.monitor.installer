#!/bin/bash

TimeRange=$1

#NAMESPACES=$(kubectl get pods --all-namespaces | grep ceph-mgr | awk '{print $1}')

sed -i 's|__NAMESPACES__|'${NAMESPACES}'|g' all.yaml | sed -i 's|__TimeRange__|'${TimeRange}'|g' all.yaml

kubectl apply -f all.yaml
