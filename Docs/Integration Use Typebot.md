Uso da integração com Typebot
=============================

Na configuração de uma fila, quando selecionada a integração Typebot irá
solicitar a URL base da sua instalação que normalmente vem a ser apenas
o protocolo e hostname do módulo viewer do seu typebot, por exemplo
`https://typebot-viewer.example.com`.

É também solicitado o **Public Id** do fluxo que será acionado para
essa fila.

Além disso tem a opção de **Interpretar RichText** que permite a conversão
adequada dos estilos de texto para o formato do canal e também um campo
para **Parâmetros adicionais** que devem ser fornecidos no formato
JSON, os valores fornecidos nesse objeto estarão disponíveis como variáveis
dentro de seu fluxo. **Atenção:** O Typebot aceita apenas um objeto
raso com valores `string`, `number` ou `boolean`, não são suporta
estrururas complexas como arrays e objetos.

O fluxo pode ser feito normalmente, o Ticketz suporta a bolha "Botões"
do Typebot porém o Ticketz a entragará como opções numeradas para o
contato da conversa.

Também é suportado o elemento "Wait" para aguardar um tempo, embora
seja desaconselhado o seu uso pois o contato pode acabar a vir escrevendo
algo nesse intervalo e isso será fornecido para a próxima entrada de
variável.

Bolhas de Imagem e áudio são suportadas normalmente e para enviar
um documento utiliza-se a bolha "embed"

### Variáveis disponíveis

Como mencionado acima, todos os valores configurados nos parâmetros
adicionais ficam disponíveis no Typebot como variáveis.

Além disso o Ticketz fornece ainda algumas variáveis padronizadas:

* `number`: Endereço do contato - no canal Whatsapp segue o formato
  `55DDDNUMERO` - 55 sendo o código do Brasil - outros canais
  irão mostrar um formato diferente;
* `pushName`: Nome do contato no Ticketz - comumente é o nome que
  o contato configurou no whatsapp dele, porém pode vir a ser
  editado pelos operadores;
* `firstMessage`: Primeira mensagem digitada pelo contato, útil
  para o início do processamento;
* `ticketId`: Número do Ticket no sistema;
* `backendURL`: URL do backend;
* `token`: Token a ser usado para emitir requisições HTTP que agirão
  diretamente sobre o ticket e/ou a sessão de integração atuais. Ver
  [Integration Commands](Integration Commands.md)

Além disso também é fornecida a variável `metadata` que pode ter
informações adicionais dependendo do driver de conexão e outros
fatores do sistema.

### Comandos

Para acionar funções especiais do Ticketz como encaminhar para fila ou
usuário, encerrar sessão do chatbot ou até mesmo fechar o atendimento
o Ticketz fornece um formato especial de mensagem que executa estas funções.

Os comandos são passados através de uma bolha do tipo "Text" iniciando com
o caractere `#` e seguido imediatamente de uma string no formato JSON.

O exemplo a seguir transfere a conversa atual par a fila 99:

```
#{ "queueId": 99 }
```

Um arquivo de exemplo com diversos comandos pode ser
[baixado aqui - clique com botão direito e escolha Salvar](https://raw.githubusercontent.com/ticketz-oss/ticketz-docker-acme/refs/heads/pro/Docs/typebot-export-bolhas-de-triggers.json).
Os comandos podem ser copiados de um fluxo para outro de forma a facilitar
o desenvolvimento.

Mais informações sobre os triggers disponíveis estão na página
[Integration Triggers](Integration%20Triggers.md)
