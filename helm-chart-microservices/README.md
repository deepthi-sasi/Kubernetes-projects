## Demo Project - Create Helm Chart for Microservices

### Topics of the Demo Project
Create a Helm Chart for the Online-Shop Microservices

### Technologies Used
- Kubernetes
- Helm
- Helmfile

### Project Description
- Create 1 shared Helm Chart for all microservices, to reuse common Deployment and Service configurations for the services

#### Steps to create 1 shared Helm Chart for all microservices
We will create one Helm Chart for all the online-shop microservices except for the redis cart microservice, for which we create a separate chart.

**Step 1:** Create the directory structure
```sh
mkdir -p charts

helm create charts/microservice
rm -r charts/microservice/templates/*.*
rm -rf charts/microservice/templates/tests
echo '' > charts/microservice/values.yaml

helm create charts/redis
rm -r charts/redis/templates/*.*
rm -rf charts/redis/templates/tests
echo '' > charts/redis/values.yaml
```

**Step 2:** Create a template file for the Deployments of the shop microservices\
Create a file `charts/microservice/templates/deployment.yaml` with the following content:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}
spec:
  replicas: {{ .Values.appReplicas }}
  selector:
    matchLabels:
      app: {{ .Values.appName }}
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
    spec:
      containers:
        - name: {{ .Values.appName }}
          image: "{{ .Values.appImage }}:{{ .Values.appVersion }}"
          ports:
            - containerPort: {{ .Values.containerPort }}
          env:
          {{- range .Values.containerEnvVars}}
          - name: {{ .name }}
            value: {{ .value | quote }}
          {{- end}}
```

**Step 3:** Create a template file for the Services of the shop microservices\
Create a file `charts/microservice/templates/service.yaml` with the following content:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.appName }}
spec:
  type: {{ .Values.serviceType }}
  selector:
    app: {{ .Values.appName }}
  ports:
    - protocol: TCP
      port: {{ .Values.servicePort }}
      targetPort: {{ .Values.containerPort }}
```

**Step 4:** Create a values file containing the default values for the microservices\
Create a file `charts/microservice/values.yaml` with the following content:
```yaml
appName: servicename
appImage: gcr.io/google-samples/microservices-demo/servicename
appVersion: v0.0.0
appReplicas: 1
containerPort: 8080
containerEnvVars: 
- name: ENV_VAR_ONE
  value: "valueone"
- name: ENV_VAR_TWO
  value: "valuetwo"
servicePort: 8080
serviceType: ClusterIP
```

**Step 5:** Create a service-specific values file for the emailservice\
We are going to override the default values for each individual microservice. Let's do it for the first microservice, the emailservice. Create an `appvalues/email-service.yaml` file with the following content:
```yaml
appName: emailservice
appImage: gcr.io/google-samples/microservices-demo/emailservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 8080
containerEnvVars: 
- name: PORT
  value: "8080"
- name: PRODUCT_CATALOG_SERVICE_ADDR
  value: "productcatalogservice:3550"
servicePort: 8000
```

**Step 6:** Check the correctness of the template\
Let's check whether the first microservice configuration files will be generated correctly. Execute the following command from the `helm-chart-microservices` directory:
```sh
helm template -f appvalues/email-service.yaml charts/microservice
```

This command won't create any files. It just prints out what would be sent to Kubernetes when `helm install` would be executed.

There is also a `helm lint` command that examines a chart for possible issues:
```sh
helm lint -f appvalues/email-service.yaml charts/microservice
# ==> Linting charts/microservice
# [INFO] Chart.yaml: icon is recommended

# 1 chart(s) linted, 0 chart(s) failed
```

**Step 7:** Create service-specific values files for all the other microservices\
Create the following files inside the `appvalues/` folder:

_cartservice.yaml_
```yaml
appName: cartservice
appImage: gcr.io/google-samples/microservices-demo/cartservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 7070
containerEnvVars: 
- name: PORT
  value: "7070"
- name: REDIS_ADDR
  value: "redis-cart:6379"

servicePort: 7070
```

_currencyservice.yaml_
```yaml
appName: currencyservice
appImage: gcr.io/google-samples/microservices-demo/currencyservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 7000
containerEnvVars: 
 - name: PORT
   value: "7000"
 - name: DISABLE_PROFILER
   value: "1"

servicePort: 7000
```

_paymentservice.yaml_
```yaml
appName: paymentservice
appImage: gcr.io/google-samples/microservices-demo/paymentservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 50051
containerEnvVars: 
- name: PORT
  value: "50051"
servicePort: 50051
```

_recommendationservice.yaml_
```yaml
appName: recommendationservice
appImage: gcr.io/google-samples/microservices-demo/recommendationservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 8080
containerEnvVars: 
- name: PORT
  value: "8080"
- name: PRODUCT_CATALOG_SERVICE_ADDR
  value: "productcatalogservice:3550"
servicePort: 8080
```

_productcatalogservice.yaml_
```yaml
appName: productcatalogservice
appImage: gcr.io/google-samples/microservices-demo/productcatalogservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 3550
containerEnvVars: 
- name: PORT
  value: "3550"
servicePort: 3550
```

_shippingservice.yaml_
```yaml
appName: shippingservice
appImage: gcr.io/google-samples/microservices-demo/shippingservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 50051
containerEnvVars: 
- name: PORT
  value: "50051"

servicePort: 50051
```

_adservice.yaml_
```yaml
appName: adservice
appImage: gcr.io/google-samples/microservices-demo/adservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 9555
containerEnvVars: 
- name: PORT
  value: "9555"

servicePort: 9555
```

