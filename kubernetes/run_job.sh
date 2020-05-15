#!/bin/bash

waitpod() {
  local arg1=$1

  while ! [[ $(kubectl get po --all-namespaces | grep "${arg1}") ]]; do
    set -x
    echo "waiting for ${arg1} existed"
    set +x
    sleep 2
  done

  #while [ $(kubectl get po | grep neo4j-migration | awk '{print $3}' | grep -v "Running\|Completed") ]
  while [ $(kubectl get po --all-namespaces | grep ${arg1} | awk '{print $4}' | grep -v "Running\|Completed") ]; do
    set -x
    echo $(kubectl get po | grep ${arg1} | awk '{print $4}' | grep -v "Running\|Completed")
    echo "Waiting for ${arg1} job creating."
    set +x
    sleep 2
  done
  echo "done"
}

NAMESPACES=$(yq r job-marvinoperator.yml.tpl data.NS_DEFAULT)
export NS_DEFAULT=${NAMESPACES}
echo "---------------------"
env
echo "---------------------"
kubectl delete job monitor-operator -n ${NAMESPACES}
sleep 1s

EVA_FILE_LIST=($(find ./ -type f -name "*.tpl"))
for EVA_FILE in "${EVA_FILE_LIST[@]}"; do
  YML_FILE_NAME=$(echo ${EVA_FILE} | sed 's/.tpl//g')
  envsubst <${EVA_FILE} >${YML_FILE_NAME}
done
echo "----- Inspecting job-marvinoperator.yml--------"
cat job-marvinoperator.yml

kubectl apply -f *.yml

waitresult=$(waitpod "monitor-operator")

kubectl logs -f -l job-name=monitor-installer -n ${NAMESPACES}
