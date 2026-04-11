helm install -f values/redis-values.yaml rediscart charts/redis

helm install -f values/email-service.yaml emailservice charts/microservice
helm install -f values/cartservice.yaml cartservice charts/microservice
helm install -f values/currencyservice.yaml currencyservice charts/microservice
helm install -f values/paymentservice.yaml paymentservice charts/microservice
helm install -f values/recommendationservice.yaml recommendationservice charts/microservice
helm install -f values/productcatalogservice.yaml productcatalogservice charts/microservice
helm install -f values/shippingservice.yaml shippingservice charts/microservice
helm install -f values/adservice.yaml adservice charts/microservice
helm install -f values/checkoutservice.yaml checkoutservice charts/microservice
helm install -f values/frontend.yaml frontendservice charts/microservice