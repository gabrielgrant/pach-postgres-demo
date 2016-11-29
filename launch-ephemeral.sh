#! /bin/bash

kubectl create -f https://github.com/gabrielgrant/pach-postgres-demo/blob/master/postgres-ephemeral-pod.yml?raw=true
kubectl create -f https://github.com/gabrielgrant/pach-postgres-demo/blob/master/postgres-service.yml?raw=true
