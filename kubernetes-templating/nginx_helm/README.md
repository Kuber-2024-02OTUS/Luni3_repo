Шаблонизация  nginx 
1) скачиваем проект (должен быть установлке helm)
2)команда для инсталяции  helm install (имя релиза)  nginx-helm 
3)проверка  curl -L http://homework.otus/homepage 



Создание релиза kafka в dev/prod окружение 
1)скачиваем проект 
2)внутри проекта в директории кафка лежит фаил   helmfile.yaml
3)на машине нужно установить  helmfile
4)helmfile init  иницитализируем нужные зависимости 
5)helmfile apply  запускаем helmfile  у нас появляется 2 инсталяции  kafka в namespace prod  и dev




