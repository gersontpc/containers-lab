# Hands-On Kubernetes

Bem-vindos ao laboratório de hands-on de Kubernetes! Durante esta atividade, você irá aprender como criar um cluster Kubernetes utilizando o Elastic Kubernetes Service (EKS) e entender os principais componentes que formam um cluster Kubernetes.

Vamos abordar como criar o deploy de aplicação e quais são componentes necessários, além de escalar o ambiente, verificar os logs dos contêineres e acessar um Pod via SSH.

Ao final deste laboratório, você passará a entender os principais componentes do kubernetes, apto a criar e gerenciar seus próprios clusters Kubernetes na AWS, utilizando as melhores práticas para orquestração de contêineres. Vamos começar!


## O que é o EKS

O Amazon Elastic Kubernetes Service (EKS) é um serviço gerenciado de Kubernetes que simplifica o processo de implantação, operação e manutenção de clusters Kubernetes na Amazon Web Services (AWS).

O EKS fornece um ambiente Kubernetes totalmente gerenciado, que inclui:

Nós do Kubernetes gerenciados pela AWS
Controle de acesso e gerenciamento de identidade
Atualizações e patches do Kubernetes
Monitoramento e alertas
O EKS é uma boa opção para organizações que desejam implantar e gerenciar aplicativos Kubernetes na AWS sem precisar gerenciar a infraestrutura subjacente.

Aqui estão alguns dos benefícios do EKS:

Fácil de configurar e gerenciar: O EKS fornece um ambiente Kubernetes totalmente gerenciado, o que significa que você não precisa se preocupar com a instalação ou manutenção da infraestrutura subjacente.
Segurança: O EKS fornece recursos de segurança integrados, como controle de acesso e gerenciamento de identidade.
Escalabilidade: O EKS é escalável horizontalmente para atender às suas necessidades.
Compatibilidade: O EKS é compatível com o Kubernetes, o que significa que você pode usar as ferramentas e plugins de sua escolha.

Mas existem outras opções de clusters Kubernetes gerenciados em outras clouds publicas, como: Google: Google Kubernetes Engine (GKE) e Azure: Azure Kubernetes Service (AKS).

### Pré-requisitos:
Ter acesso a conta lab no AWS Academy https://awsacademy.instructure.com/.

## Provisionando o EKS

Este workflow são os passos necessários para criar um Cluster EKS.
![](img/provisionamento-eks-01.png)

1. Acesse o console da aws e pesquise por EKS e clique em Elastic Kubernetes Service.

![](img/eks-01.png)

2. Ao clicar na página do serviço clique em <b>Create cluster</b>.

![](img/eks-02.png)

Em <b>Configure cluster</b>, siga os passos abaixo:

2.1 Selecione **Custom Configuration**  
2.2 Desabilite a opção **Use EKS Auto Mode**  
2.3 Em **Name** insira o nome do cluster: **eks-lab**  
2.4 Em **Cluster IAM role** selecione a role **LabRole**  

![](img/eks-04.png)

2. Em seguida clique em <b>Next</b>

![](img/eks-06.png)

3. Na sessão <b>Specify networking</b>, em <b>VPC</b> deixe a sua <b>VPC Default</b> da conta, em <b>Subnets</b> selecione somente as subnets: <b>us-east-1a</b>, <b>us-east-1b</b> e <b>us-east-1c</b>, conforme o print abaixo.

![](img/eks-07.png)

4. Por último clique em <b>Next</b>

![](img/eks-08.png)

5. Na sessão <b>Configure observability</b>, vá até <b>Control plane logs</b> e habilite os logs para: <b>API Server</b>, <b>Audit</b>, <b>Authenticator</b>, <b>Controller manager</b> e <b>Scheduler</b>.

![](img/eks-09.png)

6. Em seguida clique em <b>Next</b>

![](img/eks-10.png)

7. Seguindo o workflow de utilização do cluster EKS, chegou o passo de **Implantar Add-ons**.

