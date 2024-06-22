# Репозиторий для выполнения домашних заданий курса "Инфраструктурная платформа на основе Kubernetes-2024-02" 

создаем машины в облаке яндекс 
Ниже команды нужно воспроизвести на всех нодах кластера  на worker  на master 
 sudo apt-get install -y apt-transport-https ca-certificates curl gpg  устанавливаем доп пакеты 
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg   ключи для репы
 echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list  адрес репы 
 sudo apt-get update обновляем пакеты после добавление репы
 sudo apt-get install -y kubelet kubeadm kubectl  устанавливаем  по   для кубера 
sudo systemctl enable --now kubelet  выключаем автообновление сервисов кубера 
sudo swapoff -a отключаем свап 
 wget https://github.com/containerd/containerd/releases/download/v1.6.8/containerd-1.6.8-linux-amd64.tar.gz   устанавливаем cri 
 sudo tar Cxzvf /usr/local containerd-1.6.8-linux-amd64.tar.gz
wget https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64 
 sudo install -m 755 runc.amd64 /usr/local/sbin/runc
 wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
 sudo mkdir /etc/containerd
 containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml   включаем cgroup
 sudo curl -L https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -o /etc/systemd/system/containerd.service
 sudo systemctl daemon-reload
sudo systemctl enable --now containerd

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF  смотрим значение 
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF   вносим изменения 

sudo sysctl --system
lsmod | grep br_netfilter
lsmod | grep overlay
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

Далее на мастере делаем  
kubeadm init --pod-network-cidr=10.244.0.0/16   иницируем создание кластера 
копируем   куб конфиг 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml    устанавливаем сетевой плагин   

На worker   node
 kubeadm join 10.128.0.24:6443 --token qxmls9.eg8zayjgmr1d9fti \
        --discovery-token-ca-cert-hash sha256:514478ce11e3b57e8438664df1690fb77d51d49d634576d64b6f3d3a1b3e7f23




Для обновление мастера  в кластере 

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list  добавляем репу 
sudo apt update
 sudo apt-cache madison kubeadm  смотрим какие есть версии 
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm='1.30.0-1.1' && sudo apt-mark hold kubeadm   устанавливаем  kubeadm
 kubeadm version проверяем  версию 
sudo kubeadm upgrade plan   смотрим план по обновлению
sudo kubeadm upgrade apply v1.30.0  обновляем  kubeadm
sudo apt-mark unhold kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubelet='1.30.0-1.1' kubectl='1.30.0-1.1' && sudo apt-mark hold kubelet kubectl  устанавливаем  kubelet  и kubectl 
sudo systemctl daemon-reload    обновляем демона
sudo systemctl restart kubelet  рестартим кубелет 

Команды делаем на мастере 
для вывода ноды и последующего ее обновления 
kubectl drain  $node_name --ignore-daemonsets  снимаем нагрузку 
после обновления 
kubectl uncordon $node_name


на воркере  аналогично мастеру 
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
 sudo apt-cache madison kubeadm
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm='1.30.0-1.1' && sudo apt-mark hold kubeadm
kubeadm version
sudo kubeadm upgrade node
sudo apt-mark unhold kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubelet='1.30.0-1.1' kubectl='1.30.0-1.1' && sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet



Для установки через  kubespray
создаем пользователя  на всех  в кластере 
sudo useradd -m -d /home/testuser -s /bin/bash testuser
sudo su - testuser
mkdir .ssh
touch .ssh/authorized_keys
echo "<публичный_ключ>" >> /home/testuser/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys



на админсмкую тачку устанавливаем  ansible 
apt-get install ansible
apt-get install pip 
git clone   https://github.com/kubernetes-sigs/kubespray.git 

VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements.txt   --break-system-packages устанавливаем зависиомсти 
копируем рыбу примера инвенторя cp -rfp inventory/sample inventory/mycluster 

declare -a IPS=(10.10.1.3 10.10.1.4 10.10.1.5)   вписываем  айпи адреса своих  машин 
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]} 
правим инветори фаил   (node  заменяем названием   hostname машин   ставим своего ansible_user)   
all:
  vars:
    ansible_user: kuber
    ansible_python_interpreter: /usr/bin/python3
    become: true
  hosts:
    node1:
      ansible_host: 10.128.0.28
      ip: 10.128.0.28
      access_ip: 10.128.0.28
    node2:
      ansible_host: 10.128.0.30
      ip: 10.128.0.30
      access_ip: 10.128.0.30
    node3:
      ansible_host: 10.128.0.19
      ip: 10.128.0.19
      access_ip: 10.128.0.19
    node4:
      ansible_host: 10.128.0.9
      ip: 10.128.0.9
      access_ip: 10.128.0.9
    node5:
      ansible_host: 10.128.0.39
      ip: 10.128.0.39
      access_ip: 10.128.0.39
  children:
    kube_control_plane:
      hosts:
        node1:
        node2:
        node3:
    kube_node:
      hosts:
        node4:
        node5:
    etcd:
      hosts:
        node1:
        node2:
        node3:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}


далее выполняем плейбук

ansible-playbook -i inventory/mycluster/hosts.yaml  -b cluster.yml












