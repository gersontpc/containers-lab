# Hands-On Kubernetes

Bem-vindos ao laboratório de hands-on de Kubernetes! Durante esta atividade, você irá aprender como criar um cluster Kubernetes utilizando o K3d e entender os principais componentes que formam um cluster Kubernetes.

Vamos abordar como criar o deploy de aplicação e quais são componentes necessários, além de escalar o ambiente, verificar os logs dos contêineres e acessar um Pod via SSH.

Ao final deste laboratório, você estará apto a criar e gerenciar seus próprios clusters Kubernetes, utilizando as melhores práticas para orquestração de contêineres. Vamos começar!


## Criando Cluster Kubernetes

Existem várias ferramentas que podem ser utilizadas para simular um cluster Kubernetes em um ambiente local, cada uma com suas próprias características e recursos. Algumas das ferramentas mais populares incluem:

**Minikube**: é uma ferramenta de linha de comando que permite executar um cluster Kubernetes localmente em uma única máquina virtual.

**Kind**: é uma ferramenta que permite criar clusters Kubernetes em contêineres Docker, permitindo uma fácil criação e destruição de ambientes de teste.

**k3s**: é uma distribuição do Kubernetes com recursos reduzidos e projetada para uso em dispositivos com recursos limitados, como dispositivos IoT ou sistemas embarcados.

**MicroK8s**: é uma distribuição do Kubernetes que pode ser instalada em máquinas Ubuntu e é ideal para testes e desenvolvimento.

**Docker Desktop**: é uma ferramenta que inclui uma versão do Kubernetes e permite criar um cluster Kubernetes local usando o Docker.

**k3d**: é uma ferramenta que permite criar clusters Kubernetes em contêineres Docker, facilitando a criação de ambientes de teste e desenvolvimento.

Essas são apenas algumas das ferramentas disponíveis para simular um cluster Kubernetes em um ambiente local. A escolha da ferramenta mais adequada dependerá das necessidades e recursos disponíveis para o projeto em questão, hoje iremos utilizar a ferramenta k3d, ele permite criar e gerenciar clusters Kubernetes em contêineres Docker.


### Pré-requisitos:

Ter o Docker instalado, como dito anteriormente, ele cria o cluster em containers e o Docker é essencial para o funcionamento do Lab, ter o `curl` ou o `wget` instalados para poder executar o script de instalação e por último o kubectl para gerenciarmos o nosso cluster.


### Instalando o Kubectl on Cloud 9
1. Execute os comandos a seguir para instalar o kubectl:
```shell
cd ~/environment/container-technologies/
git pull origin master
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

```

### Instalando o k3d
Após a instalação do docker, iremos instalar o k3d.

Para o instalaer o K3D no cloud9 bastar utilizar o comando abaixo:


