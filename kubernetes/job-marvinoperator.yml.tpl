apiVersion: v1
kind: ConfigMap
metadata:
  namespace: ${NS_DEFAULT}
  name: env-monitor-installer
data:
  NS_DEFAULT: __NS_DEFAULT__
  NS_FAAS_INFRA: __NS_FAAS_INFRA__
  NS_OPENFAAS_FN: __NS_OPENFAAS_FN__
  NS_KAFKA: __NS_KAFKA__
  NS_FLUENTD: __NS_FLUENTD__
  INTERVAL_TIME: 15s
  RETENTION: __RETENTION__
  MONITOR_IP: __MONITOR_IP__
  CHECK: "true"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kb
  namespace: ${NS_DEFAULT}
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: batch/v1
kind: Job
metadata:
  labels:
    job-name: k8s-monitor-installer
  name: k8s-monitor-installer
  namespace: ${NS_DEFAULT}
spec:
  backoffLimit: 3
  template:
    metadata:
      labels:
        job-name: k8s-monitor-installer
    spec:
      containers:
        - image: cr-preview.pentium.network/k8s-monitor-installer:latest
          imagePullPolicy: Always
          name: k8s-monitor-installer
          envFrom:
            - configMapRef:
                name: env-monitor-installer
          volumeMounts:
            - mountPath: /etc/localtime
              name: hosttime
            - mountPath: /cache
              name: cache-volume
          stdin: true
          tty: true
          securityContext:
            privileged: true
            capabilities:
              add:
                - NET_ADMIN
          ports:
            - containerPort: 8000
      restartPolicy: Never
      serviceAccountName: kb
      volumes:
        - name: hosttime
          hostPath:
            path: /etc/localtime
        - name: cache-volume
          emptyDir: {}
---
#apiVersion: v1
#kind: Service
#metadata:
#  name: monitor-operator
#  namespace: marvin
#  labels:
#    app: monitor-operator
#spec:
#  type: NodePort
#  ports:
#  - name: http
#    protocol: TCP
#port is loadbalancer port
#targetport is container port
#nodePort is external accessing from any given k8s cluster ip
#    port: 8001
#    targetPort: 8000
#    nodePort: 31803
#  selector:
#    app: marvin-operator
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: Reconcile
  name: system:kb
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: EnsureExists
  name: system:kb
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kb
subjects:
  - kind: ServiceAccount
    name: kb
    namespace: ${NS_DEFAULT}
---

