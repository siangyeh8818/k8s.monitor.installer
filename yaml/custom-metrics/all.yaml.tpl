---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "domainmanagement-metrics"
    stage: "all"
    class: "all"
  name: "domainmanagement-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 8000
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_OPENFAAS_FN}
  selector:
    matchLabels:
      app: domainmanagement-metrics
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: router-metrics
  name: router-metrics
  namespace: ${NS_DEFAULT}
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 3000
  selector:
    app: router
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "marvin-exporter-metrics"
    stage: "all"
    class: "all"
  name: "marvin-exporter-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 9987
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_DEFAULT}
  selector:
    matchLabels:
      app: marvin-exporter
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "marvin-router-metrics"
    stage: "all"
    class: "all"
  name: "marvin-router-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 3000
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - ${NS_DEFAULT}
  selector:
    matchLabels:
      app: router-metrics
---
apiVersion: v1
kind: Service
metadata:
  name: marvin-exporter
  namespace: ${NS_DEFAULT}
  labels:
    app: marvin-exporter
spec:
  ports:
  - port: 9987
    protocol: TCP
    targetPort: 9987
  selector:
    app: marvin-exporter
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: marvin-exporter
  namespace: ${NS_DEFAULT}
spec:
  replicas: 1
  minReadySeconds: 15
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: marvin-exporter
    spec:
      containers:
      - name: marvin-exporter
        image: cr.pentium.network/marvin-exporter:f74508b
        imagePullPolicy: Always
        env:
          - name: PATH_CONFIG
            value: /var/openfaas/secrets/config.json
          - name: MY_POD_NAMESPACE
            value: ${NS_DEFAULT}
        ports:
        - containerPort: 9987
          protocol: TCP
        volumeMounts:
        - mountPath: /var/openfaas/secrets
          name: marvin-secrets
          readOnly: true
      serviceAccountName: marvin-exporter
      volumes:
      - name: marvin-secrets
        projected:
          defaultMode: 420
          sources:
          - secret:
              items:
              - key: config.json
                path: config.json
              name: pn-config
---
apiVersion: v1
kind: Service
metadata:
  name: nats-exporter
  namespace: ${NS_FAAS_INFRA}
  labels:
    app: nats-exporter
spec:
  ports:
  - port: 8081
    protocol: TCP
    targetPort: 8081
  selector:
    app: nats-exporter
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nats-exporter
  namespace: ${NS_FAAS_INFRA}
spec:
  replicas: 1
  minReadySeconds: 15
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: nats-exporter
    spec:
      containers:
      - name: nats-exporter
        image: cr.pentium.network/nats-exporter:f74508b
        imagePullPolicy: Always
        ports:
        - containerPort: 8081
          protocol: TCP
        env:
        - name: NATS_IP
          value: "nats.${NS_FAAS_INFRA}"
        - name: NATS_PORT
          value: "8222"
---
apiVersion: v1
kind: Service
metadata:
  name: nats-dmmt-exporter
  namespace: ${NS_FAAS_INFRA}
  labels:
    app: nats-dmmt-exporter
spec:
  ports:
  - port: 8081
    protocol: TCP
    targetPort: 8081
  selector:
    app: nats-dmmt-exporter
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nats-dmmt-exporter
  namespace: ${NS_FAAS_INFRA}
spec:
  replicas: 1
  minReadySeconds: 15
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: nats-dmmt-exporter
    spec:
      containers:
      - name: nats-dmmt-exporter
        image: cr.pentium.network/nats-exporter:be74066-dirty
        imagePullPolicy: Always
        ports:
        - containerPort: 8081
          protocol: TCP
        env:
        - name: NATS_IP
          value: "nats-dmmt.${NS_FAAS_INFRA}"
        - name: NATS_PORT
          value: "8222"
---
apiVersion: v1
kind: Service
metadata:
  name: nats-runner-exporter
  namespace: ${NS_FAAS_INFRA}
  labels:
    app: nats-runner-exporter
spec:
  ports:
  - port: 8081
    protocol: TCP
    targetPort: 8081
  selector:
    app: nats-runner-exporter
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nats-runner-exporter
  namespace: ${NS_FAAS_INFRA}
spec:
  replicas: 1
  minReadySeconds: 15
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: nats-runner-exporter
    spec:
      containers:
      - name: nats-runner-exporter
        image: cr.pentium.network/nats-exporter:be74066-dirty
        imagePullPolicy: Always
        ports:
        - containerPort: 8081
          protocol: TCP
        env:
        - name: NATS_IP
          value: "nats-runner.${NS_FAAS_INFRA}"
        - name: NATS_PORT
          value: "8222"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: marvin-exporter
  namespace: ${NS_DEFAULT}
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - list
  - delete
- apiGroups:
  - ""
  resources:
  - services
  - endpoints
  verbs:
  - get
  - create
  - update
  - list
- apiGroups:
  - "batch"
  resources:
  - cronjobs
  - cronjobs/status
  verbs:
  - get
  - create
  - update
  - list
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["product-info"]
  verbs: ["update", "get"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: marvin-exporter
  namespace: ${NS_DEFAULT}
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: marvin-exporter
  namespace: ${NS_DEFAULT}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: marvin-exporter
subjects:
- kind: ServiceAccount
  name: marvin-exporter
  namespace: ${NS_DEFAULT}
