kind: Endpoints
apiVersion: v1
metadata:
  name: neo4j-relay
  namespace: ${NS_DEFAULT}
subsets:
  - addresses: __NEO4J_IPS__
    ports:
    - name: neo4j-port
      port: 2004