_checkoutservice.yaml_
```yaml
appName: checkoutservice
appImage: gcr.io/google-samples/microservices-demo/checkoutservice
appVersion: v0.8.0
appReplicas: 2
containerPort: 5050
containerEnvVars: 
  - name: PORT
    value: "5050"
  - name: PRODUCT_CATALOG_SERVICE_ADDR   
    value: "productcatalogservice:3550"
  - name: SHIPPING_SERVICE_ADDR
    value: "shippingservice:50051"
  - name: PAYMENT_SERVICE_ADDR
    value: "paymentservice:50051"    
  - name: EMAIL_SERVICE_ADDR
    value: "emailservice:5000"
  - name: CURRENCY_SERVICE_ADDR
    value: "currencyservice:7000"
  - name: CART_SERVICE_ADDR
    value: "cartservice:7070"

servicePort: 5050
```

_frontend.yaml_
```yaml
appName: frontend
appImage: gcr.io/google-samples/microservices-demo/frontend
appVersion: v0.8.0
appReplicas: 2
containerPort: 8080
containerEnvVars: 
- name: PORT
  value: "8080"
- name: PRODUCT_CATALOG_SERVICE_ADDR
  value: "productcatalogservice:3550"
- name: CURRENCY_SERVICE_ADDR
  value: "currencyservice:7000"
- name: CART_SERVICE_ADDR
  value: "cartservice:7070"
- name: RECOMMENDATION_SERVICE_ADDR
  value: "recommendationservice:8080"
- name: SHIPPING_SERVICE_ADDR
  value: "shippingservice:50051"
- name: CHECKOUT_SERVICE_ADDR
  value: "checkoutservice:5050"
- name: AD_SERVICE_ADDR
  value: "adservice:9555"

servicePort: 80
serviceType: LoadBalancer
```

**Step 8:** Create template files for the Deployment and Service of the redis microservice\
Create a file `charts/redis/templates/deployment.yaml` with the following content:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}
spec:
  replicas: {{ .Values.appReplicas }}
  selector:
    matchLabels:
      app: {{ .Values.appName }}
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
    spec:
      containers:
      - name: {{ .Values.appName }}
        image: "{{ .Values.appImage }}:{{ .Values.appVersion }}"
        ports:
        - containerPort: {{ .Values.containerPort }}
        livenessProbe:
          initialDelaySeconds: 5
          tcpSocket:
            port: {{ .Values.containerPort }}
          periodSeconds: 5
        readinessProbe:
          initialDelaySeconds: 5
          tcpSocket:
            port: {{ .Values.containerPort }}
          periodSeconds: 5
        resources:
          requests: 
            cpu: 70m
            memory: 200Mi
          limits:
            cpu: 125m
            memory: 300Mi
        volumeMounts:
        - name: {{ .Values.volumeName }}
          mountPath: {{ .Values.containerMountPath }}
      volumes:
      - name: {{ .Values.volumeName }}
        emptyDir: {}
```

Create a file `charts/redis/templates/service.yaml` with the following content:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.appName }}
spec:
  type: ClusterIP
  selector:
    app: {{ .Values.appName }}
  ports:
  - protocol: TCP
    port: {{ .Values.servicePort }}
    targetPort: {{ .Values.containerPort }}
```

**Step 9:** Create a values file containing the default values for the redis microservice\
Create a file `charts/redis/values.yaml` with the following content:
```yaml
appName: redis
appImage: redis
appVersion: alpine
appReplicas: 1
containerPort: 6379
volumeName: redis-data
containerMountPath: /data

servicePort: 6379
```

**Step 10:** Create a service-specific values file for the redis cart\
Create an `appvalues/redis-values.yaml` file with the following content:
```yaml
appName: redis-cart
appReplicas: 2
```

**Step 11:** Check the correctness of the template\
Let's check whether the redis configuration files will be generated correctly:
```sh
helm template -f appvalues/redis-values.yaml charts/redis
```

**Step 12:** Deploy all services using Helmfile\
Create a `helmfile.yaml` to manage all releases declaratively:
```yaml
releases: 
  - name: rediscart
    chart: charts/redis
    values: 
      - appvalues/redis-values.yaml
      - appReplicas: "1"
      - volumeName: "redis-cart-data"

  - name: emailservice
    chart: charts/microservice
    values:
      - appvalues/email-service.yaml

  - name: cartservice
    chart: charts/microservice
    values:
      - appvalues/cartservice.yaml

  - name: currencyservice
    chart: charts/microservice
    values:
      - appvalues/currencyservice.yaml   

  - name: paymentservice
    chart: charts/microservice
    values:
      - appvalues/paymentservice.yaml

  - name: recommendationservice
    chart: charts/microservice
    values:
      - appvalues/recommendationservice.yaml

  - name: productcatalogservice
    chart: charts/microservice
    values:
      - appvalues/productcatalogservice.yaml

  - name: shippingservice
    chart: charts/microservice
    values:
      - appvalues/shippingservice.yaml

  - name: adservice
    chart: charts/microservice
    values:
      - appvalues/adservice.yaml

  - name: checkoutservice
    chart: charts/microservice
    values:
      - appvalues/checkoutservice.yaml

  - name: frontendservice
    chart: charts/microservice
    values:
      - appvalues/frontend.yaml
```

Deploy all releases at once:
```sh
helmfile sync
```

Alternatively, use the provided scripts to install or uninstall all services individually:
```sh
# Install all services
bash install.sh

# Uninstall all services
bash uninstall.sh
```