``` shell
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Após instalar o k3d, vamos testar se foi instalado corretamente:
``` shell
k3d --version
```

``` shell
OUTPOUT:
k3d version v5.4.8
k3s version v1.25.6-k3s1 (default)
```

Após checar se a instalação está correta, iremos criar o nosso cluster.

2. Execute o comando abaixo para criar o cluster
``` shell
k3d cluster create hands-on --servers 1 --agents 3 --port 9080:80@loadbalancer --port 9443:443@loadbalancer --api-port 6443 --k3s-arg "--disable=traefik@server:0"
```

Entendendo o comando:
`create`: Criar o cluster com o nome **hands-on**
`--server`: A quantidade de nós masters (control plane)
`--agents`: Quandidade de worker nodes
`--port`: Estamos direcionando a porta 80 (porta cluster) para a porta externa 9080 do seu computador.
`--api-port`: Porta para a comunicação com o api-server
`--disable`: Desabilitar a features, neste caso iremos desativar o traefik, que é uma ferramenta que faz o proxy reverso.

Output:
```
INFO[0000] portmapping '9080:80' targets the loadbalancer: defaulting to [servers:*:proxy agents:*:proxy]
INFO[0000] portmapping '9443:443' targets the loadbalancer: defaulting to [servers:*:proxy agents:*:proxy]
INFO[0000] Prep: Network
INFO[0000] Created network 'k3d-hands-on'
INFO[0000] Created image volume k3d-hands-on-images
INFO[0000] Starting new tools node...
INFO[0000] Starting Node 'k3d-hands-on-tools'
INFO[0001] Creating node 'k3d-hands-on-server-0'
INFO[0001] Creating node 'k3d-hands-on-agent-0'
INFO[0001] Creating node 'k3d-hands-on-agent-1'
INFO[0001] Creating node 'k3d-hands-on-agent-2'
INFO[0001] Creating LoadBalancer 'k3d-hands-on-serverlb'
INFO[0001] Using the k3d-tools node to gather environment information
INFO[0001] Starting new tools node...
INFO[0001] Starting Node 'k3d-hands-on-tools'
INFO[0002] Starting cluster 'hands-on'
INFO[0002] Starting servers...
INFO[0002] Starting Node 'k3d-hands-on-server-0'
INFO[0006] Starting agents...
INFO[0006] Starting Node 'k3d-hands-on-agent-0'
INFO[0007] Starting Node 'k3d-hands-on-agent-1'
INFO[0007] Starting Node 'k3d-hands-on-agent-2'
INFO[0011] Starting helpers...
INFO[0011] Starting Node 'k3d-hands-on-serverlb'
INFO[0017] Injecting records for hostAliases (incl. host.k3d.internal) and for 6 network members into CoreDNS configmap...
INFO[0020] Cluster 'hands-on' created successfully!
INFO[0020] You can now use it like this:
```

3. Listando o nosso cluster com o k3d:

``` shell
k3d cluster list
````

``` shell
OUTPUT:
NAME       SERVERS   AGENTS   LOADBALANCER
hands-on   1/1       3/3      true
```

4. Verificando se os componentes do cluster está executando corretamente:

``` shell
kubectl cluster-info
```

``` shell
OUTPUT:
Kubernetes control plane is running at https://0.0.0.0:6443
CoreDNS is running at https://0.0.0.0:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://0.0.0.0:6443/api/v1/namespaces/kube-system/services/https:metrics-server:https/proxy
```

5. Verificando se o Scheduler e o Controller-Manager está funcionando corretamente.

``` shell
kubectl get componentstatuses
```

``` shell
OUTPUT:
NAME                 STATUS    MESSAGE   ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
```
6. Listando os nós do cluster:

``` shell
kubectl get nodes
```
``` shell
OUTPUT: 
NAME                    STATUS   ROLES                  AGE     VERSION
k3d-hands-on-agent-2    Ready    <none>                 4m33s   v1.25.6+k3s1
k3d-hands-on-server-0   Ready    control-plane,master   4m36s   v1.25.6+k3s1
k3d-hands-on-agent-1    Ready    <none>                 4m33s   v1.25.6+k3s1
k3d-hands-on-agent-0    Ready    <none>                 4m32s   v1.25.6+k3s1
```
7. Listando os componentes do cluster

``` shell
kubectl get all --all-namespaces
```

