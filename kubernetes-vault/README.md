В namespace consul установите consul из helm-чарта
https://github.com/hashicorp/consul-k8s.git с параметрами 3
реплики для сервера.


helm install consul consul  --set global.name=consul    --namespace  consul  --create-namespace


● В namespace vault установите hashicorp vault из helm-чарта
https://github.com/hashicorp/vault-helm.git
● Сконфигурируйте установку для использования ранее
установленного consul в HA режиме
● Приложите команду установки чарта и файл с переменными
к результатам ДЗ.



helm install  vault  vault-helm-main   --namespace  vault   --create-namespace


Выполните инициализацию vault и распечатайте с помощью
полученного unseal key все поды хранилища

jq -r ".unseal_keys_b64[]" cluster-keys.json
export VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json)
kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-1 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-2 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY



Создайте хранилище секретов otus/ с Secret Engine KV, а в нем
секрет otus/cred, содержащий username='otus' password='asajkjkahs’

kubectl exec --stdin=true --tty=true vault-0 -n  vault -- /bin/sh
jq -r ".root_token" cluster-keys.json
vault login
vault kv put -mount=otus otus/cred   username='otus' password='asajkjkahs’


В namespace vault создайте serviceAccount с именем vault-auth и
ClusterRoleBinding для него с ролью system:auth-delegator.

kubectl apply -f sa.yaml
kubectl apply -f secret.yaml
kubectl apply -f lusterrolebinding.yaml

В Vault включите авторизацию auth/kubernetes и сконфигурируйте
ее используя токен и сертификат ранее созданного ServiceAccount

 vault auth enable kubernetes
внутри пода инициализировать 3 переменные 

vault write auth/kubernetes/config      
      token_reviewer_jwt="$SA_JWT_TOKEN" 
      kubernetes_host="$K8S_HOST" 
      kubernetes_ca_cert="$SA_CA_CRT"

 
Создайте и примените политику otus-policy для секретов /otus/cred
с capabilities = [“read”, “list”]. Файл .hcl с политикой приложите к
результатам ДЗ

kubectl exec -i --namespace vault  vault-0 -- \
  vault policy write otus-policy - << EOF
    path "otus/data/cred*" {
        capabilities=["read","list"]
    }
EOF




Создайте роль auth/kubernetes/role/otus в vault с использованием
ServiceAccount vault-auth из namespace Vault и политикой
otus-policy

vault write  auth/kubernetes/role/otus \
   bound_service_account_names=vault-auth \
   bound_service_account_namespaces=vault \
   policies=otus-policy \
   ttl=1440h


● Установите External Secrets Operator из helm-чарта в namespace
vault. Команду установки чарта и файл с переменными, если вы их
используете приложите к результатам ДЗ


helm install external-secrets    external-secrets/external-secrets    -n vault



● Создайте и примените манифест crd объекта SecretStore в
namespace vault, сконфигурированный для доступа к KV секретам
Vault с использованием ранее созданной роли otus и сервис
аккаунта vault-auth. Убедитесь, что созданный SecretStore успешно
подключился к vault. Получившийся манифест приложите к
результатам ДЗ.


kubectl apply -f secretstore.yaml




Создайте и примените манифест crd объекта ExternalSecret с
следующими параметрами:
● ns – vault
● SecretStore – созданный на прошлом шаге
● Target.name = otus-cred
● Получает значения KV секрета /otus/cred из vault и
отображает их в два ключа – username и password
соответственно
Убедитесь, что после применения ExternalSecret будет создан
Secret в ns vault с именем otus-cred и хранящий в себе 2 ключа
username и password, со значениями, которые были сохранены
ранее в vault. Добавьте манифест объекта ExternalSecret к
результатам ДЗ.


kubectl apply -f external-secrets.yaml






