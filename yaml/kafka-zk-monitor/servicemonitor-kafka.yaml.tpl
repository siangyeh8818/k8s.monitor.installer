---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "kafka-exporter-metrics"
    stage: "all"
    class: "all"
  name: "kafka-exporter-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 9308
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - prometheus
  selector:
    matchLabels:
      app: kafka-exporter
---
apiVersion: v1
kind: Service
metadata:
  name: kafka-svc-metrics
  namespace: ${NS_KAFKA}
  labels:
    app: kafka-svc-metrics
spec:
  ports:
  - port: 7072
    name: kafka-port
    protocol: TCP
    targetPort: 7072
  selector:
    app: kafka
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "kafka-svc-metrics"
    stage: "all"
    class: "all"
  name: "kafka-svc-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - port: kafka-port
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_KAFKA}
  selector:
    matchLabels:
      app: kafka-svc-metrics
