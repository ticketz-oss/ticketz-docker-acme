# Configuração do WHMCS com o Ticketz

Embora não seja exatamente um gateway de pagamento, para o Ticketz o WHMCS é tratado como tal.

Isso porque ele permite o controle de assinatura através de diversos mecanismos de pagamento à sua escolha.

O Ticketz irá utilizar o controle de assinatura do WHMCS para inicializar e controlar o acesso dos planos assinados.

## Preparação do WHMCS

### Gateway de pagamento Efetivo

Não faz parte do escopo desse guia a configuração do gateway de pagamento no WHMCS. Apenas procure o módulo de cobrança adequando ao seus interesses. (Mercado Pago, ASAAS, Stripe, etc)

### Cadastro do Produto

Entrar em **Produtos/Serviços**

Nessa tela criar um produto com o tipo "Outro Produto/Serviço", criar ou selecionar um grupo adequado, definir o nome e selecionar o módulo "Auto Release".p

Na aba **Preço** deve-se colocar o preço do plano mais baixo que pretende fornecer, deixar com periodicidade recorrente mensal, e garantir que o valor está ativado.

Na aba **Campos Personalizados** devese criar um campo com as seguintes características:

- **Nome do Campo:** Password
- **Tipo do Campo:** Senha
- **Descrição:** "Senha para o primeiro login"

Marcar as opções "Campo Obrigatório" e "Mostrar no formulário de Pedido"

Anotar o código do produto que estará presente na URL do navegador, após o identificador "&id=", ele será necessário na configuração do Ticketz

Concluir o salvamento do produto


### Opções Configuráveis (Planos)

Entrar em **Opções Configuráveis** e clicar em Criar um novo Grupo

Colocar um nome para o grupo de opções e selecionar o produto criado e clicar para confirmar a criação do grupo.

Após isso clicar em "Add New Configurable Option"

Na tela de nova opção utilizar o nome "Plan", Option type: "Dropdown" e adicionar a seguir as opções.

Estas opções são os planos que você deseja oferecer. Os mesmos nomes utilizados aqui deverão ser utilizados dentro do Ticketz e os valores serão o que você irá adicionar ao valor definido no produto. Utilizar sempre a recorrência mensal.

### Chaves de API

Na tela **Manage API Credentials**:

1. Ir na aba **API Roles** e criar uma nova role com o nome "querycustomer", esta role precisa ter as funções `GetClientsDetails` e `GetClientsProducts`, ambas estão no grupo "Client"

2. Na aba **API Credentials** gerar uma nova credencial para a Role recém criada. Como resultado será fornecido dois valores "Identifier" e "Secret". Ambos devem ser copiados para uso no Ticketz

### Liberação do Acesso à API

Na tela **Configurações Gerais**, ir até a aba **Segurança**

Na opção "API IP Access Restriction", incluir o endereço IP de onde está rodando o Ticketz.

## Preparação no Ticketz

### Criação dos planos

Agora no Ticketz, é necessário criar os planos com os mesmos nomes que foram criados no WHMCS, absolutamente os mesmos nomes, qualquer caractere errado já deixa de funcionar.

O Ticketz suporta múltiplas recorrências, mas recomenda-se usar sempre a mensal.

### Configuração do Gateway

No Ticketz, na tela de **Configurações**, ir até a aba **Payment Gateways**

Nessa aba selecionar o Payment Gateway WHMCS, irá se abrir algumas oções.

É necessário habilitar o método de pagamento e então preencher os valores:

- **Base URL:** É a url inicial da instalação do WHMCS
- **API Identifier:** valor coletado ao criar a credencial do WHMCS
- **API Secret:** também coletado na criação da credencial
- **Product Code:** Número do código de Produto criado no WHMCS


## Utilização

Não tem nada a ser configurado exatamente. O cliente que adquirir o produto através do carrinho de compras do WHMCS será apresentado a uma escolha de plano e definição de uma senha. Após confirmada a compra e o pagamento ele já poderá usar o email fornecido para a compra, juntamente com a senha escolhida na página de compra do produto.

O Ticketz automaticamente criará a empresa com o nome do cliente obtido no cadastro do WHMCS e também ativará o plano que ele selecionou, também pegando a data de vencimento do WHMCS.

Após ter acesso ao Ticketz, o cliente poderá alterar a sua senha livremente e cadastrar outros usuários conforme as liberações do plano que ele selecionou.
