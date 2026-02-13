#! /bin/bash

NAMESPACE=retail-app
echo "Updating kubeconfig for EKS cluster..."

aws eks update-kubeconfig \
--name project-bedrock-cluster \
--region us-east-1

echo "================================"
echo "Logging in to Amazon ECR Public..."

aws ecr-public get-login-password \
--region us-east-1 | \
helm registry login --username AWS \
--password-stdin public.ecr.aws

echo "================================"
echo "Creating namespace for retail application..."

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "================================"
echo "Deploying Redis, DynamoDB, and RabbitMQ using Helm charts..."

helm upgrade --install redis ./redis -n $NAMESPACE \

echo "================================"

helm upgrade --install dynamodb ./dynamodb -n $NAMESPACE

echo "================================"

helm upgrade --install rabbitmq ./rabbitmq -n $NAMESPACE \
--set auth.username=$DB_USERNAME \
--set auth.password=$DB_PASSWORD

echo "================================"

helm upgrade --install frontend \
oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart \
--version 1.4.0 \
--namespace $NAMESPACE \
-f ./ms-values/frontend-values.yaml

echo "================================"

helm upgrade --install catalog   \
oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart  \
--version 1.4.0   \
--namespace $NAMESPACE \
-f ./ms-values/catalog-values.yaml \
--set-string env[4].value=$DB_USERNAME \
--set-string env[5].value=$DB_PASSWORD

echo "================================"

helm upgrade --install cart \
oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart  \
--version 1.4.0   \
--namespace $NAMESPACE \
-f ./ms-values/cart-values.yaml

echo "================================"

helm upgrade --install orders \
oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart  \
--version 1.4.0   \
--namespace $NAMESPACE \
-f ./ms-values/orders-values.yaml \
--set-string env[4].value=$DB_USERNAME \
--set-string env[5].value=$DB_PASSWORD \
--set-string env[9].value=$DB_USERNAME \
--set-string env[10].value=$DB_PASSWORD 


echo "================================"

helm upgrade --install checkout  \
oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart \
--version 1.4.0 \
--namespace $NAMESPACE \
-f ./ms-values/checkout-values.yaml 

echo "================================"

sleep 60

kubectl get pods -n $NAMESPACE

echo "================================"

kubectl get pvc -n $NAMESPACE

echo "================================"

kubectl get svc -n $NAMESPACE
