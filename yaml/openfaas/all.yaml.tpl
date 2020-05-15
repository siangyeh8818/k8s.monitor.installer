---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "openfaas-gateway-metrics"
    stage: "all"
    class: "all"
  name: "openfaas-gateway-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - port: metrics
    interval: ${INTERVAL_TIME}
  namespaceSelector:
    matchNames:
    - ${NS_FAAS_INFRA}
  selector:
    matchLabels:
      app: gateway-metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "openfaas-gateway-dmmt-metrics"
    stage: "all"
    class: "all"
  name: "openfaas-gateway-dmmt-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - port: metrics
    interval: ${INTERVAL_TIME}
  namespaceSelector:
    matchNames:
    - ${NS_FAAS_INFRA}
  selector:
    matchLabels:
      app: gateway-dmmt-metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "openfaas-gateway-runner-metrics"
    stage: "all"
    class: "all"
  name: "openfaas-gateway-runner-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - port: metrics
    interval: ${INTERVAL_TIME}
  namespaceSelector:
    matchNames:
    - ${NS_FAAS_INFRA}
  selector:
    matchLabels:
      app: gateway-runner-metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "openfaas-nats-metrics"
    stage: "all"
    class: "all"
  name: "openfaas-nats-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 8081
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_FAAS_INFRA}
  selector:
    matchLabels:
      app: nats-exporter
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "openfaas-nats-dmmt-metrics"
    stage: "all"
    class: "all"
  name: "openfaas-nats-dmmt-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 8081
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_FAAS_INFRA}
  selector:
    matchLabels:
      app: nats-dmmt-exporter
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "openfaas-nats-runner-metrics"
    stage: "all"
    class: "all"
  name: "openfaas-nats-runner-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 8081
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_FAAS_INFRA}
  selector:
    matchLabels:
      app: nats-runner-exporter    
