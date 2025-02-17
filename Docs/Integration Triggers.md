Triggers de Integrações
=======================

Os "Triggers" são estruturas específicas que uma integração pode retornar ao
Ticketz através de uma mensagem ou endpoint de webhook que executam ações
específicas no Ticket a que a integração está associada.

Utilização nas Integrações
--------------------------

### Uso por mensagem retornada do Typebot

Para utilizar os triggers no typebot basta utilizar um objeto do tipo Texto e
formatar o trigger em JSON logo após o caractere `#`, por exemplo:

```
#{"closeTicket": true}
```

### Uso por retorno de Webhook

Ao chamar uma integração por Webhook o Ticketz pode receber como resposta
um array de mensagens e ações. Por exemplo:

```json
[
  {
     "type": "text",
     "content": "Uma mensagem"
  },
  {
     "type": "text",
     "content": "Outra mensagem"
  },
  {
     "type": "text",
     "content": "Uma mensagem com um trigger",
     "trigger": { "closeTicket": true }
  }
]
```

### Uso por HTTP Request

Ao acionar uma integração o Ticketz fornece um token de sessão que pode
ser utilizado para acessar um webhook em {TICKETZ_URL}/integrations/webhook
pelo método POST.

A autenticação é pelo cabeçalho "Authorization: Bearer" e o payload deve
ser um dos triggers que possuem a propriedade "action" (da última sessão
deste documento)


Compatibilidade com Whaticket
-----------------------------

Os triggers a seguir estavam presentes nas implementações mais comuns
de integração com Typebot do Whaticket SaaS e foram replicados no Ticketz
para facilitar a migração de fluxos.

### Parar o chatbot

Apenas encerra a integração removendo a marca de chatbot do ticket deixando
a conversa na aba "Aguardando"

```json
{
  "stopbot": true
}
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

Triggers exclusivos do Ticketz
------------------------------

### Encerrar o atendimento

Encerra o ticket atual colocando ele na aba de "Resolvidos"

```json

{
  "closeTicket": true
}
```

### Encerrar a sessão de integração

Efetivamente esse trigger é idêntico ao "stopbot" da sessão de compatibilidade
com Whaticket.

```json
{
  "action": "endSession"
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
