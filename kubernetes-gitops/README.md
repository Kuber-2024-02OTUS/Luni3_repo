1) скачаиваем проект далее  скачиваем argocd helm меняем в нем  с стандартноного values.yaml  на argocd-values.yaml(что в проекте)  и переименовываем на values.yaml

2) форвардим порт  для упрощения подключения далее  логинимсы в argocd  сервер
 kubectl port-forward svc/argo-argocd-server 8080:443   название может изменится в связи с тем с каким навазнием вы поднивите сервис
далее логинемся на сервер  argocd login и используем  секрет что нам выдали при релизе в инф окне
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

3)создаем проект
argocd proj create otus -d https://kubernetes.default.svc,default -s https://github.com/Kuber-2024-02OTUS/Luni3_repo
дополнительно внести правки в  фаил 
argocd proj edit otus 
clusterResourceWhitelist:
- group: '*'
  kind: '*'
destinations:
- namespace: '*'


4) далее запускаем 2 манифеста  
kubectl apply -f networks.yaml  поднимет 1 приложение 
kubectl apply -f templaiting.yaml  поднимет 2 приложение в вебе  оба приложения должны бвть в состояние health 
