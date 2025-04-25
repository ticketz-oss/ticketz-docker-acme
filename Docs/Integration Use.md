Uso das Integrações
===================

O Ticketz PRO conta com uma engine agnóstica de integrações, inicialmente
disponível para Typebot e Webhook/N8N

Uma integração pode ser utilizada escolhendo o driver desejado na tela da
configuração de filas.

Após a seleção do driver alguns outros campos devem ser preenchidos.

Uma fila é atendida por uma integração desde o momento em que o contato
envia a primeira mensagem até que uma das seguintes situações ocorra:

* Um atendente aceitou a conversa (passou para "Em atendimento");
* O driver da integração identificou que o fluxo chegou ao final (ex:
  último nó do typebot);
* O conteúdo da integração solicitou a finalização da sessão, fechamento
  ou transferência do ticket para outra fila

Transferências para uma nova fila acionam a integração daquela fila,
tanto sendo acionadas por um atendente como por uma integração. Isso
permite que uma integração passe a conversa para outra, indiferente de
qual driver cada uma esteja utilizando, inclusive é válido para o chatbot
interno ou outras automações que vierem a ser implementadas no futuro.


Mais detalhes podem ser vistos nos guias específicos de cada integração:

* [Uso do Typebot](Integration%20Use%20Typebot.md)
* [Uso do Webhook/N8N](Integration%20Use%20Webhook.md)