``` shell
OUTPUT:
NAMESPACE     NAME                                          READY   STATUS    RESTARTS   AGE
kube-system   pod/coredns-597584b69b-6g8qb                  1/1     Running   0          2m33s
kube-system   pod/local-path-provisioner-79f67d76f8-8xgw8   1/1     Running   0          2m33s
kube-system   pod/metrics-server-5f9f776df5-vgr6j           1/1     Running   0          2m33s

NAMESPACE     NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE
default       service/kubernetes       ClusterIP   10.43.0.1      <none>        443/TCP                  2m47s
kube-system   service/kube-dns         ClusterIP   10.43.0.10     <none>        53/UDP,53/TCP,9153/TCP   2m43s
kube-system   service/metrics-server   ClusterIP   10.43.240.11   <none>        443/TCP                  2m42s

NAMESPACE     NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/coredns                  1/1     1            1           2m43s
kube-system   deployment.apps/local-path-provisioner   1/1     1            1           2m43s
kube-system   deployment.apps/metrics-server           1/1     1            1           2m42s

NAMESPACE     NAME                                                DESIRED   CURRENT   READY   AGE
kube-system   replicaset.apps/coredns-597584b69b                  1         1         1       2m33s
kube-system   replicaset.apps/local-path-provisioner-79f67d76f8   1         1         1       2m33s
kube-system   replicaset.apps/metrics-server-5f9f776df5           1         1         1       2m33s
```

### Conhecendo o kubectl

O kubectl é uma ferramenta de linha de comando utilizada para interagir com clusters Kubernetes. Ele permite que os usuários gerenciem aplicativos e recursos em um cluster Kubernetes, como implantações, serviços, pods, configurações, etc.

Com o kubectl, é possível implantar e escalar aplicativos, fazer rolling updates e rollbacks, gerenciar o estado dos pods e serviços, criar e gerenciar objetos personalizados, além de muitas outras tarefas relacionadas ao gerenciamento de um cluster Kubernetes.

O kubectl é uma ferramenta essencial para qualquer pessoa que trabalhe com Kubernetes, como desenvolvedores, administradores de sistemas e operadores de cluster. Ele é usado em um ambiente de terminal para interagir com o cluster Kubernetes e executar operações em qualquer nó ou componente do cluster.

Em resumo, o kubectl é a principal ferramenta de gerenciamento de Kubernetes que permite que você controle e gerencie aplicativos em um cluster Kubernetes.

Obs: O k3d configura o contexto do cluster de forma automática, então iremos apenas listar os contextos já configurados.

8. Listando os contextos dos clusters configurados:

``` shell
kubectl config get-contexts
```
``` shell
OUTPUT:
CURRENT   NAME                                                   CLUSTER                                                    AUTHINFO                                                   NAMESPACE
          arn:aws:eks:us-east-1:223341017520:cluster/backend     arn:aws:eks:us-east-1:223341017520:cluster/backend         arn:aws:eks:us-east-1:223341017520:cluster/backend
          docker-desktop                                         docker-desktop                                             docker-desktop
*         k3d-hands-on                                           k3d-hands-on                                               admin@k3d-hands-on
```

O kubectl pode ser usado para configurar o contexto de um cluster no arquivo ~/.kube/config. Esse arquivo é usado pelo kubectl para determinar qual cluster, usuário e namespace devem ser usados para interagir com o cluster.

A seguir estão os principais elementos de um contexto configurado no arquivo ~/.kube/config:

`apiVersion`: a versão da API do Kubernetes usada pelo arquivo de configuração.\
`kind`: o tipo do objeto Kubernetes. Para um contexto, o tipo é Context.\
`name`: o nome do contexto.\
`context`: um objeto que define as informações de contexto para um cluster, incluindo cluster, user e namespace.\
`cluster`: um objeto que define as informações do cluster, incluindo o nome do cluster e o endpoint para se conectar ao API server.\
`user`: um objeto que define as informações de autenticação do usuário, como o nome do usuário e a chave de acesso.\
`namespace`: o namespace padrão a ser usado pelo contexto.\

Um exemplo de contexto configurado no arquivo ~/.kube/config pode ser semelhante a este:

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJ....dEQkFtTlRudDBidHUwM2NpTDJFZUVxekdObWZoVE4KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    server: https://0.0.0.0:6443
  name: k3d-hands-on
contexts:
- context:
    cluster: k3d-hands-on
    user: admin@k3d-hands-on
  name: k3d-hands-on
