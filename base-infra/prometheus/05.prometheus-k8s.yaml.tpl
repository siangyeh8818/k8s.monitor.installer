apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: k8s
  namespace: prometheus
spec:
  serviceMonitorSelector:
    matchExpressions:
    - key: class
      operator: In
      values:
      - system
      - all
  alerting:
    alertmanagers:
      - name: alertmanager-openfaas
        namespace: openfaas
        port: web
  ruleSelector:
    matchLabels:
      role: alert-rules
  serviceAccountName: prometheus-k8s
  retention: ${RETENTION}
  resources:
    requests:
      memory: 400Mi
  tolerations:
    - key: dedicated
      value: monitor
      effect: NoExecute
  storage:
    volumeClaimTemplate:
      spec:
        resources:
          requests:
            storage: 200Gi
        storageClassName: rook-ceph-block
