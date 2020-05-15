---
apiVersion: v1
kind: Service
metadata:
  labels:
    monitor: "on"
    class: "system"
    k8s-app: "fluentd-logging"
  name: fluentd-monitor
  namespace: ${NS_FLUENTD}
spec:
  ports:
  - name: transport
    port: 34224
    protocol: TCP
    targetPort: 24224
  - name: monitorworker1
    port: 24231
    protocol: TCP
    targetPort: 24231
  - name: monitorworker2
    port: 24232
    protocol: TCP
    targetPort: 24232
  - name: monitorworker3
    port: 24233
    protocol: TCP
    targetPort: 24233
  selector:
    app: fluentd
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    class: all
    k8s-app: fluentd-workflow-preview
    stage: all
  name: fluentd-workflow-preview
  namespace: prometheus
spec:
  endpoints:
  - interval: ${INTERVAL_TIME}
    port: monitorworker1
    scheme: http
  - interval: ${INTERVAL_TIME}
    port: monitorworker2
    scheme: http
  - interval: ${INTERVAL_TIME}
    port: monitorworker3
    scheme: http
  jobLabel: k8s-app
  namespaceSelector:
    matchNames:
    - ${NS_FLUENTD}
  selector:
    matchLabels:
      k8s-app: fluentd-logging