![](img/provisionamento-eks-02.png)

Na sessão <b>Select add-ons</b>, os <b>Add-ons</b>: <b>kube-proxy</b>, <b>CoreDNS</b>, <b>Amazon VPC CNI</b> e <b>Amazon EKS Pod Identity Agent</b>, já estarão pré-selecionados.

![](img/eks-11.png)

![](img/eks-12.png)

Para que serve cada Add-on ?

> O <b>kube-proxy</b>: Cuida do roteamento interno de tráfego no cluster Kubernetes.  
O <b>CoreDNS</b>: Oferece resolução de nomes, essencial para que os serviços e pods possam se localizar.  
O <b>Amazon VPC CNI</b>: Conecta os pods diretamente à infraestrutura da VPC, garantindo integração nativa com outros serviços AWS.  
O<b> Amazon EKS Pod Identity Webhook</b> (também conhecido como Amazon EKS Pod Identity Agent) é um add-on do Amazon EKS que habilita o uso de IAM Roles for Service Accounts (IRSA). Esse add-on permite que os pods executados em um cluster EKS assumam funções específicas do IAM (IAM roles) usando o mapeamento de identidades, sem precisar configurar credenciais de acesso (chaves de acesso e secret keys) diretamente nos containers.

1. Clique novamente em <b>Next</b>

![](img/eks-13.png)

9. Na sessão <b>Configure selected add-ons settings</b>, clique em <b>Next</b> novamente!
> Esta sessão serve para selecionar as versões dos Add-ons, iremos deizar as versões padrão.

![](img/eks-14.png)

10. Na sessão <b>Review and create</b>, clique em <b>Create</b>.
> Esta sessão serve para revisar todas as configurações que realizamos.

![](img/eks-15.png)

11. Após clicar em <b>Create</b>, você será direcionado para o <b>Cluster</b>, repare que em <b>Status</b> o cluster está em <b>Creating</b>.
> Este passo, demora em torno de 10 minutos.

![](img/eks-16.png)

Enquanto o cluster está sendo criado iremos conhecer o <b>CloudShell</b> da AWS.

### Cloud Shell

Para gerenciar o nosso cluster, iremos utilizar o <b>CloudShell</b> serviço de Terminal Interativo da AWS.

Antes vamos entender o que é o CloudShell!

O AWS Cloud Shell é um ambiente de terminal interativo baseado no navegador que permite que você execute comandos e scripts da AWS CLI. Ele é pré-provisionado com as ferramentas e bibliotecas mais comuns que você precisa para trabalhar com a AWS, incluindo:

- Bash: O shell padrão do Linux
- Python: Uma linguagem de programação popular
- Node.js: Um ambiente de execução JavaScript
- Git: Um sistema de controle de versão
- Kubectl: Ferramenta que se conecta ao API Server para poder gerenciar clusters Kubernetes.

12. No concole da AWS, no canto inferior esquerdo, tem o ícone do Cloud Shell, clique nele!

![](img/eks-17.png)

13. Ao clicar no ícone do CloudShell ele irá provisionar um console para você poder utilizar para gerenciar os serviços da aws através de CLI (Command Line Interface).

![](img/eks-18.png)

> O CloudShell é como se fosse aqueles consoles que existe em data centers, para quem não conhece:

![](img/cd03.png)

Iremos utilizar o **CloudShell** para gerenciar o cluster.

Após alguns minutos cluster irá ficar com o status **Active**, o status indica que o cluster foi criado com sucesso.

![](img/eks-19.png)

, agora precisamos gerenciar ele, lembra que eu comentei sobre o endpoint do API Server que o cliente (kubectl) se conecta a ele para poder gerenciar o cluster, então agora iremos ver na prática.

### Conhecendo o kubectl

O kubectl é uma ferramenta de linha de comando utilizada para interagir com clusters Kubernetes. Ele permite que os usuários gerenciem aplicativos e recursos em um cluster Kubernetes, como implantações, serviços, pods, configurações, etc.

