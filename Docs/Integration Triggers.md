Comandos de Integrações
=======================

Os comandos, também chamados de "Triggers" são estruturas específicas que
uma integração pode retornar ao Ticketz através de uma mensagem ou endpoint
de webhook que executam ações específicas no Ticket a que a integração está
associada.

Formato de Mensagem
-------------------

Uma mensagem a ser entregue utilizando segue o formato:

```
{
  "type": string;
  "content": string;
  "mediaUrl": string;
}
```

* `type` pode ser um dos valores: `text`, `image`, `video`, `audio`,
  `gif` ou `document`
* `content` para mensagens do tipo texto deve ter o texto a ser transmitido
* `mediaUrl` para os outros tipos deve ter a URL do arquivo a ser enviado

Utilização dos comandos
-----------------------

Os comandos e mensagens podem ser fornecidos ao Ticketz por três formas:

### Bolha de texto

Exclusivamente para integração Typebot, um comando por vez utilizando
uma bolha de texto iniciando com o caractere `#` seguido pelo payload
em formato json.

O exemplo a seguir transfere a conversa para a fila 99:

```
#{
  "queueId": 99
}
```

### Retorno de Webhook

Exclusivamente para a integração Webhook, retornando a requisição com
um payload json, que pode conter:

* Apenas um comando
* Apenas uma mensagem com comando opcional
* Um array de mensagens, cada mensagem podendo ter um comando opcional.

O exemplo a seguir demonstra o uso de um array de mensagens com
duas delas tendo um comando:

```json
[
  {
     "type": "text",
     "content": "Uma mensagem"
  },
  {
     "type": "text",
     "content": "Outra mensagem",
     "trigger": { "action": "wait", "seconds": 2 }
  },
  {
     "type": "text",
     "content": "Uma mensagem com um trigger",
     "trigger": { "closeTicket": true }
  }
]
```

### Uma requisição HTTP para o backend

Este recurso pode ser utilizado tanto pelo Typebot quanto pelo Webhook,
e até por sistemas externos se for providenciada uma forma de transferir
o token de autorização.

Uma das variáveis fornecidas à integração é o token de autenticação,
também é fornecida uma variável com a URL do backend completa.

O endpoint é ``${BACKEND_URL}/integrations/webhook``

A requisição é do tipo POST

A autenticação é feita pelo cabeçalho `Authorization: Bearer ${token}`

O Payload pode ser qualquer formato mencionado no item
anterior (Retorno por webhook)

Comandos disponíveis
--------------------

### Envio de mensagem

Envia uma mensagem para o canal da conversa. O valor "message" pode
ser um único objeto de mensagem conforme o tipo especificado no item
anterior ou um array com vários objetos de mensagens.

```json
{
  "message": {
    "type": "text",
    "content": "conteúdo da mensagem"
  }}}
```

### Transferência de Fila

Transfere o ticket para outra fila, caso a nova fila não seja atendida
por chatbot também irá remover o atributo chatbot

```json
{
  "queueId": <numero da fila>
}
```

### Transferência de usuário e fila

Transfere o ticket para outra fila e já atribui para um usuário, nesse
caso o ticket já será aceito e aparecerá na aba "Atendendo" do novo usuário.

```json
{
  "queueId": <numero da fila>,
  "userId": <numero do user>
}
```

### Encerrar a sessão de integração

Apenas encerra a integração removendo a marca de chatbot do ticket deixando
a conversa na aba "Aguardando"

```json
{
  "action": "endSession"
}
```

### Parar o chatbot

Efetivamente esse trigger é idêntico ao "endSession" e está sendo mantido
para compatibilidade com automações já existentes.

```json
{
  "stopbot": true
}
```

### Encerrar o atendimento

Encerra o ticket atual colocando ele na aba de "Resolvidos"

```json
{
  "closeTicket": true
}
```

### Inserir anotação no ticket

Adiciona um aviso interno no ticket

```json
{
  "action": "note",
  "message": {
    "content": "Texto da anotação"
  }
}
```

### Múltiplas alterações no ticket

Este trigger é poderoso porque ele pode alterar várias propriedades
do atendimento.

```json
{
  "action": "updateTicket",
  "ticketData": <ticketdata>
}
```

Para esse trigger o valor `ticketData` deve ser um objeto com quaisquer dos
seguintes valores:

```
interface TicketData {
  status: string;     // pode ser "pending", "open" ou "closed"
  userId: number;     // transfere para outro usuário
  queueId: number;    // transfere para outra fila
  justClose: boolean; // para comandar o fechamento do ticket 
  annotation: string; // ao transferir adiciona a anotação no atendimento
}
```

### Aguardar um tempo

Aguarda um tempo em segundos - este comando só é efetivo quando
utilizado em um array de comandos (ver mais a seguir)

```json
{
  "action": "wait",
  "seconds": 2
}
```

### Ping

Esse comando faz com que o ticketz responda com uma mensagem
automática "pong".

Serve para forçar a ordem de alguns processamentos no typebot
colocando ele logo antes de um campo texto.

```json
{
  "action": "ping"
}
```
