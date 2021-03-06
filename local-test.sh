#!/bin/bash
set -ex

# delete any previous kind cluster
kind delete cluster || true
# create a local kind cluster
kind create cluster --config kubernetes/kind-config.yml

# build the docker image
docker build --tag cloud-ruby:local .
# load the docker image locally into kind
kind load docker-image cloud-ruby:local

# run our our local deployment (including namespace, deployment, service)
kubectl apply --filename kubernetes/local-deployment.yml

# wait for our application to be ready
kubectl wait --namespace cloud-ruby --for=condition=ready pod --selector=app=cloud-ruby --timeout=30s
sleep 10 # race condition with the routing to the containers

# test that we can get to the application
curl --include --silent http://localhost:30123/hello-world | grep "200 OK"