Com o kubectl, é possível implantar e escalar aplicativos, fazer rolling updates e rollbacks, gerenciar o estado dos pods e serviços, criar e gerenciar objetos personalizados, além de muitas outras tarefas relacionadas ao gerenciamento de um cluster Kubernetes.

O kubectl é uma ferramenta essencial para qualquer pessoa que trabalhe com Kubernetes, como desenvolvedores, administradores de sistemas e operadores de cluster. Ele é usado em um ambiente de terminal para interagir com o cluster Kubernetes e executar operações em qualquer nó ou componente do cluster.

Em resumo, o kubectl é a principal ferramenta de gerenciamento de Kubernetes que permite que você controle e gerencie aplicativos em um cluster Kubernetes.

O <b>CloudShell</b> já vem com o `kubectl` então não precise se preoupar com a instalação, mas caso precise instalar, acesse a documentação: [clique aqui!](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)


### Configurando o Kubectl
14. Agora iremos configurar o autocomplete do `kubectl` e o alias `k` para facilitar na administração do cluster.


Habilitando o auto complete:

```shell
cat <<'EOF' >> ~/.bashrc
# Enable alias and autocomplete
source <(kubectl completion bash)
alias k="kubectl"
complete -o default -F __start_kubectl k
EOF

source ~/.bashrc
```

![](img/eks-020.png)


15. Após configurar o alias, execute o comando abaixo no <b>CloudShell</b>, para configurar o acesso do `kubectl` ao cluster EKS:

``` shell
aws eks update-kubeconfig --region us-east-1 --name eks-lab
```
![](img/eks-021.png)

Verificando se os componentes do cluster está executando corretamente:

``` shell
kubectl cluster-info
```

![](img/eks-022.png)

1.  Verificando se o Etcd, Scheduler e o Controller-Manager está funcionando corretamente.

``` shell
kubectl get componentstatuses
```

![](img/eks-023.png)

17. Listando os nós do cluster:

``` shell
kubectl get nodes
```

![](img/eks-024.png)

A partir de agora é necessário provisionar os nodegroups!

### Provisionando os Nodes Groups

Seguindo o workflow de criação do cluster EKS, é necessário **Provisionar Node Groups**:

![](img/provisionamento-eks-03.png)

18. Volte até o seu Cluster <b>eks-lab</b>, clique em <b>Compute</b>:

![](img/eks-20.png)

1.  E clique em <b>Add</b> para adicionar um novo Node Group

![](img/eks-21.png)

20. Em <b>Name</b>, coloque o nome: `eks-lab-node-group` e em <b>Node IAM role</b>, selecione `LabRole`.

![](img/eks-22.png)

21. Clique em <b>Next</b>

![](img/eks-23.png)

22. Na sessão <b>Set compute and scaling configuration</b>, clique em <b>Next</b>

> Aqui você pode selecionar o tipo de instância, tamanho do disco, a quantidade mínima, desejada e máxima de nodes, além do update.

![](img/eks-23.png)

23. Na sessão <b>Specify networking</b> clique em <b>Next</b>

> Ele selecionará as subnets já setadas no cluster.

![](img/eks-23.png)

24. Na sessão <b>Review and create</b> Revise as configurações e clique em <b>Create</b>.

![](img/eks-24.png)

25. Ao criar o Node Group `eks-lab-node-group`, irá ficar com o status de <b>Creating</b>

> Os nós demora alguns minutos até ficarem prontos.

![](img/eks-25.png)

Após alguns minutos os nós foram criados e estão com o status de <b>Pronto</b> (Ready)

![](img/eks-26.png)

Execute o comando abaixo no CloudShell para visualizar os nós.

```shell
kubectl get nodes
```
![](img/node-eks-01.png)

26. Listando os componentes do cluster

``` shell
kubectl get all --all-namespaces
```

![](img/node-eks-02.png)

27. Listando os contextos dos clusters configurados:

``` shell
kubectl config get-contexts
```

