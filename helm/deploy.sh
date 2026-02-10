#! /bin/bash

aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws

helm upgrade --install frontend   oci://public.ecr.aws/aws-containers/retail-store-sample-ui-chart   --version 1.4.0   --namespace retail-app -f ./ms-values/frontend-values.aml

helm upgrade --install catalog   oci://public.ecr.aws/aws-containers/retail-store-sample-catalog-chart  --version 1.4.0   --namespace retail-app -f ./ms-values/catalog-values.yaml

helm upgrade --install cart  oci://public.ecr.aws/aws-containers/retail-store-sample-cart-chart  --version 1.4.0   --namespace retail-app -f ./ms-values/cart-values.yaml

helm upgrade --install orders   oci://public.ecr.aws/aws-containers/retail-store-sample-orders-chart  --version 1.4.0   --namespace retail-app -f ./ms-values/orders-values.yaml

helm upgrade --install checkout  oci://public.ecr.aws/aws-containers/retail-store-sample-checkout-chart   --version 1.4.0   --namespace retail-app -f ./ms-values/checkout-values.yaml


helm upgrade --install mysql ./mysql -n retail-app

helm upgrade --install postgresql ./postgresql -n retail-app

helm upgrade --install redis ./redis -n retail-app


kubectl get pods -n retail-app

kubectl get pvc -n retail-app

kubectl get svc -n retail-app
