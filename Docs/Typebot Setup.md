Inclusão de containers de Typebot
=================================

Arquivo de Configuração
-----------------------

O arquivo `.env-integrations` deve definir algumas variáveis.

Este arquivo deve existir antes de acionar a instalação dos containers.

### Variáveis a serem configuradas

#### Hostnames

Os três hostnames a seguir precisam estar com o DNS configurado de acordo, todos 
apontando para o mesmo servidor onde está sendo feita a instalação.

> `TYPEBOT_BUILDER_HOST`
> 
> Hostname que hospedará o módulo "Builder" do typebot. É este hostname que será acessado
> para construir os fluxos.

> `TYPEBOT_VIEWER_HOST`
>
> Hostname que hospedará o módulo "Viewer" do typebot. É este hostname que será
> utilizado nas configurações da fila do Ticketz para indicar a URL do typebot
> a ser executado.

> `MINIO_HOST`
> 
> Hostname que hospedará a API S3 do componente Minio. Este host será utilizado pelo
> Typebot para armazenar arquivos a serem enviados e recebidos.

#### Configuração SMTP

O arquivo `.env-integrations` ainda precisa de informações necessárioas
para o correto funcionamento do envio de email pelo Typebot. Isso é muito
importante pois todas as autorizações de acesso são validadas por um
código enviado por email.

#### Arquivo de exemplo:

Você pode usar esse exemplo como base para configurar o arquivo `.env-integrations`
lembrando de substituir pelos valores adequados.

```
TYPEBOT_BUILDER_HOST=typebot.example.com
TYPEBOT_VIEWER_HOST=typebot-viewer.example.com
MINIO_HOST=minio.example.com

SMTP_FROM=email@example.com
SMTP_USERNAME=email@example.com
SMTP_PASSWORD=GoodPass
SMTP_HOST=mail.example.com
SMTP_PORT=587
SMTP_SECURE=true
```

Arquivo de "segredos" e outras configurações geradas
----------------------------------------------------

O arquivo `.env-secrets` é gerado automaticamente na execução do comando de
instalação e não deve ser alterado manualmente sob o risco de perder
acesso a arquivos e configurações encriptados

Instalação
----------

A instalação do typebot só está disponível como um upgrade da instalação
do Ticketz PRO.

Antes de executar o comando é preciso ir até a pasta `ticketz-docker-acme`
e criar o arquivo `.env-integrations` conforme o exemlo.

É possível usar o arquivo `example.env-integrations` como base:

```bash
cd ~/ticketz-docker-acme
sudo cp example.env-integrations .env-integrations
sudo vi .env-integrations
```

Após configurar todas as variáveis basta executar o comando de instalação do
typebot:

```bash
curl -sSL in.ticke.tz | sudo bash
```

Após alguns minutos todos os serviços estarão disponíveis. 

As credenciais geradas serão mostradas na tela e é recomendado anotá-las para
referência futura.

Serviços Instalados
-------------------

### Typebot Builder

No endereço informado na variável `TYPEBOT_BUILDER_HOST` fica acessível o
construtor de fluxos


### Typebot Viewer

O módulo "Viewer" do typebot é utilizado indiretamente apenas, usando o hostname
informado na variável `TYPEBOT_VIEWER_HOST`

### Minio Console

A console do servidor S3 Minio estará acessível com o mesmo host do frontend do
Ticketz apenas adicionando `/minio` ao caminho.

Normalmente não é necessário acessar, porém pode ser interessante para
observar a utilização de arquivos por parte do typebot.

O login da console é feito com os valores de `MINIO_ROOT_CLIENT_ID` e 
`MINIO_ROOT_CLIENT_PASSWORD` fornecidos logo após a conclusão da instalação

Uso das Integrações
-------------------

Para fazer a utilização da integração com o Typebot leia os documento:

* [Integration Use](Integration%20Use.md)
* [Typebot Use](Integration%20Use%20Typebot.md)