![](img/node-eks-03.png)


O kubectl pode ser usado para configurar o contexto de um cluster no arquivo ~/.kube/config. Esse arquivo é usado pelo kubectl para determinar qual cluster, usuário e namespace devem ser usados para interagir com o cluster.

A seguir estão os principais elementos de um contexto configurado no arquivo ~/.kube/config:

`apiVersion`: a versão da API do Kubernetes usada pelo arquivo de configuração.  
`kind`: o tipo do objeto Kubernetes. Para um contexto, o tipo é Context.  
`name`: o nome do contexto.  
`context`: um objeto que define as informações de contexto para um cluster, incluindo cluster, user e namespace.  
`cluster`: um objeto que define as informações do cluster, incluindo o nome do cluster e o endpoint para se conectar ao API server.  
`user`: um objeto que define as informações de autenticação do usuário, como o nome do usuário e a chave de acesso.  
`namespace`: o namespace padrão a ser usado pelo contexto.  

Um exemplo de contexto configurado no arquivo ~/.kube/config pode ser semelhante a este:

```
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJWkxsMFErVjNVRGN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpFeE1ERXdNRE...kwySmsyd2hKUUppUHRNQ1piUlNKS3hDM2tzWkEKUkV3VExGZG5nR1owCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://SUASUGSHSUAYRSKDKSAUSA.gr7.us-east-1.eks.amazonaws.com
  name: arn:aws:eks:us-east-1:679551794714:cluster/eks-lab
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJZGg4TWlYc2xiUEV3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpFeE1ERXdOVEkwTWpCYUZ3MHp...RU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://SUASUGSHSUAYRSKDKSAUSA.gr7.us-east-1.eks.amazonaws.com
  name: arn:aws:eks:us-east-1:679551794714:cluster/abc
contexts:
- context:
    cluster: arn:aws:eks:us-east-1:679551794714:cluster/eks-lab
    user: arn:aws:eks:us-east-1:679551794714:cluster/eks-lab
  name: arn:aws:eks:us-east-1:679551794714:cluster/eks-lab
```

### Habilitando o observability do Cluster
28. No cluster clique na aba Add-ons e clique em **Get more add-ons**.

![](img/eks-27.png)

29. Marque o plugin **Amazon CloudWatch Observability**.

![](img/eks-28.png)

30. Depois clique em **Next**.

![](img/eks-29.png)

31. Clique em next novamente.

![](img/eks-30.png)

32. E por último clique em **Create**.

![](img/eks-31.png)

Aguarde a criação...

![](img/eks-32.png)

33. Após alguns minutos o status deve ficar como **Active**.

![](img/eks-33.png)

34. Agora iremos ir até o CloudWatch para visualizar o observability do Cluster.

Em serviços pesquise por **CloudWatch**, após clicar em CloudWatch clique em **Container Insights**.

![](img/eks-34.png)

35. Em [1] **Container Insights** selecione *Service: EKS*, logo após clique em [2] **View in maps**.

![](img/eks-35.png)

O Container Insights para EKS é uma ferramenta poderosa que oferece monitoramento, registro e análise abrangentes para seus containers no Amazon Elastic Kubernetes Service (EKS). Ele fornece uma visão holística da saúde e do desempenho de seus aplicativos em contêiner, permitindo que você:

- Monitoramento Abrangente
 - Solução de Problemas Eficaz
 - Otimização de Desempenho
 - Segurança Aprimorada
 - Integração com Ferramentas Existentes

Benefícios do Container Insights:

**Visibilidade Aprimorada:** Obtenha uma visão completa do seu cluster EKS e dos containers em execução.  
**Solução de Problemas Mais Rápida:** Identifique e resolva problemas de containers de forma mais rápida e eficiente.  
**Desempenho Otimizado:** Otimize o desempenho do seu cluster EKS e dos containers para obter melhores resultados.  
**Segurança Reforçada:** Proteja seus containers e cluster EKS contra ameaças à segurança.  
**Gerenciamento Simplificado:** Simplifique o gerenciamento do seu cluster EKS e dos containers em execução.

