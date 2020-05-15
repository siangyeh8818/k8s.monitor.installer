---
kind: Service
apiVersion: v1
metadata:
  name: neo4j-relay
  namespace: ${NS_DEFAULT}
  labels:
    app: neo4j-relay
spec:
  type: ClusterIP
  ports:
  - name: metrics
    port: 9091
    targetPort: 2004
  selector:
    app: neo4j
    component: core
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "neo4j-metrics"
    stage: "all"
    class: "all"
  name: "neo4j-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - port: metrics
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_DEFAULT}
  selector:
    matchLabels:
      app: neo4j-relay