current-context: k3d-hands-on
kind: Config
preferences: {}
users:
- name: admin@k3d-hands-on
  user:
    client-certificate-data: LS0tLS1CRUdJTiB...dEQkFtTlRudDBidHUwM2NpTDJFZUVxekdObWZoVE4KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo==
    client-key-data: LS0tLS1CRUdJTiBFQyBQUklW...dEQkFtTlRudDBidHUwM2NpTDJFZUVxekdObWZoVE4KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
```

### Realizando o deploy de uma aplicação

Agora que já entendemos os principais componentes do Cluster, iremos realizar o deploy de uma app, essa app será basicamente uma imagem do NGINX,  O NGINX é um servidor web de código aberto que pode ser usado para servir arquivos estáticos ou atuar como um proxy reverso para outros servidores web.


Na path /manifests, tem os manifestos para realizarmos o deploy.

Iremos utilizar primeiro o `deployment.yaml`, vamos entender os principais componentes deste manifesto.

`manifests/deployment.yaml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

`apiVersion:` especifica a versão da API que está sendo utilizada, neste caso a apps/v1.\
`kind:` especifica o tipo de objeto que está sendo criado, neste caso um Deployment.\
`metadata:` contém informações de metadados do objeto, como o nome e labels para identificação.\
`replicas:` especifica o número de réplicas que serão criadas para garantir a disponibilidade da aplicação.\
`selector:` especifica o seletor de labels que será usado para identificar os Pods que fazem parte do Deployment.\
`template:` especifica o modelo para criação dos Pods do Deployment.\
`metadata:` contém as informações de metadados do Pod.\
`labels:` especifica as labels para identificação do Pod.\
`spec:` especifica as características do Pod, como os containers que serão executados dentro dele.\
`containers:` especifica o(s) container(s) que serão executados no Pod.\
`name:` especifica o nome do container.\
`image:` especifica a imagem do container que será utilizada.\
`ports:` especifica as portas que serão expostas pelo container. Neste caso, a porta 80 foi exposta.\

9. Após entender cada item do nosso manifesto, vamos utilizar ele para realizar o deploy do nosso app.

``` shell
cd ~/environment/container-technologies/03-kubernetes/01-cluster-local/
kubectl apply -f manifests/deployment.yaml
```

10. Após aplicado, iremos listar a nossa app.

``` shell
kubectl get pods -l app=nginx
```

``` shell
OUTPUT:
default       nginx-deployment-cd55c47f5-7sbgz          0/1     ContainerCreating   0          7s
default       nginx-deployment-cd55c47f5-c68ww          0/1     ContainerCreating   0          7s
```

11. Vamos realizar o get novamente para verificar se os `PODS` da app subiram.

``` shell
kubectl get pods  -l app=nginx
```

``` shell
OUTPUT:
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-cd55c47f5-c68ww   1/1     Running   0          67s
nginx-deployment-cd55c47f5-7sbgz   1/1     Running   0          67s
```

12. Trazendo informação mais detalhada dos pods.

``` shell
kubectl get pods  -l app=nginx -o wide
```

``` shell
OUTPUT:
NAME                                READY   STATUS    RESTARTS   AGE     IP          NODE                    NOMINATED NODE   READINESS GATES
nginx-deployment-5954ddfcc9-kl6pl   1/1     Running   0          2m14s   10.42.3.7   k3d-hands-on-server-0   <none>           <none>
nginx-deployment-5954ddfcc9-zchtl   1/1     Running   0          2m10s   10.42.0.7   k3d-hands-on-agent-1    <none>           <none>
```

13. Conhecendo o POD da nossa app, com o comando `kubectl describe pods <pod-name>` . Escolha o node de um pod listado anteriromente.

``` shell
kubectl describe pods nginx-deployment-cd55c47f5-c68ww
```