![](img/eks-36.png)

### Realizando o deploy de uma aplicação

![](img/provisionamento-eks-04.png)

Agora que já entendemos os principais componentes do Cluster, iremos realizar o deploy de uma app, essa app será basicamente uma imagem do NGINX,  O NGINX é um servidor web de código aberto que pode ser usado para servir arquivos estáticos ou atuar como um proxy reverso para outros servidores web.


36. Primeiro iremos clonar o repositório da aula no Cloud Shell.

```
cd ~/
git clone https://github.com/gersontpc/containers.git
cd ~/containers/Lab-05/02-cluster-eks/
```

![](img/eks-app-01.png)

Após clonar o repositório, na path /manifests, tem os manifestos para realizarmos o deploy.

Antes iremos preparar o ambiente criando um namespace (isolamento lógico) `nginx` para podermos realizar o deploy da nossa app.

`00-namespace.yaml`

```
---
kind: Namespace
apiVersion: v1
metadata:
  name: nginx
  labels:
    name: nginx
```
Execute o comando abaixo para criar o namespace

```kubernetes
kubectl apply -f manifests/00-namespace.yaml
```

![](img/eks-app-02.png)

37. Após a criação do namespace, iremos executar o comando para listar todos os namespaces.

``` shell
kubectl get namespace
```

![](img/eks-app-03.png)

Após ter criado o namespace iremos realizar o nosso primeiro o `01-deployment.yaml`, vamos entender os principais componentes deste manifesto.

`manifests/01-deployment.yaml`

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    rollingUpdate:
      maxSurge: 100%
      maxUnavailable: 25%
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        command: ["/bin/bash"]
        args: ["-c", "echo '<h1>This is the new Kubernetes default page!</h1>' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'"]
        restartPolicy: OnFailure
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: "100m"
            memory: "256Mi"
          requests:
            cpu: "50m"
            memory: "128Mi"

```

`apiVersion:` especifica a versão da API que está sendo utilizada, neste caso a apps/v1.  
`kind:` especifica o tipo de objeto que está sendo criado, neste caso um Deployment.  
`metadata:` contém informações de metadados do objeto, como o nome e labels para identificação.  
`replicas:` especifica o número de réplicas que serão criadas para garantir a disponibilidade da aplicação.  
`selector:` especifica o seletor de labels que será usado para identificar os Pods que fazem parte do Deployment.  
`template:` especifica o modelo para criação dos Pods do Deployment.  
`metadata:` contém as informações de metadados do Pod.  
`labels:` especifica as labels para identificação do Pod.  
`spec:` especifica as características do Pod, como os containers que serão executados dentro dele.  
`containers:` especifica o(s) container(s) que serão executados no Pod.  
`name:` especifica o nome do container.  
`image:` especifica a imagem do container que será utilizada.  
`ports:` especifica as portas que serão expostas pelo container. Neste caso, a porta 80 foi exposta.  

38. Após entender cada item do nosso manifesto, vamos utilizar ele para realizar o deploy do nosso app.


``` shell
kubectl create -f manifests/01-deployment.yaml
```

![](img/eks-app-04.png)

39. Após aplicado, iremos listar a nossa app. Repare que os pods já estão em status de Running.

``` shell
kubectl get pods -n nginx
```

![](img/eks-app-05.png)

40. Trazendo informação mais detalhada dos pods.

``` shell
kubectl get pods -n nginx -o wide
```

![](img/eks-app-06.png)

41. Conhecendo o POD da nossa app, com o comando `kubectl describe pods <pod-name>`

``` shell
kubectl describe pods nginx-6864dc595f-9jbz -n nginx
```

```shell
OUTPUT:
Name:             nginx-6864dc595f-9jbz
Namespace:        nginx
Priority:         0
Service Account:  default
Node:             ip-172-31-12-186.ec2.internal/172.31.12.186
Start Time:       Wed, 01 Nov 2023 10:34:57 +0000
Labels:           app=nginx
                  pod-template-hash=57787bb6df
