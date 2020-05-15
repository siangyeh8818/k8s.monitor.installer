#!/bin/bash

function CheckIp() {
    IP=$1
    echo $IP

    if [ $(echo $IP | grep -E '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$' | grep -o "\." | wc -l) -eq 3 ]; then
        echo "$IP is correct format of IP address"
        return 0
    else
        echo "IP is incorrect format of IP address"
        return 1
    fi
}

echo "-----env NS_DEFAULT : $NS_DEFAULT"

NEO4J_MASTER=$(kubectl -n $NS_DEFAULT get secret pn-config -o yaml | grep config.json | awk '{print $2}' | base64 -d | jq .PN_GLOBAL_DB | cut -d '/' -f 3 | cut -d ':' -f 1)
# ex: "neo4j.marvin:7687"
export NEO4J_MASTER=${NEO4J_MASTER}
echo "-----env NEO4J_MASTER: ${NEO4J_MASTER}"

NEO4J_NODE=$(kubectl -n $NS_DEFAULT get secret pn-config -o yaml | grep config.json | awk '{print $2}' | base64 -d | jq .PN_GLOBAL_DB_RESOLVER)

export NEO4J_NODE=${NEO4J_NODE}
echo "-----env NEO4J_NODE: ${NEO4J_NODE}"

EVA_FILE_LIST=($(find neo4j/ -type f -name "*.tpl"))
for EVA_FILE in "${EVA_FILE_LIST[@]}"; do
    YML_FILE_NAME=$(echo ${EVA_FILE} | sed 's/.tpl//g')
    envsubst <${EVA_FILE} >${YML_FILE_NAME}
done

CheckIp $NEO4J_MASTER

if [ $? -eq 0 ]; then
    echo "kubectl apply -f neo4j/neo4j-systemctl.yaml"
    echo "----------------"
    source neo4j-ips.sh
    echo "cat origin yaml ...."
    cat neo4j/neo4j-systemctl.yaml
    echo "----------------"
    echo "cat new yaml (tmp.yml)...."
    cat tmp.yml
    echo "----------------"
    kubectl apply -f tmp.yml
    echo "start to apply neo4j"
    kubectl apply -f neo4j/neo4j-svc-servicemonitor.yaml
else
    echo "kubectl apply -f neo4j/neo4j-container.yaml"
    kubectl apply -f neo4j/neo4j-container.yaml
fi

ELASTICSEARCH_ADDRESS=$(kubectl -n $NS_DEFAULT get secret pn-config -o yaml | grep config.json | awk '{print $2}' | base64 -d | jq .PN_GLOBAL_ELASTICSEARCH | cut -d '/' -f 3)
# ex: "elasticsearch.marvin.svc.cluster.local:9200"
export ELASTICSEARCH_ADDRESS=${ELASTICSEARCH_ADDRESS}
echo "-----env ELASTICSEARCH_ADDRESS: ${ELASTICSEARCH_ADDRESS}"

CheckIp $ELASTICSEARCH_ADDRESS

if [ $? -eq 0 ]; then

    for i in $(curl ${ELASTICSEARCH_ADDRESS}/_cat/nodes | awk '{print $1}'); do
        echo "elasticsearch ip : $i"
        cp elasticsearch/export.yaml.templete elasticsearch/export-$RANDOM.yaml.tpl
        export ELASTICSEARCH_IP=$i
        EVA_FILE_LIST=($(find elasticsearch/ -type f -name "*.tpl"))
        for EVA_FILE in "${EVA_FILE_LIST[@]}"; do
            YML_FILE_NAME=$(echo ${EVA_FILE} | sed 's/.tpl//g')
            envsubst <${EVA_FILE} >${YML_FILE_NAME}
            echo "we will kubectl apply -f ${YML_FILE_NAME}"
        done
    done
else
    cp elasticsearch/export.yaml.templete elasticsearch/export-$RANDOM.yaml.tpl
    EVA_FILE_LIST=($(find elasticsearch/ -type f -name "*.tpl"))
    for EVA_FILE in "${EVA_FILE_LIST[@]}"; do
        YML_FILE_NAME=$(echo ${EVA_FILE} | sed 's/.tpl//g')
        envsubst <${EVA_FILE} >${YML_FILE_NAME}
        echo "kubectl apply -f elasticsearch/${YML_FILE_NAME}"
    done
    kubectl apply -f elasticsearch/
fi