``` shell
OUTPUT:
Name:             nginx-deployment-cd55c47f5-c68ww
Namespace:        default
Priority:         0
Service Account:  default
Node:             k3d-hands-on-agent-0/172.19.0.4
Start Time:       Thu, 16 Mar 2023 15:24:44 -0300
Labels:           app=nginx
                  pod-template-hash=cd55c47f5
Annotations:      <none>
Status:           Running
IP:               10.42.3.3
IPs:
  IP:           10.42.3.3
Controlled By:  ReplicaSet/nginx-deployment-cd55c47f5
Containers:
  nginx:
    Container ID:   containerd://397d8c86512c9c647e4579d42da4b26e12abcfd860bd484e46603b16ed1de585
    Image:          nginx:latest
    Image ID:       docker.io/library/nginx@sha256:aa0afebbb3cfa473099a62c4b32e9b3fb73ed23f2a75a65ce1d4b4f55a5c2ef2
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Thu, 16 Mar 2023 15:24:55 -0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-bqld7 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-bqld7:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  15m   default-scheduler  Successfully assigned default/nginx-deployment-cd55c47f5-c68ww to k3d-hands-on-agent-0
  Normal  Pulling    15m   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     15m   kubelet            Successfully pulled image "nginx:latest" in 10.701844921s (10.701860672s including waiting)
  Normal  Created    15m   kubelet            Created container nginx
  Normal  Started    15m   kubelet            Started container nginx
```

14. Conhecendo o nosso deploy, utilizando o comando `kubectl describe deploy <deploy-name>`, mas antes iremos pegar o nome do nosso deploy\
Primeiro vamos realizar o `kubectl get deploy` para listar todos os deploys de todos os namespaces.\