Annotations:      <none>
Status:           Running
IP:               172.31.6.187
IPs:
  IP:           172.31.6.187
Controlled By:  ReplicaSet/nginx-57787bb6df
Containers:
  nginx:
    Container ID:  containerd://c35a0fa58303cdb880aa93533a72eedfed286f468cceb71e7e4d4cc3338caa4a
    Image:         nginx:latest
    Image ID:      docker.io/library/nginx@sha256:775b948ed18e931cfe48c4664387162764dcf286303bbe02bd72703f72f17f02
    Port:          80/TCP
    Host Port:     0/TCP
    Command:
      /bin/bash
    Args:
      -c
      echo '<h1>Hello K8s World</h1>' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'
    State:          Running
      Started:      Wed, 01 Nov 2023 10:35:06 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     100m
      memory:  256Mi
    Requests:
      cpu:        50m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-lxp86 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-lxp86:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m27s  default-scheduler  Successfully assigned nginx/nginx-57787bb6df-2sgx7 to ip-172-31-12-186.ec2.internal
  Normal  Pulling    3m23s  kubelet            Pulling image "nginx:latest"
  Normal  Pulled     3m19s  kubelet            Successfully pulled image "nginx:latest" in 4.843s (4.843s including waiting)
  Normal  Created    3m19s  kubelet            Created container nginx
  Normal  Started    3m18s  kubelet            Started container nginx
```

![](img/eks-app-07.png)

42. Conhecendo o nosso deploy, utilizando o comando `kubectl describe deploy <deploy-name>`, mas antes iremos pegar o nome do nosso deploy.  
Primeiro vamos realizar o `kubectl get deploy` para listar todos os deploys de todos os namespaces.


``` shell
kubectl get deploy nginx -n nginx
```

![](img/eks-app-08.png)

43. Descrevendo o deploy `nginx`.

``` shell
kubectl describe deploy nginx -n nginx
```

```shell
OUTPUT:
Name:                   nginx
Namespace:              nginx
CreationTimestamp:      Wed, 01 Nov 2023 10:34:57 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 100% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:      nginx:latest
    Port:       80/TCP
    Host Port:  0/TCP
    Command:
      /bin/bash
    Args:
      -c
      echo '<h1>Hello K8s World</h1>' > /usr/share/nginx/html/index.html && exec nginx -g 'daemon off;'
    Limits:
      cpu:     100m
      memory:  256Mi
    Requests:
      cpu:        50m
      memory:     128Mi
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-57787bb6df (3/3 replicas created)
Events:          <none>
```

![](img/eks-app-09.png)

### Expondo a aplicação

![](img/provisionamento-eks-05.png)

Para acessar a app, precisamos expor o serviço em nosso cluster apontando para os nossos pods.

Criando a service para poder acessar a app, o manifesto está na path `manifests/02-service-nginx.yaml`.
O conteúdo do manifesto é:

`manifests/02-service-nginx.yaml`


```
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: nginx
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
````

Este manifesto descreve um serviço do Kubernetes com as seguintes configurações:

`apiVersion:` a versão da API do Kubernetes usada para criar o recurso. Neste caso, é a versão "v1". 
`kind:` o tipo do recurso Kubernetes que está sendo criado. Neste caso, é um "Service".  
`metadata:` informações sobre o objeto sendo criado, incluindo um nome descritivo e rótulos que permitem que o recurso seja pesquisado e gerenciado com facilidade.  
`spec:` as especificações do serviço, incluindo sua configuração de rede e informações de porta.  
`selector:` uma seleção baseada em rótulos que identifica os pods a serem expostos pelo serviço. Neste caso, o serviço expõe todos os pods com o rótulo "app: nginx".  
`type:` o tipo de serviço a ser criado. Neste caso, é um LoadBalancer, que permite fazer o balanceamento de carga entre os ips dos nós  
`ports:` as portas expostas pelo serviço. Neste caso, uma única porta é exposta com o nome "http" e mapeada para a porta 80 nos pods correspondentes à seleção de rótulo do serviço.


