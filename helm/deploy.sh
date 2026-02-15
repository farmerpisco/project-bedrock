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
echo "Deploying Ingress resource for frontend service..."

kubectl apply -f ingress.yaml

echo "================================"
echo "Deploying Redis, DynamoDB, and RabbitMQ using Helm charts..."

helm upgrade --install redis ./redis -n $NAMESPACE \

echo "================================"

helm upgrade --install dynamodb ./dynamodb -n $NAMESPACE

echo "================================"

helm upgrade --install rabbitmq ./rabbitmq -n $NAMESPACE \
--set auth.username=$RABBITMQ_USERNAME \
--set auth.password=$RABBITMQ_PASSWORD

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
--set-string env.RETAIL_CATALOG_PERSISTENCE_ENDPOINT=$MYSQL_ENDPOINT \
--set-string env.RETAIL_CATALOG_PERSISTENCE_USER=$DB_USERNAME \
--set-string env.RETAIL_CATALOG_PERSISTENCE_PASSWORD=$DB_PASSWORD

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
--set-string env.RETAIL_ORDERS_PERSISTENCE_ENDPOINT=$POSTGRESQL_ENDPOINT \
--set-string env.RETAIL_ORDERS_PERSISTENCE_USER=$DB_USERNAME \
--set-string env.RETAIL_ORDERS_PERSISTENCE_PASSWORD=$DB_PASSWORD \
--set-string env.RETAIL_ORDERS_MESSAGING_RABBITMQ_USERNAME=$RABBITMQ_USERNAME \
--set-string env.RETAIL_ORDERS_MESSAGING_RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD 


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

echo "==============================="
echo "Waiting for ALB to be provisioned..."

ALB_DNS=""
while [ -z "$ALB_DNS" ]; do
  ALB_DNS=$(kubectl get ingress frontend-ingress -n $NAMESPACE \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
  if [ -z "$ALB_DNS" ]; then
    echo "ALB not ready yet, waiting 10 seconds..."
    sleep 10
  fi
done

echo "ALB DNS for frontend: $ALB_DNS"
echo "================================"