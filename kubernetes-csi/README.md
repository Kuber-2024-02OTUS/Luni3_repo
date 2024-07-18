1) Создаем бакет в  ya.cloud и SA и даем доступ данному SA В бакет 

2) yc iam access-key create --service-account-name  <name_SA>
где перменная name_SA  вписываем ваш SA получаем для доступа нужные  key value

3) создаем секрет из проекта
kubectl apply -f secret.yaml 
 где меняем данные ниже на те что получим из 2  пункта 
  accessKeyID: <YOUR_ACCESS_KEY_ID>
  secretAccessKey: <YOUR_SECRET_ACCESS_KEY>
4)с данной ремы качаем папку https://github.com/yandex-cloud/k8s-csi-s3 deploy/kubernetes  
и использщуем необхмсые yaml файлы для развертывания драйвера
kubectl create -f provisioner.yaml
kubectl create -f driver.yaml
kubectl create -f csi-s3.yaml

5)создаем свой storage class
kubectl apply -f  stirageclass
вносим изменения в нвазние  bucket:    и ставим мся вашего ч bucket

6) создаем pvc
испольуем yaml из проекта
kubectl apply -f pvc.yaml


7) создаем под для использвание данной pvc
kubectl apply -f pod_volum.yaml
внутри пвс (бакета) будет создан фаил  по пути /homework/file и внутри него будет запись  Hello

Как проверить пойти на ya.cloud найти нужный bucker  и выкачать его внутри должно быть значение Hello
