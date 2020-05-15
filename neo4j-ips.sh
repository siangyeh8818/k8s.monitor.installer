NEO4J_MASTER_IP=$(kubectl get secret pn-config -ojsonpath='{.data.config\.json}' | base64 -d | jq .PN_GLOBAL_DB | cut -d '/' -f 3 | cut -d ':' -f 1)

echo $NEO4J_MASTER_IP

arr=$(kubectl get secret pn-config -ojsonpath='{.data.config\.json}' | base64 -d | jq .PN_GLOBAL_DB_RESOLVER | jq -r .[])

#echo $arr
#if [ ${#arr[@]} -eq 0 ]; then
#  echo "Neo4j single mode. No db resolvers"
#else
#  echo "Neo4j causual cluster mode"
#  yq d neo4j/neo4j-systemctl.yaml.tpl subsets.[0].addresses >tmp.yml
#fi

# turn subsets.[0].address to array
yq d neo4j/neo4j-systemctl.yaml subsets.[0].addresses >tmp.yml
yq w tmp.yml subsets.[0].addresses[+].ip $NEO4J_MASTER_IP >tmp2.yml

rm tmp.yml
mv tmp2.yml tmp.yml

# loop through all slave ips
for SLAVE_IP in $arr; do
  IP=$(echo $SLAVE_IP | cut -d ':' -f 1)
  echo $IP
  yq w tmp.yml subsets.[0].addresses[+].ip $IP >tmp2.yml
  rm tmp.yml
  mv tmp2.yml tmp.yml
done

#cat tmp.yml

#mv tmp.yml neo4j/neo4j-systemctl.yaml
