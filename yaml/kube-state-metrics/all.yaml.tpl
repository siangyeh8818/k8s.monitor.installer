---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kube-state-metrics
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  - nodes
  - pods
  - services
  - resourcequotas
  - replicationcontrollers
  - limitranges
  - persistentvolumeclaims
  - persistentvolumes
  - namespaces
  - endpoints
  verbs:
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - deployments
  - replicasets
  verbs:
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - statefulsets
  verbs:
  - list
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - jobs
  verbs:
  - list
  - watch
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
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
  name: kube-state-metrics
  namespace: prometheus
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kube-state-metrics
  namespace: prometheus
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - extensions
  resourceNames:
  - kube-state-metrics
  resources:
  - deployments
  verbs:
  - get
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube-state-metrics
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kube-state-metrics
subjects:
- kind: ServiceAccount
  name: kube-state-metrics
  namespace: prometheus
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kube-state-metrics
  namespace: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kube-state-metrics
subjects:
- kind: ServiceAccount
  name: kube-state-metrics
---
apiVersion: v1
kind: Service
metadata:
  labels:
    monitor: "on"
    class: "system"
    k8s-app: "kube-state-metrics"
  name: "kube-state-metrics"
  namespace: "prometheus"
spec:
  ports:
  - name: https-main
    port: 8443
    targetPort: https-main
  - name: https-self
    port: 9443
    targetPort: https-self
  selector:
    app: kube-state-metrics
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  labels:
    app: kube-state-metrics
  name: kube-state-metrics
  namespace: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kube-state-metrics
  template:
    metadata:
      labels:
        app: kube-state-metrics
    spec:
      containers:
      - args:
        - --secure-listen-address=:8443
        - --upstream=http://127.0.0.1:8081/
        image: quay.io/coreos/kube-rbac-proxy:v0.4.0
        name: kube-rbac-proxy-main
        ports:
        - containerPort: 8443
          name: https-main
        resources:
          limits:
            cpu: 20m
            memory: 40Mi
          requests:
            cpu: 10m
            memory: 20Mi
      - args:
        - --secure-listen-address=:9443
        - --upstream=http://127.0.0.1:8082/
        image: quay.io/coreos/kube-rbac-proxy:v0.4.0
        name: kube-rbac-proxy-self
        ports:
        - containerPort: 9443
          name: https-self
        resources:
          limits:
            cpu: 20m
            memory: 40Mi
          requests:
            cpu: 10m
            memory: 20Mi
      - args:
        - --host=127.0.0.1
        - --port=8081
        - --telemetry-host=127.0.0.1
        - --telemetry-port=8082
        image: quay.io/coreos/kube-state-metrics:v1.4.0
        name: kube-state-metrics
        resources:
          limits:
            cpu: 100m
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
      - command:
        - /pod_nanny
        - --container=kube-state-metrics
        - --cpu=100m
        - --extra-cpu=50m
        - --memory=150Mi
        - --extra-memory=30Mi
        - --threshold=5
        - --deployment=kube-state-metrics
        env:
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.name
        - name: MY_POD_NAMESPACE
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
        image: quay.io/coreos/addon-resizer:1.0
        name: addon-resizer
        resources:
          limits:
            cpu: 10m
            memory: 30Mi
          requests:
            cpu: 10m
            memory: 30Mi
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: kube-state-metrics
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "kube-state-metrics"
    stage: "all"
    class: "all"
  name: "kube-state-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    honorLabels: true
    interval: ${INTERVAL_TIME}
    port: https-main
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
  - bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
    interval: ${INTERVAL_TIME}
    port: https-self
    scheme: https
    tlsConfig:
      insecureSkipVerify: true
  jobLabel: k8s-app
  namespaceSelector:
    matchNames:
    - prometheus
  selector:
    matchLabels:
      k8s-app: kube-state-metrics
