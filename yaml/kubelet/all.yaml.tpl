apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: "kubelet"
  labels:
    k8s-app: "kubelet"
    stage: "all"
    class: "all"
  namespace: "prometheus"
spec:
  jobLabel: k8s-app
  endpoints:
  - port: https-metrics
    scheme: https
    interval: ${INTERVAL_TIME}
    tlsConfig:
      insecureSkipVerify: true
    bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
  - port: https-metrics
    scheme: https
    path: /metrics/cadvisor
    interval: ${INTERVAL_TIME}
    honorLabels: true
    tlsConfig:
      insecureSkipVerify: true
    bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
  selector:
    matchLabels:
      k8s-app: kubelet
  namespaceSelector:
    matchNames:
    - kube-system
