apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-exporter
rules:
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - list
  - watch
- apiGroups:
  - authentication.k8s.io
  resources:
  - tokenreviews
  verbs:
  - create
- apiGroups:
  - authorization.k8s.io
  resources:
  - subjectaccessreviews
  verbs:
  - create
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: node-exporter
  namespace: prometheus
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-exporter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: node-exporter
subjects:
- kind: ServiceAccount
  name: node-exporter
  namespace: prometheus
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: "node-exporter"
    k8s-app: "node-exporter"
    monitor: "on"
    class: "system"
  name: "node-exporter"
  namespace: "prometheus"
spec:
  type: ClusterIP
  clusterIP: None
  ports:
  - name: http
    port: 9100
    protocol: TCP
  selector:
    app: node-exporter
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: prometheus
spec:
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: node-exporter
      name: node-exporter
    spec:
      serviceAccountName: node-exporter
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      hostNetwork: true
      hostPID: true
      containers:
      - image: quay.io/prometheus/node-exporter:v0.17.0
        args:
        - "--web.listen-address=0.0.0.0:9100"
        - "--path.procfs=/host/proc"
        - "--path.sysfs=/host/sys"
        - "--collector.processes"
        name: node-exporter
        resources:
          requests:
            memory: 30Mi
            cpu: 100m
          limits:
            memory: 100Mi
            cpu: 200m
        volumeMounts:
        - name: proc
          readOnly:  true
          mountPath: /host/proc
        - name: sys
          readOnly: true
          mountPath: /host/sys
      tolerations:
        - effect: NoExecute
          operator: Exists
        - effect: NoSchedule
          operator: Exists
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: "node-exporter"
  namespace: "prometheus"
  labels:
    k8s-app: "node-exporter"
    stage: "all"
    class: "system"
spec:
  jobLabel: k8s-app
  selector:
    matchLabels:
      k8s-app: node-exporter
  namespaceSelector:
    matchNames:
    - prometheus
  endpoints:
  - port: http
    scheme: http
    interval: ${INTERVAL_TIME}
