# Documentação do QuickPix

## Visão Geral

O **QuickPix** é um sistema que gerencia registros de cobranças Pix, permitindo a criação, consulta, listagem e atualização de informações relacionadas a pagamentos Pix.

---

## Estrutura do Modelo

A tabela `QuickPix` possui os seguintes campos:

- **id**: Identificador único do registro (chave primária, gerado automaticamente).
- **companyId**: Identificador da empresa associada ao registro (chave estrangeira).
- **key**: Chave única gerada aleatoriamente para identificar o registro.
- **pixcode**: Código Pix associado ao registro.
- **expiration**: Data de expiração do código Pix.
- **isPaid**: Indica se o pagamento foi realizado (valor padrão: `false`).
- **metadata**: Campo JSON opcional para armazenar informações adicionais.
- **createdAt**: Data de criação do registro.
- **updatedAt**: Data de última atualização do registro.

---

## Rotas Disponíveis

### 1. **Adicionar Registro**
- **Método**: `POST`
- **Endpoint**: `/quickpix`
- **Descrição**: Cria um novo registro de chave Pix.
- **Parâmetros no corpo**:
  - `pixcode` (string): Código Pix.
  - `expiration` (date): Data de expiração.
  - `metadata` (JSON, opcional): Informações adicionais.
- **Resposta**: Retorna a URL gerada e os dados do registro criado.

---

### 2. **Consultar Registro por ID**
- **Método**: `GET`
- **Endpoint**: `/quickpix/:id`
- **Autenticação**: `apiTokenAuth`, `isAuth`, `isAdmin`
- **Descrição**: Retorna os detalhes de um registro específico pelo `id`.

---

### 3. **Consultar Registro por Chave**
- **Método**: `GET`
- **Endpoint**: `/quickpix/k/:key`
- **Descrição**: Retorna os detalhes de um registro específico pela `key`.

---

### 4. **Listar Registros**
- **Método**: `GET`
- **Endpoint**: `/quickpix`
- **Autenticação**: `apiTokenAuth`, `isAuth`, `isAdmin`
- **Descrição**: Lista todos os registros, com suporte a filtros baseados em metadados.
- **Parâmetros de consulta**:
  - `metadataKey` (string, opcional): Chave do metadado para filtrar.
  - `metadataValue` (string, opcional): Valor do metadado para filtrar.

---

### 5. **Marcar como Pago**
- **Método**: `PATCH`
- **Endpoint**: `/quickpix/:id/paid`
- **Autenticação**: `apiTokenAuth`, `isAuth`, `isAdmin`
- **Descrição**: Atualiza o status de um registro para indicar que o pagamento foi realizado.

---

## Regras de Negócio

**Autenticação e Autorização**:

Todas as rotas, exceto a consulta por chave (`/quickpix/k/:key`), exigem autenticação e permissões administrativas.

**Geração de Chave**:

A chave (`key`) é gerada automaticamente com 9 caracteres aleatórios.

**Validação de Empresa**:

Os registros são vinculados a uma empresa específica (`companyId`), garantindo que apenas usuários autorizados possam acessá-los.

**Filtros de Metadados**:
A listagem de registros suporta filtros dinâmicos baseados em metadados armazenados no campo `metadata`.

---

## Exemplo de Uso

### Criar um Registro

**Requisição**:

```
POST /quickpix { "pixcode": "00020126330014BR.GOV.BCB.PIX…", "expiration": "2023-12-31T23:59:59Z", "metadata": { "orderId": "12345", "customerName": "João Silva" } }
```

**Resposta**:

```
{ "url": "https://frontend.example.com/pix.html?k=ABC123XYZ", "id": "1", "companyId": 10, "key": "ABC123XYZ", "pixcode": "00020126330014BR.GOV.BCB.PIX…", "expiration": "2023-12-31T23:59:59Z", "isPaid": false, "metadata": { "orderId": "12345", "customerName": "João Silva" }, "createdAt": "2023-01-01T12:00:00Z", "updatedAt": "2023-01-01T12:00:00Z" }
```

---

## Página de pagamento

A URL de pagamento é utilizada para exibir as informações de uma cobrança Pix de forma interativa e amigável ao usuário. Ela é gerada dinamicamente no momento da criação de um registro no QuickPix e contém os seguintes recursos:

**QRCode Dinâmico**:

A página exibe um QRCode gerado a partir do código Pix (pixcode) associado ao registro.

O QRCode pode ser escaneado diretamente para realizar o pagamento.

**Código Pix Copiável**:

O código Pix é exibido em formato de texto, permitindo que o usuário copie e cole no aplicativo bancário, utilizando a funcionalidade "Pix Copia e Cola".

**Contagem Regressiva**:

A página exibe uma contagem regressiva indicando o tempo restante até a expiração da cobrança, com base no campo expiration.

**Verificação de Pagamento**:

A página verifica periodicamente o status de pagamento do registro através da rota /quickpix/k/:key.

Caso o pagamento seja identificado, a interface é atualizada para informar que a cobrança foi paga.

**Mensagens Multilíngues**:

A página suporta mensagens em diferentes idiomas (como português, inglês e espanhol), adaptando-se ao idioma do navegador do usuário.

**Experiência do Usuário**:

Instruções claras são fornecidas para orientar o usuário sobre como realizar o pagamento, seja pelo QRCode ou pelo código Pix.

### Exemplo de URL Gerada:


`https://frontend.example.com/pix.html?k=ABC123XYZ`

**Nesta URL**:

O parâmetro k representa a chave única do registro, que é utilizada para buscar os dados da cobrança no backend.
