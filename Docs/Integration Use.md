Uso das Integrações
===================

O Ticketz PRO conta com uma engine agnóstica de integrações, inicialmente
disponível para Typebot e Webhook/N8N

Para utilização das integrações basta selecionar o mecanismo de automação
desejado e fornecer as informações que ele solicitar.

Toda conversa que chegar nessa fila será atendida por esta integração.

Typebot
-------

A integração Typebot irá solicitar a URL base da sua instalação que 
normalmente vem a ser apenas o protocolo e hostname do módulo viewer do seu
typebot, por exemplo `https://typebot-viewer.example.com`.

É também solicitado o **Public Id** do fluxo que será acionado para
essa fila.

Além disso tem a opção de **Interpretar RichText** que permite a conversão
adequada dos estilos de texto para o formato do canal e também um campo
para **Parâmetros adicionais** que devem ser fornecidos no formato
JSON, os valores fornecidos nesse objeto estarão disponíveis como variáveis
dentro de seu fluxo. **Atenção:** O Typebot não suporta estrururas
complexas nos parâmetros adicionais.

O fluxo pode ser feito normalmente, o Ticketz suporta a bubble "Botões"
do Typebot porém o Ticketz a entragará como opções numeradas para o
contato da conversa.

Também é suportado o elemento "Sleep" para aguardar um tempo, embora
seja desaconselhado o seu uso pois o contato pode acabar a vir escrevendo
algo nesse intervalo e isso será fornecido para a próxima entrada de
variável.

Bubbles de Imagem e áudio são suportadas normalmente e para enviar
um documento utiliza-se a bubble "embed"

### Variáveis disponíveis

Como mencionado acima, todos os valores configurados nos parâmetros
adicionais ficam disponíveis no Typebot como variáveis.

Além disso o Ticketz fornece ainda 4 variáveis padronizadas:

* `pushName`: Nome do contato no Ticketz - comumente é o nome que
  o contato configurou no whatsapp dele, porém pode vir a ser
  editado pelos operadores;
* `number`: Endereço do contato (no canal Whatsapp segue o formato `55DDDNUMERO`);
* `ticketId`: Número do Ticket no sistema;
* `backendURL`: URL do backend do sistema que pode vir a ser utilizada
  no futuro para a chamada de alguns endpoints de API.

### Triggers

Para acionar funções especiais do Ticketz como encaminhar para fila ou
usuário, encerrar sessão do chatbot ou até mesmo fechar o atendimento
o Ticketz fornece um formato especial de mensagem que executa estas funções.

Os triggers são meramente uma bubble do tipo "Text" iniciando com 
o caractere `#` e seguido imediatamente de uma string no formato JSON.

O arquivo [typebot-export-bolhas-de-triggers.json](typebot-export-bolhas-de-triggers.json)
pode ser importado no seu typebot para facilitar a criação dos seus 
fluxos.

Mais informações sobre os triggers disponíveis estão na página
[Integration Triggers](Integration%20Triggers.md)
