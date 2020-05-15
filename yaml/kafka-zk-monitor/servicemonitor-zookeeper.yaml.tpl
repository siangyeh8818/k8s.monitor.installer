---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "zookeeper-exporter-metrics"
    stage: "all"
    class: "all"
  name: "zookeeper-exporter-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 9141
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - prometheus
  selector:
    matchLabels:
      app: zookeeper-exporter
