# k8s.monitor.installer

原本是一個安裝各種監控模組件的Ansible專案
但我不喜歡Ansible , 所以包裝成docker
用變數去控制安裝行為

###How to build
```
skaffold build
```

###How to deploy
```
cd kubernetes 
./run_job.sh
但其實原本是搭配另一個環境擋(gdeyamlOperator的environment.yaml)拿到namespaces決定部署在哪裏 , 所以這樣直接執行會無法執行run_job.sh
需要自行修改
```