41. Após entender cada item do nosso manifesto, vamos utilizar ele para realizar o deploy da nossa service.

``` shell
kubectl apply -f manifests/02-service-nginx.yaml
```

![](img/eks-app-10.png)

44. Antes de acessar o app pelo browser, vamos liberar o security group dos Node Groups para acessar a app, vá até o cluster EKS, aba <b>Networking</b> e em <b>Cluster security group</b>, clique no id do security group [sg-00e6a5104f3b24d2a].

![](img/eks-37.png)

45. Na aba <b>Inbound rules</b> clique em <b>Edit inbound rules</b>

![](img/eks-38.png)

46. [1] Clique em <b>Add rule</b>, [2] selecione a regra <b>HTTP</b>, libere para qualquer origem <b>0.0.0.0/0</b>, [3] clique em <b>Save rules</b>, para salvar a regra.

![](img/eks-39.png)

47. Acessado a nossa "app" via Load Balancer.

``` shell
kubectl get service nginx -n nginx -o wide
```

![](img/eks-app-11.png)

Repare que a nossa service `nginx` foi criada com sucesso.

48. Agora vamos acessar o app através do navegador, digite a url do Load Balancer:

```
http://a065bc940eaf2407487fc94629c5535c-89993584.us-east-1.elb.amazonaws.com/
```
![](img/eks-40.png)

Sucesso! conseguimos acessar a nossa app.

### Escalando os PODs

49. Para escalar os pods iremos executar o comando `kubectl scale deployment`, atualmente temos 2 répicas e iremos aumentar para 8 réplicas.

``` shell
kubectl scale deployment nginx --replicas=8 -n nginx
```

![](img/eks-app-12.png)

50. Checando se foi escalado corretamente.

``` shell
kubectl get pods -n nginx
```

```shell
OUTPUT:
NAME                     READY   STATUS              RESTARTS   AGE
nginx-57787bb6df-2sgx7   1/1     Running             0          128m
nginx-57787bb6df-dk7wt   0/1     ContainerCreating   0          3s
nginx-57787bb6df-k27wr   1/1     Running             0          128m
nginx-57787bb6df-lvrp4   1/1     Running             0          128m
nginx-57787bb6df-m5kch   0/1     ContainerCreating   0          3s
nginx-57787bb6df-r2sgf   0/1     ContainerCreating   0          3s
nginx-57787bb6df-r4qzq   0/1     ContainerCreating   0          3s
nginx-57787bb6df-sn64c   0/1     ContainerCreating   0          3s
```

51. Repare que os containers foram escalados para 8 réplicas.

``` shell
kubectl get pods -n nginx
```

![](img/eks-app-13.png)

Pronto os PODs foram escalados com sucesso!

52. Vamos voltar para duas réplicas.

``` shell
kubectl scale deployment nginx --replicas=2 -n nginx
```

```shell
OUTPUT:
deployment.apps/nginx scaled
```

### Realizando rollback de versão

53. Para realizar o rollback da versão iremos aplicar o manifesto `manifests/deployment-v1.yaml`

``` shell
kubectl apply -f manifests/03-deployment-v1.yaml
```

![](img/eks-app-14.png)

54. Execute o curl para verificar se alterou a página do nosso webserver.

``` shell
curl http://a0d10f8234df541fc807413cb72fe8dc-844940680.us-east-1.elb.amazonaws.com/

<h1>Deploy V1!</h1>
```

Ou acesse pelo browser:  
![](img/deploy-v1.png)

55. Após realizar o deploy, vamos realizar o deploy do `manifests/deployment-v2.yaml`

``` shell
kubectl apply -f manifests/04-deployment-v2.yaml
```

![](img/eks-app-16.png)

