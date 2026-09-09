# Lab-02 — Docker Compose no GitHub Codespaces

## Contexto e objetivo

Aplicações com múltiplos serviços precisam de uma definição consistente de rede, persistência e configuração. O Docker Compose descreve esses componentes em YAML e permite gerenciar seu ciclo de vida em conjunto.

Neste laboratório, você vai executar WordPress e MariaDB no GitHub Codespaces, verificar a comunicação entre os serviços, acessar a aplicação pelo navegador e aplicar limites de CPU e memória. O serviço do banco se chama `mysql` nos arquivos, mas utiliza a imagem do **MariaDB**.

## 1. Preparar o ambiente no GitHub Codespaces

Você precisa de uma conta GitHub com acesso ao Codespaces e cota disponível ou faturamento habilitado para utilizá-lo. O exercício utiliza o ambiente remoto do Codespaces, sem necessidade de uma conta AWS ou instalação local do Docker.

1. Abra [o repositório do laboratório](https://github.com/gersontpc/containers-lab) ou seu fork no GitHub.
2. Selecione a branch com este laboratório e clique em **Code → Codespaces → Create codespace on &lt;branch&gt;**.
3. Aguarde a preparação do ambiente e a abertura do VS Code no navegador.
4. Abra **Terminal → New Terminal** e valide as ferramentas:

```
docker version
docker info
docker compose version
```

O comando `docker version` deve apresentar `Client` e `Server`, e `docker compose version` deve informar a versão instalada. Se houver erro de conexão com o Docker, aguarde a preparação terminar e tente novamente. Se persistir, reinicie o codespace e confira os logs de criação do ambiente.

Este repositório utiliza o ambiente padrão do Codespaces, que inclui Docker. Consulte a [documentação do ambiente de desenvolvimento](https://docs.github.com/en/codespaces/about-codespaces/deep-dive).

O repositório já está clonado no ambiente. Partindo da raiz, acesse a pasta do laboratório:

```
cd Lab-02
ls
```

Confira a presença de `compose.yml` e `compose-limits.yml`. Execute os próximos comandos nessa pasta.

## 2. Conhecer e iniciar a stack

Abra [compose.yml](compose.yml) no editor e observe:

| Componente | Configuração |
| --- | --- |
| `mysql` | Executa o MariaDB e armazena os dados no volume `database`. |
| `wordpress` | Executa a aplicação e armazena seus arquivos no volume `wordpress`. |
| Rede `wordpress` | Permite que a aplicação encontre o banco pelo nome do serviço `mysql`. |
| `WORDPRESS_DB_HOST` | Define `mysql` como endereço do banco na rede interna do Compose. |
| `8080:80` | Publica a porta HTTP do WordPress na porta 8080 do ambiente Docker. |
| `depends_on` | Define a ordem de inicialização; nesta configuração, não espera o banco estar pronto para conexões. |

As credenciais presentes nos arquivos são exemplos de laboratório. Em produção, utilize gerenciamento de segredos e credenciais próprias.

Valide a configuração e inicie os serviços:

```
docker compose config --quiet
docker compose up -d
docker compose ps
docker compose logs --tail 50 mysql wordpress
```

**Resultado esperado:** os serviços `mysql` e `wordpress` em execução e a porta `8080` publicada pelo WordPress. Na primeira execução, o download das imagens e a inicialização do banco podem levar alguns minutos.

Teste a resposta HTTP pelo terminal remoto:

```
curl -I http://localhost:8080
```

Uma resposta HTTP, inclusive um redirecionamento para a instalação, indica que o servidor está atendendo. Se a aplicação informar erro de conexão com o banco, aguarde a inicialização do MariaDB e consulte os logs novamente.

## 3. Acessar o WordPress pelo Codespaces

1. No painel inferior do VS Code, abra a aba **PORTS / Portas**.
2. Se a porta `8080` não aparecer, clique em **Forward a Port / Encaminhar uma Porta** e informe `8080`.
3. Mantenha a visibilidade **Private / Privada** e clique em **Open in Browser / Abrir no Navegador**.
4. Use o navegador autenticado na conta GitHub que criou o codespace.

O Codespaces gera uma URL como `https://<nome-do-codespace>-8080.app.github.dev`. Use essa URL para instalar e acessar o WordPress. `localhost:8080` refere-se ao ambiente remoto quando utilizado no terminal do Codespaces.

O tráfego segue este caminho: **navegador → porta encaminhada do Codespaces → porta 8080 do host Docker → porta 80 do WordPress**. A porta `3306` do banco fica na rede interna; não precisa ser encaminhada.

Mantenha o protocolo de encaminhamento como **HTTP**, pois o WordPress deste exercício atende HTTP internamente; a URL externa do Codespaces utiliza HTTPS. Veja a [documentação de encaminhamento de portas](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace).

## 4. Configurar o WordPress

1. Selecione **Português do Brasil** e clique em **Continuar**.
2. Preencha o título do site, por exemplo, `Container Technologies`.
3. Defina o usuário administrador, por exemplo, `wpuser`, e registre a senha gerada na instalação.
4. Informe seu e-mail e clique em **Instalar WordPress**.
5. Faça login com o usuário e a senha que você acabou de configurar.
6. No painel administrativo, clique no nome do site para visualizar a página inicial.

**Resultado esperado:** acesso ao painel administrativo e à página pública do WordPress pela URL encaminhada. A senha do administrador é definida nessa instalação e é independente da senha do banco no Compose.

## 5. Verificar a persistência dos dados

Crie e publique um post de teste no WordPress. Depois, no terminal, remova e recrie os contêineres:

```
docker compose down
docker compose up -d
```

Aguarde os serviços iniciarem e abra o site novamente pela mesma URL. O post e a configuração devem continuar disponíveis, porque `down` preserva os volumes nomeados por padrão.

A camada gravável do contêiner é descartada quando ele é removido; os dados armazenados nos volumes permanecem disponíveis para os novos contêineres.

## 6. Aplicar limites de recursos

O arquivo [compose-limits.yml](compose-limits.yml) contém a stack completa e acrescenta ao serviço WordPress o limite de **1 CPU** e **512 MB de memória**, além das reservas declaradas. O serviço MariaDB permanece sem limites explícitos nesse arquivo.

Aplique essa configuração ao mesmo projeto:

```
docker compose -f compose-limits.yml config --quiet
docker compose -f compose-limits.yml up -d
docker compose -f compose-limits.yml ps
docker stats --no-stream
```

Para conferir os limites efetivamente configurados no contêiner do WordPress:

```
docker inspect --format 'CPU (NanoCpus): {{.HostConfig.NanoCpus}} | Memória (bytes): {{.HostConfig.Memory}}' "$(docker compose -f compose-limits.yml ps -q wordpress)"
```

**Resultado esperado:** `1000000000` em `NanoCpus` e `536870912` em memória, correspondentes a 1 CPU e 512 MiB. O consumo mostrado por `docker stats` varia conforme a carga. As reservas declaradas não significam recursos exclusivos garantidos nesse ambiente compartilhado.

Use `-f compose-limits.yml` nos próximos comandos para manter explícita a configuração escolhida.

### Por que não escalar o banco com `--scale mysql=3`?

Esse comando criaria três processos de banco usando o mesmo volume `database`. Isso não configura replicação e pode causar conflitos de acesso aos arquivos. Mantenha uma instância do banco neste exercício. Escalar um banco exige configuração própria de replicação ou cluster e armazenamento adequado para cada instância.

O WordPress também utiliza uma porta fixa no host (`8080`), que não pode ser publicada simultaneamente por várias réplicas. Escalar a aplicação exigiria rever a publicação de portas e o balanceamento de tráfego.

## 7. Limpar e encerrar o ambiente

Para remover os contêineres e a rede do projeto, preservando os dados:

```
docker compose -f compose-limits.yml down
```

Se terminou o exercício e deseja **apagar também o banco, os posts e os arquivos do WordPress**, execute:

```
docker compose -f compose-limits.yml down --volumes
```

Encerre o ambiente pela paleta de comandos, em **Codespaces: Stop Current Codespace**, ou pelo menu **Stop codespace** em [github.com/codespaces](https://github.com/codespaces). Fechar apenas a aba não garante a parada imediata.

O codespace parado ainda utiliza armazenamento. Antes de excluí-lo, salve os arquivos que deseja manter ou faça commit e push no seu fork. Consulte o [ciclo de vida do Codespaces](https://docs.github.com/en/codespaces/about-codespaces/understanding-the-codespace-lifecycle).

## Problemas comuns

| Sintoma | Verificação |
| --- | --- |
| Porta 8080 ocupada | Use `docker ps` e verifique se o contêiner do Lab-01 ainda está usando essa porta. Pare-o antes de iniciar a stack. |
| Site não abre | Confira `docker compose ps`, os logs e o encaminhamento da porta 8080. |
| Erro de conexão com o banco | Aguarde a inicialização do MariaDB e confira as credenciais nos dois serviços. Alterar as variáveis não redefine um banco já inicializado em volume. |
| Contêiner reiniciando | Consulte `docker compose logs --tail 100 mysql wordpress` para identificar o erro. |
| Login do WordPress inválido | Utilize a senha definida na instalação do site, não a senha de exemplo do MariaDB. |
| Site redireciona para URL antiga | Reutilize o codespace em que instalou o site. O WordPress persiste sua URL no banco; mudar de endereço exige atualizar essa configuração ou reiniciar a instalação com novos volumes, caso os dados sejam descartáveis. |

Após aplicar os limites, acrescente `-f compose-limits.yml` aos comandos Compose de diagnóstico.

## Critérios de conclusão

- [ ] WordPress e MariaDB estão em execução no Codespaces.
- [ ] O site e o painel administrativo foram acessados pela porta encaminhada.
- [ ] Um post foi preservado após recriar os contêineres.
- [ ] Os limites do WordPress foram aplicados e conferidos.
- [ ] Você consegue explicar o papel da rede interna e dos volumes.
- [ ] A stack foi encerrada e o codespace foi parado ou excluído.
