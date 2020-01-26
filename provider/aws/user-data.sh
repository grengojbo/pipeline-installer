#!/usr/bin/env bash

HOME="${HOME:-/root}"
K8S_VERSION="1.16.1"
API_ADDRESS=$(curl -s -q http://169.254.169.254/latest/meta-data/public-ipv4)

curl -q -s -L https://banzaicloud.com/downloads/pke/pke-0.4.17 -o /usr/local/bin/pke
chmod +x /usr/local/bin/pke
export PATH=$PATH:/usr/local/bin/

pke install single --kubernetes-api-server=${API_ADDRESS}:6443 --kubernetes-version=${K8S_VERSION}

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
