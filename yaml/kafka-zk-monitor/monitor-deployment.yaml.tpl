---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: zookeeper-exporter
  namespace: prometheus
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: zookeeper-exporter
    spec:
      containers:
      - name: zookeeper-exporter
        image: carlpett/zookeeper_exporter:v1.0.2 
        command:
          - "/zookeeper_exporter"
          - "-zookeeper"
          - "zk-metrics-svc.${NS_KAFKA}:2181"
        imagePullPolicy: Always
        ports:
        - containerPort: 9141
          protocol: TCP
        volumeMounts:
        - mountPath: /etc/localtime
          name: time
      volumes:
        - name: time
          hostPath:
            path: /etc/localtime
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: kafka-exporter
  namespace: prometheus
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: kafka-exporter
    spec:
      containers:
      - name: kafka-exporter
        image: danielqsj/kafka-exporter
        args: ["--kafka.server=kafka-svc.${NS_KAFKA}:9092"]
        imagePullPolicy: Always
        ports:
        - containerPort: 9308
          protocol: TCP
        volumeMounts:
        - mountPath: /etc/localtime
          name: time
      volumes:
        - name: time
          hostPath:
            path: /etc/localtime
