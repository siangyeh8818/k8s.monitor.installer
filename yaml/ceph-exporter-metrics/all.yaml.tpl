---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: ceph-exporter
  namespace: prometheus
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: ceph-exporter
      name: ceph-exporter
    spec:
      containers:
      - name: ceph-exporter
        image: siangyeh8818/rook_ceph_exporter:1.0
        imagePullPolicy: Always
        command:
        - "/bin/ceph_exporter"
        - "--ceph.config"
        - "/var/lib/rook/rook-ceph/rook-ceph.config"
        ports:
        - name: http-metrics
          containerPort: 9128
          protocol: TCP
        volumeMounts:
        - mountPath: /etc/localtime
          name: localtime
          readOnly: true
        - mountPath: /var/lib/rook/rook-ceph/
          name: ceph-cfg
          readOnly: true
      volumes:
      - name: localtime
        hostPath:
          path: /etc/localtime
      - name: ceph-cfg
        hostPath:
          path: /opt/rook/rook-ceph
      nodeSelector:
        ceph-mgr: enabled
      tolerations:
      - effect: NoExecute
        key: dedicated
        operator: Equal
        value: storage-node
---
apiVersion: v1
kind: Service
metadata:
  name: ceph-exporter
  namespace: prometheus
  labels:
    k8s-app: ceph-exporter
spec:
  selector:
    app: ceph-exporter
  ports:
  - name: http-metrics
    port: 9128
    targetPort: 9128
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "ceph-exporter-metrics"
    stage: "all"
    class: "all"
  name: "ceph-exporter-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 9128
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - prometheus
  selector:
    matchLabels:
      k8s-app: ceph-exporter
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: "ceph-mgr-metrics"
    stage: "all"
    class: "all"
  name: "ceph-mgr-metrics"
  namespace: "prometheus"
spec:
  endpoints:
  - targetPort: 9283
    honorLabels: true
    interval: ${INTERVAL_TIME}
    scheme: http
  namespaceSelector:
    matchNames:
    - rook-ceph
  selector:
    matchLabels:
      app: rook-ceph-mgr
