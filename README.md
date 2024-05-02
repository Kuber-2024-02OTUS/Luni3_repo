# Репозиторий для выполнения домашних заданий курса "Инфраструктурная платформа на основе Kubernetes-2024-02" 
Настройка сервисных аккаунтов и ограничение прав для них


1)В namespace homework создать service account monitoring
и дать ему доступ к эндпоинту /metrics вашего кластера

скопировать проект использовать в кластере 
kubectl apply -f sa-mo.yaml   создаем нужный sа

далее для этого  са даем нужную кластер роль 
kubectl apply -f cr-mo.yaml создаем  rolebinding

 и по итогу   соединяем роль с са 
kubectl apply -f  crb-mo.yaml   создаем clusterrolebinding


2)Изменить манифест deployment из прошлых ДЗ так, чтобы
поды запускались под service account monitoring

kubectl apply -f delpoyment.yaml добавлен необходимый sa


3)В namespace homework создать service account с именем
cd и дать ему роль admin в рамках namespace homework

 
kubectl apply -f sacd.yaml  создаем новый sa  c  именем cd 
kubectl apply -f rolecd.yaml  создаем роль для него 
kubectl apply -f  rbcd.yaml   и рольбиндинг для данного sa

5) Сгенерировать для service account cd токен с временем
действия 1 день и сохранить его в файл token

kubectl apply -f secret.yaml  создаем секрет для sa cd 

 kubectl create token  cd   -n homework  --duration 1440m


4) Создать kubeconfig для service account cd
используем script.sh
у нас созается конфиг sa.kuberconfig
Проверка, что конфит работает
KUBECONFIG=sa.kubeconfig  kubectl get po



 
