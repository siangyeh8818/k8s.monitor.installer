---
apiVersion: v1
kind: Service
metadata:
  name: kafka-metrics-svc
  namespace: ${NS_KAFKA}
  labels:
    app: kafka-metrics-svc
spec:
  ports:
  - port: 7072
    protocol: TCP
    targetPort: 7072
  selector:
    app: kafka
---
apiVersion: v1
kind: Service
metadata:
  name: kafka-exporter
  namespace: prometheus
  labels:
    app: kafka-exporter
spec:
  ports:
    - port: 9308
      protocol: TCP
      targetPort: 9308
  selector:
    app: kafka-exporter
---
apiVersion: v1
kind: Service
metadata:
  name: zk-metrics-svc
  namespace: ${NS_KAFKA}
  labels:
    app: zk-svc
spec:
  ports:
  - port: 2181
    targetPort: 2181
  selector:
    app: zk
---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper-exporter
  namespace: prometheus
  labels:
    app: zookeeper-exporter
spec:
  ports:
    - port: 9141
      protocol: TCP
      targetPort: 9141
  selector:
    app: zookeeper-exporter
