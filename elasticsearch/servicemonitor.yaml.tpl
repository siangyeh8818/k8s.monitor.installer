---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-exporter
  namespace: ${NS_DEFAULT}
  labels:
    app: elasticsearch-exporter
spec:
  ports:
    - name: es-port
      port: 9108
      protocol: TCP
      targetPort: 9108
  selector:
    app: elasticsearch-exporter
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "elasticsearch-exporter-metrics"
    stage: "all"
    class: "all"
  name: "elasticsearch-exporter-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - port: es-port
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_DEFAULT}
  selector:
    matchLabels:
      app: elasticsearch-exporter
