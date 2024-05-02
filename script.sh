#!/usr/bin/env bash

SERVICE_ACCOUNT_SECRET_NAME=secret-sa-sample
SERVICE_ACCOUNT_NAMESPACE=homework

set -e

CONTEXT=$(kubectl config current-context)
echo "current context: $CONTEXT"

CLUSTER_NAME=$(kubectl config get-contexts "$CONTEXT" | awk '{print $3}' | tail -n 1)
echo "Cluster name: ${CLUSTER_NAME}"

API_SERVER=$(kubectl config view \
    -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}")
echo "API Server: ${API_SERVER}"

CA=$(kubectl get secret/${SERVICE_ACCOUNT_SECRET_NAME} -n ${SERVICE_ACCOUNT_NAMESPACE} -o jsonpath='{.data.ca\.crt}')
TOKEN=$(kubectl get secret/${SERVICE_ACCOUNT_SECRET_NAME} -n ${SERVICE_ACCOUNT_NAMESPACE} -o jsonpath='{.data.token}' | base64 -d)

echo "
apiVersion: v1
kind: Config
clusters:
- name: minikube
  cluster:
    certificate-authority-data: ${CA}
    server: ${API_SERVER}
contexts:
- name: minikube
  context:
    cluster: minikube
    namespace: ${SERVICE_ACCOUNT_NAMESPACE}
    user: "cd"
current-context: minikube
users:
- name: "cd"
  user:
    token: ${TOKEN}
" > sa.kubeconfig

chmod go-r sa.kubeconfig
echo "generated config file: sa.kubeconfig"
