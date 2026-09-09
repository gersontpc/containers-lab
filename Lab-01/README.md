# Lab-01 — Construindo e publicando uma imagem Docker

## Contexto

Imagine que sua equipe precisa entregar uma página web e executá-la em diferentes ambientes. Copiar apenas o HTML não define qual servidor deve atendê-lo nem como iniciá-lo. Uma imagem Docker reúne a aplicação e seu ambiente de execução em um artefato que pode ser versionado e distribuído.

Neste laboratório, você vai empacotar uma página da FIAP em uma imagem baseada no NGINX, executá-la em um contêiner e publicá-la no Docker Hub. Todo o trabalho será feito no terminal do **GitHub Codespaces**, pelo navegador, sem instalar Docker na sua máquina.

**Duração estimada:** 45 a 60 minutos.

## Objetivo

Ao concluir o laboratório, você será capaz de:

- Diferenciar Dockerfile, imagem, contêiner e registry.
- Construir uma imagem com uma página HTML personalizada.
- Executar, inspecionar e remover contêineres usando a CLI do Docker.
- Explicar a diferença entre a porta do contêiner e a porta publicada no host.
- Acessar a aplicação pelo encaminhamento de portas do Codespaces.
- Publicar uma imagem versionada no Docker Hub e executá-la novamente a partir do registry.

## Conceitos essenciais

| Conceito | Papel neste laboratório |
| --- | --- |
| Dockerfile | Receita que define a imagem base e os arquivos da aplicação. |
| Imagem | Pacote usado como base para criar contêineres; aqui, NGINX e a página HTML. |
| Contêiner | Instância de uma imagem, com seus processos e uma camada gravável própria. |
| Registry | Serviço que armazena e distribui imagens, como o Docker Hub. |
| Tag | Identificador de uma imagem, como `v1.0.0`. Tags podem ser reutilizadas; não são imutáveis. |
| Contexto de build | Arquivos disponibilizados ao build. Neste roteiro, será a pasta `Lab-01/site`. |

O fluxo será: **arquivos → build → imagem → contêiner → validação → push → Docker Hub**.

## Pré-requisitos