``` shell
kubectl get deploy
````
``` shell
OUTPUT:
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           20m
```

15. Descrevendo o deploy `nginx-deployment`.

``` shell
$ kubectl describe deploy nginx-deployment
```
``` shell
OUTPUT:
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Thu, 16 Mar 2023 15:24:44 -0300
Labels:                 app=nginx
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx:latest
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-cd55c47f5 (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  22m   deployment-controller  Scaled up replica set nginx-deployment-cd55c47f5 to 2
```

### Acessando a App

Para acessar a app, precisamos expor o serviço em nosso cluster apontando para os nossos pods.

Criando a service para poder acessar a app, o manifesto está na path `manifests/service.yaml`.

O conteúdo do manifesto é:

`manifests/service.yaml`


```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - name: http
    port: 80
    targetPort: 80
````

Este manifesto descreve um serviço do Kubernetes com as seguintes configurações:

`apiVersion:` a versão da API do Kubernetes usada para criar o recurso. Neste caso, é a versão "v1".\
`kind:` o tipo do recurso Kubernetes que está sendo criado. Neste caso, é um "Service".\
`metadata:` informações sobre o objeto sendo criado, incluindo um nome descritivo e rótulos que permitem que o recurso seja pesquisado e gerenciado com facilidade.\
`spec:` as especificações do serviço, incluindo sua configuração de rede e informações de porta.\
`selector:` uma seleção baseada em rótulos que identifica os pods a serem expostos pelo serviço. Neste caso, o serviço expõe todos os pods com o rótulo "app: nginx".\
`type:` o tipo de serviço a ser criado. Neste caso, é um LoadBalancer, que permite fazer o balanceamento de carga entre os ips dos nós\
`ports:` as portas expostas pelo serviço. Neste caso, uma única porta é exposta com o nome "http" e mapeada para a porta 80 nos pods correspondentes à seleção de rótulo do serviço.

Após entender cada item do nosso manifesto, vamos utilizar ele para realizar o deploy da nossa service.

``` shell
cd ~/environment/container-technologies/03-kubernetes/01-cluster-local/
kubectl apply -f manifests/service.yaml
service/nginx-service created
```

16. Checando se a service foi criada com sucesso.
``` shell
kubectl get service
```
``` shell
OUTPUT:
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                                   PORT(S)        AGE
kubernetes      ClusterIP      10.43.0.1       <none>                                        443/TCP        18m
nginx-service   LoadBalancer   10.43.169.188   172.22.0.3,172.22.0.4,172.22.0.5,172.22.0.6   80:31258/TCP   8m16s
```

Repare que a nossa service `nginx-service` foi criada com sucesso.

17. Agora vamos acessar o app através do navegador, gere a url com o comando abaixo abaixo:

```
publicC9Ip=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4` && echo "http://$publicC9Ip:9080"
```
![nginx](img/nginx-frontend.png)

Sucesso! conseguimos acessar a nossa app.

### Escalando os PODs

18. Para escalar os pods iremos executar o comando `kubectl scale deployment`, atualmente temos 2 répicas e iremos aumentar para 8 réplicas.

``` shell
kubectl scale deployment nginx-deployment --replicas=8
```

``` shell
OUTPUT:
deployment.apps/nginx-deployment scaled
```

19. Checando se foi escalado corretamente.

``` shell
kubectl get pods -l app=nginx
```

``` shell
OUTPUT:
NAME                               READY   STATUS              RESTARTS   AGE
nginx-deployment-cd55c47f5-c68ww   1/1     Running             0          47m
nginx-deployment-cd55c47f5-7sbgz   1/1     Running             0          47m
nginx-deployment-cd55c47f5-nw5vn   0/1     ContainerCreating   0          3s
nginx-deployment-cd55c47f5-nbpgb   0/1     ContainerCreating   0          3s
nginx-deployment-cd55c47f5-l6mnv   0/1     ContainerCreating   0          3s
nginx-deployment-cd55c47f5-trrw9   0/1     ContainerCreating   0          3s
nginx-deployment-cd55c47f5-85rfb   0/1     ContainerCreating   0          3s
nginx-deployment-cd55c47f5-zhj67   1/1     Running             0          3s
```

Repare que os containers foram escalados para 8 réplicas.

```
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-cd55c47f5-c68ww   1/1     Running   0          48m
nginx-deployment-cd55c47f5-7sbgz   1/1     Running   0          48m
nginx-deployment-cd55c47f5-zhj67   1/1     Running   0          71s
nginx-deployment-cd55c47f5-l6mnv   1/1     Running   0          71s
nginx-deployment-cd55c47f5-nbpgb   1/1     Running   0          71s
nginx-deployment-cd55c47f5-nw5vn   1/1     Running   0          71s
nginx-deployment-cd55c47f5-trrw9   1/1     Running   0          71s
nginx-deployment-cd55c47f5-85rfb   1/1     Running   0          71s
```

Pronto os PODs foram escalados com sucesso!

20. Vamos voltar para duas réplicas.

``` shell
kubectl scale deployment nginx-deployment --replicas=2
```

``` shell
OUTPUT:
deployment.apps/nginx-deployment scaled
```

### Realizando rollback de versão

21. Para realizar o rollback da versão iremos aplicar o manifesto `manifests/deployment-v1.yaml`

``` shell
kubectl apply -f manifests/deployment-v1.yaml
```

``` shell
OUTPUT:
deployment.apps/nginx-deployment configured
```

Execute o curl para verificar se alterou a versão.

``` shell
curl http://$publicC9Ip:9080/
```

``` shell
OUTPUT:
DEPLOYMENT VERSAO 1
```

22. Após realizar o deploy, vamos realizar o deploy do `manifests/deployment-v2.yaml`

``` shell
kubectl apply -f manifests/deployment-v2.yaml
```
``` shell
OUTPUT:
deployment.apps/nginx-deployment configured
```

23. Execute o curl para verificar se alterou a versão.

``` shell
curl http://$publicC9Ip:9080/
```

``` shell
OUTPUT:
DEPLOYMENT VERSAO 2
```

24. Repare que os pods estão recém criados:
``` shell
kubectl get pods -l app=nginx
```

``` shell
OUTPUT:
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-75b69f9778-974lm   1/1     Running   0          42s
nginx-deployment-75b69f9778-jxsch   1/1     Running   0          40s
```

25. Realize o curl para retornar testar se estamos utilizar o curl.

``` shell
curl http://$publicC9Ip:9080/
```
``` shell
OUTPUT:
DEPLOYMENT VERSAO 2
```

26. Agora iremos realizar o Rollback para a versão 1 do nosso deployment.
O Deployment cria uma revisão a cada alteração no deploy, para listar essas versões iremos utilizar o `kubectl rollout history`:

``` shell
kubectl rollout history deploy nginx-deployment
```

``` shell
OUTPUT:
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>
```

27. Agora vamos realizar o rollback para a versão 2 da nossa app.

```
kubectl rollout undo deployment/nginx-deployment --to-revision=1
```

``` shell
OUTPUT:
deployment.apps/nginx-deployment rolled back
```

### Coletado os logs dos pods.

28. Para coletar os logs dos PODs, iremos utilizar o `kubectl logs -f <NOME DO POD>`

``` shell
kubectl logs -f nginx-deployment-cd55c47f5-knjsg
```

``` shell
OUTPUT:
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/03/16 20:26:42 [notice] 1#1: using the "epoll" event method
2023/03/16 20:26:42 [notice] 1#1: nginx/1.23.3
2023/03/16 20:26:42 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6)
2023/03/16 20:26:42 [notice] 1#1: OS: Linux 5.15.49-linuxkit
2023/03/16 20:26:42 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2023/03/16 20:26:42 [notice] 1#1: start worker processes
2023/03/16 20:26:42 [notice] 1#1: start worker process 29
2023/03/16 20:26:42 [notice] 1#1: start worker process 30
2023/03/16 20:26:42 [notice] 1#1: start worker process 31
2023/03/16 20:26:42 [notice] 1#1: start worker process 32
2023/03/16 20:26:42 [notice] 1#1: start worker process 33

