Substituição de variáveis no Ticketz
====================================

O Ticketz suporta substituição de variáveis em várias partes do sistema. Elas devem ser utilizadas seguindo o padrão da lib mustache, por exemplo: `{{variavel}}`.

As seguintes variáveis estão disponíveis:

* **name**: Nome completo do contato
* **firstname**: Primeiro nome do contato
* **email**: E-mail do contato
* **greeting**: Saudação conforme o horário do dia
* **queue**: Nome da fila
* **protocol**: Protocolo do ticket no formatno YYYYMMDD-TicketId
* **user**: Nome do usuário que atendeu o ticket
* **time**: Horário atual
* **ticket**: Número do Ticket

Os seguintes valores existem para manter compatibilidade prévia:

* **gretting** e **ms**: O mesmo que `{{greeting}}`
* **hora**: O mesmo que `{{time}}`
* **fila**: O mesmo que `{{queue}}`
* **usuario**: O mesmo que `{{user}}`

Além disso, os valores colocados como Informações Adicionais ao contato também estarão em duas formas diferentes:

1. Diretamente com o formato `{{variavel}}`, em caso de conflito com as variáveis padrões do Ticketz, prevalecerá o valor padrão.
2. Como subelementos da variável **extraInfo**, no formato `{{extraInfo.variavel}}`, nesse caso não ocorrem conflitos.

Recursos Avançados
------------------

A lib mustache permite o uso de condicionais e loops, o que possibilita a criação de templates mais dinâmicos. Por exemplo:

```
{{#variavel}}
  O conteúdo da variável é {{variavel}}
{{/variavel}}
```

Você pode conferir aqui o [Guia Completo de uso do Mustache](https://mustache.github.io/mustache.5.html)
