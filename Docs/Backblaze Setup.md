# Backblaze Setup

Este guia te ajuda a configurar o Backblaze no Ticketz em poucos minutos.

## Passo a passo no Backblaze

1. Crie uma conta em https://www.backblaze.com.
2. Crie um bucket e altere a visibilidade para Publico. Nesse ponto sera solicitado o cartao.
3. No canto superior direito, acesse "Billing" e adicione o cartao novamente (precisa passar duas vezes).
4. Va em "Application Keys" e crie uma nova chave com permissao de leitura e escrita no bucket criado.
5. Guarde em um bloco de notas: Key ID e Application Key.

## Preenchendo no Ticketz

Na tela de configuracoes do Ticketz, bem embaixo, preencha os campos assim:

- Access Key: o Key ID.
- Secret Key: o Application Key.
- Region: a regiao do seu bucket (geralmente aparece no endpoint; comum: sa-east-005).
- Bucket: o nome do bucket.
- Endpoint: a URL do endpoint iniciando com https.

Pronto. Se tudo estiver correto, o Ticketz passa a usar o Backblaze para armazenar arquivos.
