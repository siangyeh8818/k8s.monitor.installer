#!/bin/bash

TIMERANGE=$1
#check=false

data_folder="yaml"

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

echo "------ Show env ........."
env
source pre-deploy.sh
echo "------ End env  ........."

echo "------ Stage1 : Used envsubst to replace env to yaml  ........."

EVA_FILE_LIST=($(find yaml/ -type f -name "*.tpl"))
for EVA_FILE in "${EVA_FILE_LIST[@]}"; do
  YML_FILE_NAME=$(echo ${EVA_FILE} | sed 's/.tpl//g')
  envsubst <${EVA_FILE} >${YML_FILE_NAME}
done

EVA_FILE_LIST=($(find base-infra/ -type f -name "*.tpl"))
for EVA_FILE in "${EVA_FILE_LIST[@]}"; do
  YML_FILE_NAME=$(echo ${EVA_FILE} | sed 's/.tpl//g')
  envsubst <${EVA_FILE} >${YML_FILE_NAME}
done
#echo "------ Stage1 : Used create_tunnel to create tunnel ........."
#if [ "${CREATE_TUNNEL}" = true ]; then
#  echo "CREATE_TUNNEL is ${CREATE_TUNNEL} , create ssh tunnel "
#  export KUBECONFIG=$(create_tunnel_k8s ${ENVORONMENT_BRANCH})
#elif [ "${CREATE_TUNNEL}" = false ]; then
#  echo "CREATE_TUNNEL is ${CREATE_TUNNEL} , will not create ssh tunnel "
#fi

#echo "------ Stage2 : Download gdeyamlOperator ........."

#echo "------ Stage3 : Used gdeyamlOperator to create tunnel ........."
#./gdeyamlOperator -action gitclone -inputfile deploy.yml -git-repo-path base -git-user ${GIT_USER} -git-token ${GIT_TOKEN} || error=true
#if [ $error ]; then
#  echo "failed to used gdeyamlOperator to clone pnbase form deploy.yml"
#  slackSend '#ff0000' "(1/4): Clone all necessary pack-zip or git-repo\nStatus:FAILED\nEnvIronment:${ENVORONMENT_BRANCH}" '#system-deploy'
#  exit -1
#fi
echo "------ Stage3 : Check cluster info  ........."
echo "----------------kebeconfig path----------------------"
echo $KUBECONFIG
echo "---------------show k8s-cluster-info---------------"
kubectl cluster-info || error=true
kubectl get nodes -owide || error=true
if [ $error ]; then
  echo "failed to connect kubernetes cluster "
  slackSend '#ff0000' "(1/4): Clone all necessary pack-zip or git-repo\nStatus:FAILED\nEnvironment:${ENVORONMENT_BRANCH}" '#system-deploy'
  exit -1
fi

echo "------ Stage4 : Create namespaces  ........."
kubectl create ns prometheus
kubectl create ns prometheus-operator
#./gdeyamlOperator -action kustomize -kustomize-module namespaces -namespace ${NS_DEFAULT}
echo "------ Stage5 : Deploy prometheus-operator  ........."
kubectl apply -f base-infra/prometheus-operator
waitresult=$(waitpod "prometheus-operator")

echo "------ Stage6 : Deploy prometheus  ........."
kubectl apply -f base-infra/prometheus
waitresult=$(waitpod "prometheus-k8s-0")

echo "------ Stage7 : Factering secret info (pre-deploy.sh) ........."
source pre-deploy.sh

echo "------ Stage8 : Install external monitor-modules----------"
dir=$(ls -l $data_folder | awk '/^d/ {print $NF}')
for i in $dir; do
  echo "Loop for Deploy Module Yaml , Module:  $i"
  if [ "$CHECK" != "true" ]; then
    echo "-------- Debug model ---------"
    echo "kubectl apply -f  yaml/$i"
    sleep 3s
  else
    echo "-------- Real model ---------"
    kubectl apply -f yaml/$i
    sleep 3s
  fi
done
