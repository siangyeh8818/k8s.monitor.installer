apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: grafana
  namespace: ${NS_DEFAULT}
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: cr.pentium.network/grafana:dbfa6f2.20200421105138
        imagePullPolicy: Always
        env:
        - name: IP_PROMETHEUS
          value: "k8s.prometheus"
        - name: PORT_PROMETHEUS
          value: "9090"
        ports:
        - containerPort: 3000
          protocol: TCP
        volumeMounts:
        - mountPath: /etc/localtime
          name: time
        - mountPath: /var/lib/grafana
          name: grafana-data
        - mountPath: /opt/config/json
          name: pn-config
      tolerations:
        - key: dedicated
          value: monitor
          effect: NoExecute
#      nodeSelector:
#        kubernetes.io/hostname: "monitor"
      volumes:
        - hostPath:
            path: /etc/localtime
          name: time
        - hostPath:
            path: /opt/grafana/data
          name: grafana-data
        - name: pn-config
          secret:
            defaultMode: 420
            secretName: pn-config
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: ${NS_DEFAULT}
  labels:
    app: grafana
spec:
  type: NodePort
  ports:
    - port: 3000
      protocol: TCP
  externalIPs:
    - ${MONITOR_IP}
  selector:
    app: grafana
