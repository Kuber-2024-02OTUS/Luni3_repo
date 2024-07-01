# Создаем манифест описывающий pod с distroless образом для создания контейнера 

1 kubectl apply -f efimer.yaml

# Далее   создаем под к нашему существующему поду 

2 kubectl debug -n default   nginx --image=busybox -ti  --target=nginx-distroless

# получаем доступ непосредственно в этом поде к файловой системе 

3 proc/1/root/etc/nginx # ls
conf.d          fastcgi_params  koi-utf         koi-win         mime.types      modules         nginx.conf      scgi_params     uwsgi_params    win-utf
/proc/1/root/etc/nginx # pwd
/proc/1/root/etc/nginx


# Создаем под с tcpdump внутри 

4 kubectl debug -n default   nginx --image=nicolaka/netshoot -ti  --target=nginx-distroless



# Выполните несколько сетевых обращений к nginx в отлаживаемом
поде любым удобным вам способом. 
5 curl http://localhost:8001/api/v1/namespaces/default/pods/nginx:80/proxy/
запросы в tcpdump 
00:05:38.543314 eth0  Out ifindex 2 42:6d:c2:fc:3b:45 ethertype IPv4 (0x0800), length 684: 10.112.129.92.80 > 10.128.0.27.41718: Flags [P.], seq 239:851, ack 211, win 508, options [nop,nop,TS val 2747729647 ecr 2175532623], length 612: HTTP
00:05:38.543718 eth0  In  ifindex 2 8e:d9:3b:40:0b:01 ethertype IPv4 (0x0800), length 72: 10.128.0.27.41718 > 10.112.129.92.80: Flags [.], ack 851, win 164, options [nop,nop,TS val 2175532692 ecr 2747729647], length 0
00:06:09.513830 eth0  In  ifindex 2 8e:d9:3b:40:0b:01 ethertype IPv4 (0x0800), length 72: 10.128.0.27.41718 > 10.112.129.92.80: Flags [.], ack 851, win 166, options [nop,nop,TS val 2175563662 ecr 2747729647], length 0
00:06:09.513845 eth0  Out ifindex 2 42:6d:c2:fc:3b:45 ethertype IPv4 (0x0800), length 72: 10.112.129.92.80 > 10.128.0.27.41718: Flags [.], ack 211, win 508, options [nop,nop,TS val 2747760617 ecr 2175532692], length 0
00:06:20.807741 eth0  In  ifindex 2 8e:d9:3b:40:0b:01 ethertype IPv4 (0x0800), length 282: 10.128.0.27.41718 > 10.112.129.92.80: Flags [P.], seq 211:421, ack 851, win 166, options [nop,nop,TS val 2175574956 ecr 2747760617], length 210: HTTP: GET / HTTP/1.1
00:06:20.807765 eth0  Out ifindex 2 42:6d:c2:fc:3b:45 ethertype IPv4 (0x0800), length 72: 10.112.129.92.80 > 10.128.0.27.41718: Flags [.], ack 421, win 507, options [nop,nop,TS val 2747771911 ecr 2175574956], length 0


# Получите доступ к файловой системе ноды, и затем доступ к логам
пода с distrolles nginx 
6 kubectl  debug node/cl1vmt8d77ghvdn8rr0v-ujed -it --image=busybox
посмотреть логи на ноде 
cat /host/var/log/pods/default_node-debugger-cl1vmt8d77ghvdn8rr0v-ujed-4254n_59ba4144-aeda-43b8-a0e1-956e70b206df/debugger/0.log



# Выполните команду strace для корневого процесса nginx в
рассматриваемом ранее поде. 

* kubectl debug -n default   nginx --image=quay.io/mwasher/crictl:0.0.1 -ti --target=nginx-distroless  -- /bin/sh

apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx-distroless
    image:  kyos0109/nginx-distroless
    securityContext:
      capabilities:
        add:
        - SYS_PTRACE

внутри пода получаем strace: attach: ptrace(PTRACE_SEIZE, 7): Operation not permitted 
эфимерные поды не имеют доступа к процессам и не работают   с  securityContext
    
