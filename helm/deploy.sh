#! /bin/bash

aws eks update-kubeconfig \
--name project-bedrock-cluster \
--region us-east-1

aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

kubectl create namespace retail-app

helm upgrade --install redis ./redis -n retail-app

echo "================================"

helm upgrade --install dynamodb ./dynamodb -n retail-app

echo "================================"

helm upgrade --install rabbitmq ./rabbitmq -n retail-app \
--set auth.username=bedrockuser \
--set auth.password=bedrockpass

echo "================================"

helm upgrade --install frontend \
oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart \
--version 1.4.0 \
--namespace retail-app \
-f ./ms-values/frontend-values.yaml

echo "================================"

helm upgrade --install catalog   \
oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart  \
--version 1.4.0   \
--namespace retail-app \
-f ./ms-values/catalog-values.yaml \
--set-string env[4].value=bedrockuser \
--set-string env[5].value=bedrockpasskey.8305

echo "================================"

helm upgrade --install cart \
oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart  \
--version 1.4.0   \
--namespace retail-app \
-f ./ms-values/cart-values.yaml

echo "================================"

helm upgrade --install orders \
oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart  \
--version 1.4.0   \
--namespace retail-app \
-f ./ms-values/orders-values.yaml \
--set-string env[4].value=bedrockuser \
--set-string env[5].value=bedrockpasskey.8305 \
--set-string env[9].value=bedrockuser \
--set-string env[10].value=bedrockpass 


echo "================================"

helm upgrade --install checkout  \
oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart \
--version 1.4.0 \
--namespace retail-app \
-f ./ms-values/checkout-values.yaml 

echo "================================"

sleep 60

kubectl get pods -n retail-app

echo "================================"

kubectl get pvc -n retail-app

echo "================================"

kubectl get svc -n retail-app