Logs dos GETS realizados

10.42.2.0 - - [16/Mar/2023:20:33:22 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.86.0" "-"
10.42.2.0 - - [16/Mar/2023:20:33:55 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.86.0" "-"
10.42.0.0 - - [16/Mar/2023:20:33:56 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.86.0" "-"
```


### Finalizando o Lab.

Agora é hora de limpar a casa! :)

Vamos deletar os objetos que criamos dentro do nosso cluster Kubernetes

29. Deletando a Service:

``` shell
kubectl delete -f service.yaml
```
``` shell
OUTPUT:
service "nginx-service" deleted
```

30. Deletendo o Deployment:

``` shell
kubectl delete -f deployment-v1.yaml
```

``` shell
OUTPUT:
deployment.apps "nginx-deployment" delete
```

E por último vamos deletar o nosso cluster.

``` shell
k3d cluster delete hands-on
```

``` shell
OUTPUT:
INFO[0000] Deleting cluster 'hands-on'
INFO[0001] Deleting cluster network 'k3d-hands-on'
INFO[0001] Deleting 1 attached volumes...
INFO[0001] Removing cluster details from default kubeconfig...
INFO[0001] Removing standalone kubeconfig file (if there is one)...
INFO[0001] Successfully deleted cluster hands-on!
```

### Conclusão
Parabéns, você concluiu com sucesso este laboratório de hands-on de Kubernetes!

Durante este laboratório, você aprendeu como criar um cluster Kubernetes usando o K3d e sobre os principais componentes que compõem um cluster Kubernetes. Você também aprendeu como criar um pod, deployment de uma aplicação, como escalar o ambiente, verificar os logs e até mesmo acessar um pod via SSH.

Este conhecimento é fundamental para quem deseja entender e trabalhar com Kubernetes, uma das plataformas mais utilizadas no mundo para orquestração de containers. Esperamos que este laboratório tenha sido útil para você e que agora você se sinta mais confiante para trabalhar com Kubernetes em seu ambiente. Parabéns novamente e continue praticando!