56. Execute o curl para verificar se alterou a versão.

``` shell
curl http://a065bc940eaf2407487fc94629c5535c-89993584.us-east-1.elb.amazonaws.com/

<h1>Deploy V2!</h1>
```
Ou acesse pelo browser:  
![](img/deploy-v2.png)

57. Repare que os pods estão recém criados:
``` shell
kubectl get pods -l app=nginx -n nginx
```

![](img/eks-app-15.png)

58.  Agora iremos realizar o Rollback para a versão 1 do nosso deployment. O Deployment cria uma revisão a cada alteração no deploy, para listar essas versões iremos utilizar o `kubectl rollout history`:

``` shell
kubectl rollout history deploy nginx -n nginx
```

![](img/eks-app-17.png)

59. Agora vamos realizar o rollback para a versão 2 da nossa app.

``` shell
kubectl rollout undo deployment/nginx --to-revision=1 -n nginx
```

![](img/eks-app-18.png)

60. Vamos checar se ele alterou para a versão que fizemos a nossa alteração:

    Realize o curl para verificar se estamos na Versão 2 da app, lembrando que na linha do tempo a versão 2 do histório de deploy, deve retornar a página com a frase <b>Deploy V1!</b>.

``` shell
curl http://a0d10f8234df541fc807413cb72fe8dc-844940680.us-east-1.elb.amazonaws.com/

<h1>Deploy V1!</h1>
```
Ou acesse pelo browser:  
![](img/deploy-v1.png)

Pronto, agora você acabou de aprender a fazer rollback para uma versão específica da sua app.


### Finalizando o Lab

Agora é hora de limpar a casa! :)

Vamos deletar os objetos que criamos dentro do nosso cluster Kubernetes

61. Deletando a Service:

``` shell
kubectl delete -f manifests/02-service-nginx.yaml

service "nginx" deleted
```

62. Deletendo o Deployment:

``` shell
kubectl delete -f manifests/01-deployment.yaml
```

```shell
OUTPUT:
deployment.apps "nginx" delete
```

Excluindo o <b>Node Group</b> do Cluster EKS.

63. Acesse o serviço [EKS](https://us-east-1.console.aws.amazon.com/eks/home?region=us-east-1#/clusters)

![](img/eks-01.png)

64. Clique no cluster do lab `eks-lab`

![](img/eks-41.png)

65. Clique na aba <b>Compute</b>

![](img/eks-42.png)

66. Desça até <b>Node groups</b>, selecione o `eks-lab-node-group` e clique em <b>Delete</b>

![](img/eks-43.png)

67. Por questão de segurança você precisa colocar o nome do node group para ter certeza que precisa deletar ele (isso evita a deleção acidental), depois clique em <b>Delete</b>!

![](img/eks-44.png)

68. Agora basta esperar alguns minutos para realizar a deleção  

![](img/eks-45.png)

69. Pronto, após a deleção do node group, iremos realizar a deletar o Cluster, no cluster clique em <b>Delete cluster</b>.

![](img/eks-46.png)

70. Para deletar coloque o nome do cluster <b>eks-lab</b> para confirmar a deleção, logo em seguida clique em <b>Delete</b>

![](img/eks-47.png)

71. Após confirmar a deleção, o cluster será deletado em alguns minutos.

![](img/eks-48.png)


### Conclusão
Pronto, você acaba de concluir o laboratório de hands-on de EKS!

Durante este laboratório, você aprendeu como criar um cluster EKS e alguns dos principais componentes que compõem um cluster Kubernetes. Você também aprendeu como criar um namespace, deployment, service do tipo load balancer e realizar o scaling e rollback de versão da app.

Este conhecimento é fundamental para quem deseja entender e trabalhar com Kubernetes, uma das plataformas mais utilizadas no mundo para orquestração de containers. Esperamos que este laboratório tenha sido útil para você e que agora você se sinta mais confiante para trabalhar com Kubernetes em seu ambiente. Parabéns novamente e continue praticando!