- Conta no [GitHub](https://github.com/) com acesso ao repositório e ao GitHub Codespaces.
- Cota disponível ou faturamento habilitado para Codespaces, conforme sua conta ou organização. Consulte o [uso incluído do Codespaces](https://docs.github.com/en/codespaces/troubleshooting/troubleshooting-included-usage).
- Conta no [Docker Hub](https://hub.docker.com/) para a etapa de publicação.
- Navegador e familiaridade básica com comandos de terminal.

## 1. Preparar o GitHub Codespaces

1. Abra [este repositório no GitHub](https://github.com/gersontpc/containers-lab). Se quiser salvar os exercícios na sua própria conta, crie um fork e abra-o.
2. Selecione a branch que contém este roteiro.
3. Clique em **Code → Codespaces → Create codespace on &lt;branch&gt;**.
4. Aguarde o VS Code abrir no navegador e a preparação do ambiente terminar.
5. Abra **Terminal → New Terminal**.

Sem uma configuração própria de dev container, o Codespaces usa a [imagem padrão de desenvolvimento](https://docs.github.com/en/codespaces/about-codespaces/deep-dive). A [configuração da imagem universal](https://github.com/devcontainers/images/blob/main/src/universal/.devcontainer/devcontainer.json) inclui suporte a Docker. Valide o ambiente antes de continuar:

```
pwd
docker version
docker info
```

**Resultado esperado:** `pwd` aponta para o repositório em `/workspaces/`, `docker version` apresenta as seções `Client` e `Server`, e `docker info` retorna informações do daemon sem erro de conexão.

Execute os próximos comandos no mesmo terminal. Partindo da raiz do repositório, crie uma pasta para o exercício:

```
mkdir -p Lab-01/site
cd Lab-01/site
```

O repositório já está disponível no Codespaces; não é necessário cloná-lo novamente. Se abrir outro terminal, retorne a essa pasta antes de continuar.

## 2. Criar a página e o Dockerfile

Crie uma página HTML usando o terminal integrado:

```
cat > index.html <<'EOF_HTML'
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>FIAP | Lab-01</title>
</head>
<body>
  <h1>FIAP — Orquestração de Containers e Kubernetes</h1>
  <p>Minha primeira imagem Docker no GitHub Codespaces.</p>
  <p>Versão da aplicação: v1.0.0</p>
</body>
</html>
EOF_HTML
```

Crie o `Dockerfile` no mesmo diretorio:

```
cat > Dockerfile <<'EOF_DOCKERFILE'
FROM nginx:stable-alpine
LABEL org.opencontainers.image.title="FIAP Lab-01"
LABEL org.opencontainers.image.description="Página de exemplo servida pelo NGINX"
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF_DOCKERFILE
```

| Instrução | O que faz neste exemplo |
| --- | --- |
| `FROM nginx:stable-alpine` | Usa a variante Alpine da imagem oficial do NGINX como base. Essa tag acompanha atualizações; para fixar exatamente uma base, use seu digest. |
| `LABEL` | Adiciona metadados à imagem. A instrução antiga `MAINTAINER` está obsoleta. |
| `COPY` | Copia o HTML do contexto de build para o diretório servido pelo NGINX. |
| `EXPOSE 80` | Documenta a porta utilizada pela aplicação. Não publica a porta no host. |
| `CMD` | Define o comando padrão para manter o NGINX em primeiro plano. A imagem base fornece seu próprio `ENTRYPOINT`, que é preservado. |

O processo principal precisa permanecer ativo: quando ele termina, o contêiner para. `daemon off;` mantém o NGINX em primeiro plano, enquanto o `-d` de `docker run` libera o terminal para você.

Outras instruções úteis para próximos exercícios:

| Instrução | Finalidade |
| --- | --- |
| `RUN` | Executar comandos durante o build, como instalar dependências. |
| `WORKDIR` | Definir o diretório de trabalho das instruções seguintes. |
| `ENV` | Definir variáveis de ambiente disponíveis no contêiner. |
| `ARG` | Declarar parâmetros de build; não usar para segredos. |
| `USER` | Definir o usuário para as instruções seguintes e a execução. |
| `ENTRYPOINT` | Definir o executável principal, que pode receber argumentos de `CMD`. |
| `HEALTHCHECK` | Definir uma verificação periódica de saúde do contêiner. |
| `ADD` | Copiar conteúdo com recursos adicionais, como extração de arquivos locais; prefira `COPY` para cópias simples. |

Consulte a [referência de Dockerfile](https://docs.docker.com/reference/dockerfile/) para detalhes.

## 3. Construir a imagem

Construa a imagem no ambiente Docker do Codespaces usando o formato `<usuario-dockerhub>/<repositorio>:<tag>`. Essa identificação será utilizada depois para publicá-la no Docker Hub.

Substitua `seu-usuario-dockerhub` pelo seu **Docker ID**, não pelo e-mail nem necessariamente pelo usuário do GitHub:

```
export DOCKERHUB_USER="seu-usuario-dockerhub"
export IMAGE_NAME="$DOCKERHUB_USER/container-technologies"
docker build -t "$IMAGE_NAME:v1.0.0" .
```

- `-t` atribui a referência `usuario/container-technologies:v1.0.0` à imagem local: `usuario` é a conta do Docker Hub, `container-technologies` é o repositório de destino e `v1.0.0` é a tag da versão.
- O `.` indica a pasta atual como contexto de build, contendo `Dockerfile` e `index.html`.
- No primeiro build, o Docker baixa a imagem base. Builds posteriores podem aproveitar o cache.

Confira a imagem criada:

```
docker image ls "$IMAGE_NAME"
```

**Resultado esperado:** a imagem aparece na listagem local com `usuario/container-technologies` na coluna `REPOSITORY` e `v1.0.0` na coluna `TAG`. O build ainda não envia nada ao Docker Hub. ID, tamanho e tempo de criação variam conforme o ambiente e a versão da base.

## 4. Executar e acessar a aplicação

```
docker run -d --name lab01-web -p 8080:80 "$IMAGE_NAME:v1.0.0"
docker ps --filter name=lab01-web
curl -fsS http://localhost:8080
```

**Resultado esperado:** contêiner com status `Up`, mapeamento `8080->80/tcp` e o HTML da página no retorno do `curl`.

| Opção | Significado |
| --- | --- |
| `-d` | Executa em segundo plano e devolve o controle do terminal. |
| `--name lab01-web` | Define um nome para usar nos próximos comandos. |
| `-p 8080:80` | Publica a porta `80` do contêiner na porta `8080` do host Docker no Codespaces. |

Para visualizar a página no navegador:

1. Abra a aba **PORTS / Portas**, no painel inferior do VS Code.
2. Se a porta `8080` não aparecer, clique em **Forward a Port / Encaminhar uma Porta** e informe `8080`.
3. Mantenha a visibilidade **Private / Privada** e use **Open in Browser / Abrir no Navegador**.
4. Verifique o título da FIAP e a versão `v1.0.0`.

O caminho da requisição é: **navegador → URL encaminhada do Codespaces → porta 8080 → porta 80 do contêiner → NGINX**.

`localhost:8080` funciona no terminal remoto. No navegador da sua máquina, use a URL gerada pelo Codespaces, normalmente terminada em `-8080.app.github.dev`. Consulte o [encaminhamento de portas](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace).

## 5. Inspecionar o contêiner e seu ciclo de vida

Veja os logs e confirme o arquivo dentro do contêiner:

```
docker logs --tail 20 lab01-web
docker exec lab01-web cat /usr/share/nginx/html/index.html
```

Para explorar interativamente:

```
docker exec -it lab01-web /bin/sh
```

Dentro do contêiner, execute:

```sh
ls /usr/share/nginx/html
cat /usr/share/nginx/html/index.html
exit
```

O `exit` encerra apenas esse shell; o NGINX continua em execução. De volta ao terminal do Codespaces, teste a parada e a retomada:

```
docker stop lab01-web
docker ps -a --filter name=lab01-web
docker start lab01-web
curl -fsS http://localhost:8080
```

**Observe:** após `stop`, o status é `Exited`. `docker ps` lista apenas contêineres em execução; `docker ps -a` inclui os parados. `start` reinicia o mesmo contêiner, enquanto `run` cria um novo.

## 6. Publicar no Docker Hub

No terminal do Codespaces, autentique-se no Docker Hub:

```
docker login
```

Siga o fluxo exibido no terminal: abra a URL indicada no navegador e confirme o código com a conta correspondente a `$DOCKERHUB_USER`. Aguarde `Login Succeeded`. O fluxo padrão está descrito na [documentação de login](https://docs.docker.com/reference/cli/docker/login/).

Se precisar autenticar explicitamente pelo Docker ID, use `docker login --username "$DOCKERHUB_USER"` e informe um [token de acesso pessoal](https://docs.docker.com/security/access-tokens/personal-access-tokens/) com permissão de escrita no prompt de senha. Não coloque o token no Dockerfile, no HTML ou em comandos salvos no repositório.

Publique a imagem no repositório `container-technologies` da sua conta no Docker Hub:

```
docker push "$IMAGE_NAME:v1.0.0"
```

**Resultado esperado:** envio ou reutilização das camadas e exibição de um digest `sha256:...`. No Docker Hub, abra o repositório e confirme a tag `v1.0.0` na aba **Tags**.

O push publica a imagem; não publica o contêiner em execução nem suas alterações posteriores.

## 7. Validar a imagem publicada

Remova o contêiner do exercício e sua referência local à imagem. Depois baixe a imagem do Docker Hub e execute-a novamente:

```
docker stop lab01-web
docker rm lab01-web
docker image rm "$IMAGE_NAME:v1.0.0"
docker pull "$IMAGE_NAME:v1.0.0"
docker run -d --name lab01-web -p 8080:80 "$IMAGE_NAME:v1.0.0"
curl -fsS http://localhost:8080
```

**Resultado esperado:** a mesma página disponível após o pull. O Docker pode reutilizar camadas locais; não é necessário apagar todo o cache para validar a imagem publicada.

## 8. Desafio: publicar uma segunda versão

1. Edite `Lab-01/site/index.html` no VS Code: personalize a mensagem e troque a versão exibida para `v1.1.0`. Salve o arquivo.
2. Atualize a página no navegador **antes de reconstruir**. Ela ainda mostra a versão anterior, pois `COPY` copiou o arquivo durante o build; não há sincronização com o arquivo local.
3. No terminal, ainda em `Lab-01/site`, execute:

```
docker build -t "$IMAGE_NAME:v1.1.0" .
docker stop lab01-web
docker rm lab01-web
docker run -d --name lab01-web -p 8080:80 "$IMAGE_NAME:v1.1.0"
curl -fsS http://localhost:8080
docker push "$IMAGE_NAME:v1.1.0"
```

Confirme a nova mensagem no navegador e as duas tags no Docker Hub.

**Para refletir:** por que apenas reiniciar o contêiner antigo não atualiza a página? O que seria necessário para voltar à versão `v1.0.0`? Qual a vantagem de usar tags diferentes para cada entrega?

## 9. Limpar e encerrar o ambiente

Remova os recursos criados no exercício:

```
docker stop lab01-web
docker rm lab01-web
docker image rm "$IMAGE_NAME:v1.0.0"
docker logout
```

Se realizou o desafio, remova também a segunda imagem:

```
docker image rm "$IMAGE_NAME:v1.1.0"
```

Esses comandos não removem as tags publicadas no Docker Hub nem os arquivos em `Lab-01/site`.

Para encerrar o Codespaces, abra a paleta de comandos do VS Code e selecione **Codespaces: Stop Current Codespace**, ou use **Stop codespace** no menu do ambiente em [github.com/codespaces](https://github.com/codespaces). Fechar a aba do navegador não garante a parada imediata.

Um codespace parado ainda ocupa armazenamento. Se terminou o laboratório, salve os arquivos que deseja manter fora do ambiente ou faça commit e push no seu fork antes de selecionar **Delete**. Consulte o [ciclo de vida do Codespaces](https://docs.github.com/en/codespaces/about-codespaces/understanding-the-codespace-lifecycle) para entender parada, retenção e exclusão.

## Problemas comuns

| Sintoma | Como investigar ou resolver |
| --- | --- |
| `docker: command not found` ou erro de conexão com o daemon | Confirme que está no terminal do Codespaces e que a preparação terminou. Reinicie o codespace; se persistir, verifique os logs de criação e se o fork usa uma configuração de dev container diferente da padrão. |
| `Dockerfile` ou `index.html` não encontrado no build | Execute `pwd` e `ls`; os dois arquivos devem estar em `Lab-01/site`, de onde o build é executado. |
| Nome `lab01-web` já está em uso | Consulte `docker ps -a --filter name=lab01-web`. Use `docker start lab01-web` para retomar o existente ou pare e remova esse contêiner antes de recriá-lo. |
| Porta `8080` já está ocupada | Verifique `docker ps`. Se precisar usar `-p 8081:80`, encaminhe a porta `8081` no Codespaces e ajuste a URL do `curl`. |
| Página não abre no navegador | Teste `curl -fsS http://localhost:8080`, confira `docker logs lab01-web` e verifique a aba **Ports**. Para uma porta privada, use o navegador autenticado na conta dona do codespace. |
| `curl` falha logo após `docker run` | O servidor pode ainda estar iniciando. Aguarde alguns segundos e repita; se persistir, consulte `docker ps -a` e os logs. |
| Push retorna `denied` ou `unauthorized` | Execute `echo "$IMAGE_NAME"` e confira se o usuário antes de `/container-technologies` corresponde à conta autenticada no Docker Hub e se ela tem permissão de escrita no repositório. |
| Variável vazia ou erro `invalid reference format` | Se abriu outro terminal, redefina `DOCKERHUB_USER` e `IMAGE_NAME` conforme a etapa 3. |
| Alteração no HTML não aparece | Salve o arquivo, reconstrua a imagem e recrie o contêiner com a nova tag. |

## Critérios de conclusão

- [ ] A imagem foi construída no Docker do Codespaces e aparece em `docker image ls` com a referência `<seu-usuario-dockerhub>/container-technologies:v1.0.0`.
- [ ] A página foi acessada pela porta encaminhada do Codespaces.
- [ ] Você consultou logs, acessou o contêiner e testou `stop` e `start`.
- [ ] A tag foi publicada no Docker Hub e executada novamente após o pull.
- [ ] Você consegue explicar por que `EXPOSE 80` não substitui `-p 8080:80`.
- [ ] Os recursos do exercício foram removidos e o codespace foi parado ou excluído.

Para registrar a atividade, guarde uma captura da página, a saída de `docker image ls` e o link da tag no seu Docker Hub, antes da limpeza. Não inclua credenciais nos registros.
