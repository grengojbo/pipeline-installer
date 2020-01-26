#!/usr/bin/env bash

echo "Waiting for Kubernetes to be up and running, it will take a few minutes"

until [[ "$(test -f $(which kubectl 2>/dev/null) 2>/dev/null && kubectl get nodes -l 'node-role.kubernetes.io/master=' -o jsonpath='{range .items[*]}{range @.status.conditions[?(@.type=="Ready")]}{@.status}{end}{end}' 2>/dev/null)" = "True" ]]
do
    sleep 5
done
