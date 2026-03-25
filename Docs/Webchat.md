# Webchat - Guia de Uso e Integração

## 📋 Índice

1. [Sobre o Webchat](#sobre-o-webchat)
2. [Pré-requisitos](#pré-requisitos)
3. [Configuração no Ticketz](#configuração-no-ticketz)
4. [Integração no Website](#integração-no-website)
5. [Personalização](#personalização)
6. [Exemplos](#exemplos)
7. [Troubleshooting](#troubleshooting)

---

## Sobre o Webchat

O **Webchat** é um widget flutuante (FAB - Floating Action Button) que permite que seus clientes iniciem conversas diretamente do seu website. Ele usa socket.io para comunicação em tempo real e é totalmente responsivo, funcionando em desktop e mobile.

**Características principais:**
- ✅ Seletor de país com bandeiras
- ✅ Validação de número de telefone
- ✅ Personalização de cores e títulos
- ✅ Suporte multi-idioma
- ✅ Sem dependências externas (vanilla JavaScript)
- ✅ Rápido carregamento
- ✅ Notificações push (quando o chat é fechado)

---

## Pré-requisitos

- Ticketz instalado e rodando
- Acesso ao painel administrativo do Ticketz
- Um domínio/URL de acesso ao Ticketz
- Permissões para editar o HTML/templates do seu website

---

## Configuração no Ticketz

### 1. Criar um Canal Webchat

1. Acesse o **Painel Administrativo** do Ticketz
2. Vá para **Canais** → **Novo Canal**
3. Selecione **Webchat** como tipo de canal
4. Configure os seguintes campos:

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| **Nome do Canal** | Identificador único (usado na integração) | webchat-principal |
| **Título da Janela** | Título exibido no widget | Atendimento Online |
| **Subtítulo da Janela** | Subtítulo ou descrição breve | Respostas rápidas 24/7 |
| **Cor Primária** | Cor do botão FAB e header | #0066CC |
| **Cor Secundária** | Cor de fundo secundário | #F5F5F5 |

### 2. Obter o Channel ID

Após criar o canal, você terá um **UUID do Canal** (Channel ID). Este ID será usado na integração do website.

**Você pode encontrar o Channel ID:**
- Na URL do canal no painel: `https://SUA_URL_TICKETZ/admin/channels/CHANNEL_ID`
- Na configuração do canal (geralmente mostrado na listagem)

---

## Integração no Website

### Método: Embed via Script Tag

Adicione o seguinte código ao HTML do seu website, logo antes do fechamento da tag `</body>`:

```html
<!-- Webchat Ticketz FAB -->
<script>
  window.WebchatPath = '/webchat.html';
  window.WebchatChannelId = 'REPLACE_WITH_YOUR_CHANNEL_ID';
  window.WebchatBackendUrl = 'https://SUA_URL_TICKETZ';
</script>
<script src="https://SUA_URL_TICKETZ/webchat-fab.js" async></script>
```

### Configuração das Variáveis

Você deve substituir os seguintes valores:

#### `window.WebchatBackendUrl`
**URL da instalação do Ticketz** onde o Ticketz está rodando.

**Exemplos:**
- `https://ticketz.suaempresa.com`
- `https://chat.example.com`
- `https://atendimento.com.br`
- `https://localhost:3333` (desenvolvimento local)

**⚠️ Importante:** Use o protocolo correto (http ou https) e não adicione barra final (`/`).

#### `window.WebchatChannelId`
O **UUID único do canal** que você criou no Ticketz.

**Exemplo:** `a1b2c3d4-e5f6-7890-abcd-ef1234567890`

#### `window.WebchatPath` (opcional)
Caminho relativo para o arquivo webchat.html. Não altere este valor normalmente, deixe como `/webchat.html`.

---

## Personalização

### Cores do Widget

O widget busca automaticamente as cores configuradas no canal no Ticketz. Você pode sobrescrever as cores via JavaScript:

```html
<script>
  window.WebchatPath = '/webchat.html';
  window.WebchatChannelId = 'your-channel-id';
  window.WebchatBackendUrl = 'https://ticketz.suaempresa.com';
  
  // Centralizar o widget (padrão: canto inferior direito)
  window.WebchatPosition = 'bottom-center'; // ou 'bottom-left', 'bottom-right'
  
  // Título customizado
  window.WebchatTitle = 'Fale Conosco';
  
  // Desabilitar auto-abertura (opcional)
  window.WebchatAutoOpen = false;
</script>
<script src="https://ticketz.suaempresa.com/webchat-fab.js" async></script>
```

### Selecionador de País

O widget inclui um selecionador de país com:
- 🚩 Bandeiras dos países
- 📱 Código do país (+55, +1, +49, etc.)
- 🔍 Busca por nome ou código

O país é automaticamente carregado da lista oficial de países via CDN público.

### Idiomas Suportados

O Webchat suporta os seguintes idiomas:
- 🇵🇹 Português (pt)
- 🇺🇸 Inglês (en)
- 🇪🇸 Espanhol (es)
- 🇫🇷 Francês (fr)
- 🇩🇪 Alemão (de)
- 🇮🇩 Indonésio (id)
- 🇮🇹 Italiano (it)

O idioma é detectado automaticamente pelo navegador do usuário.

---

## Exemplos

### Exemplo 1: Integração Básica

```html
<!DOCTYPE html>
<html>
<head>
    <title>Meu Website</title>
</head>
<body>
    <h1>Bem-vindo!</h1>
    <p>Converse conosco clicando no botão de chat abaixo.</p>

    <!-- Webchat Ticketz FAB -->
    <script>
      window.WebchatPath = '/webchat.html';
      window.WebchatChannelId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      window.WebchatBackendUrl = 'https://chat.suaempresa.com';
    </script>
    <script src="https://chat.suaempresa.com/webchat-fab.js" async></script>
</body>
</html>
```

### Exemplo 2: Integração com Desenvolvimento Local

Para testar o Webchat em desenvolvimento com Docker Compose rodando localmente:

```html
<script>
  window.WebchatPath = '/webchat.html';
  window.WebchatChannelId = 'seu-channel-id';
  window.WebchatBackendUrl = 'http://localhost:3333';
</script>
<script src="http://localhost:3333/webchat-fab.js" async></script>
```

**⚠️ Nota:** `localhost` só funciona se o website está também em `localhost`. Para CORS entre domínios diferentes, use HTTPS e domínios reais.

### Exemplo 3: Iniciar Chat Programaticamente

Você pode abrir o chat via JavaScript quando o usuário clicar em um botão:

```html
<button id="openChat">Clique para atendimento</button>

<script>
  document.getElementById('openChat').addEventListener('click', function() {
    // O widget será carregado automaticamente ao clicar
    // Se você precisa de controle mais fino, use:
    if (window.WebchatFAB && window.WebchatFAB.setOpen) {
      window.WebchatFAB.setOpen(true);
    }
  });
</script>

<!-- Webchat Ticketz FAB -->
<script>
  window.WebchatPath = '/webchat.html';
  window.WebchatChannelId = 'seu-channel-id';
  window.WebchatBackendUrl = 'https://chat.suaempresa.com';
</script>
<script src="https://chat.suaempresa.com/webchat-fab.js" async></script>
```

### Exemplo 4: Múltiplos Websites com Mesmo Ticketz

Se você tem múltiplos websites e quer direcioná-los para o mesmo Ticketz:

**Website 1 (vendas):**
```html
<script>
  window.WebchatPath = '/webchat.html';
  window.WebchatChannelId = 'channel-vendas-uuid';
  window.WebchatBackendUrl = 'https://chat.suaempresa.com';
</script>
<script src="https://chat.suaempresa.com/webchat-fab.js" async></script>
```

**Website 2 (suporte):**
```html
<script>
  window.WebchatPath = '/webchat.html';
  window.WebchatChannelId = 'channel-suporte-uuid';
  window.WebchatBackendUrl = 'https://chat.suaempresa.com';
</script>
<script src="https://chat.suaempresa.com/webchat-fab.js" async></script>
```

---

## Troubleshooting

### ❌ Widget não aparece

**Verificar:**
1. ✅ Verifique se `WebchatBackendUrl` está correto (use sua URL real, não localhost)
2. ✅ Verifique se `WebchatChannelId` existe no Ticketz
3. ✅ Abra o Console do Navegador (F12) e procure por erros
4. ✅ Verifique se o arquivo `webchat-fab.js` está sendo carregado (aba Network do DevTools)

**Erro comum:** `Uncaught SyntaxError: Unexpected token <`
- **Causa:** URL inválida, retornando HTML de erro em vez do JavaScript
- **Solução:** Verif ique se `WebchatBackendUrl` está correto

### ⚠️ CORS Error

**Mensagem:** `Access to XMLHttpRequest has been blocked by CORS policy`

**Solução:**
- O Ticketz deve estar em HTTPS se o website está em HTTPS
- Verifique se o Ticketz está configurado com o domínio correto
- A integração via iframe + socket.io contorna a maioria dos problemas de CORS

### 📱 Widget não funciona em mobile

**Verificar:**
1. ✅ Zoom do site está em 100% (alguns temas de mobile zoomam por padrão)
2. ✅ A viewport está corretamente configurada: `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
3. ✅ Toque na tela (alguns navegadores requerem interação antes de executar JavaScript)

### 🔌 Sem conexão com o servidor

**Mensagem no Console:** `WebSocket connection failed`

**Solução:**
1. ✅ Verifique se o servidor Ticketz está rodando
2. ✅ Verifique se `WebchatBackendUrl` permite conexão (firewall, proxy)
3. ✅ Teste a conectividade: acesse `https://seuurl.com/webchat.html` diretamente no navegador
4. ✅ Se usou HTTPS, certifique que o certificado SSL é válido (não auto-assinado em produção)

### 😵 Chat carrega mas sem resposta

**Possível causa:** Socket.io não conseguindo conectar

**Solução:**
```bash
# No servidor Ticketz, verifique se websockets estão habilitados:
curl -i https://seu-ticketz.com/socket.io/?EIO=4&transport=websocket
```

---

## Variáveis de Ambiente (Backend)

Se você estiver configurando o Ticketz via Docker Compose, a URL será determinada por:

```yaml
# docker-compose.yaml
environment:
  - BACKEND_URL=https://seu-ticketz.com
  - FRONTEND_URL=https://seu-ticketz.com
```

Use o valor de `FRONTEND_URL` como `WebchatBackendUrl` nos seus websites.

---

## Segurança

- ✅ O Webchat **não armazena dados do usuário** localmente além da sessão
- ✅ Todas as comunicações usam **socket.io com suporte a SSL/TLS**
- ✅ O Channel ID é público (usado para identificar o canal)
- ✅ Dados sensíveis (chaves de API, tokens) **não são expostos** no frontend

---

## Próximas Etapas

1. **Criar um canal** no Ticketz
2. **Copiar a configuração** com seu Channel ID e URL
3. **Testar localmente** antes de ir para produção
4. **Monitorar logs** do Ticketz para erros de conexão
5. **Personalizar cores** e textos conforme sua marca

---

## Suporte

Para dúvidas ou problemas:
- 📚 Consulte a documentação oficial do [Ticketz OSS](https://github.com/ticketz-oss/ticketz)
- 🐛 Reporte issues no [GitHub](https://github.com/ticketz-oss/ticketz/issues)
- 💬 Comunidade: Descreva o problema detalhando `WebchatBackendUrl`, `WebchatChannelId` e erros do console

---

**Versão:** 1.0  
**Atualizado:** Março 2026  
**Suportado em:** Ticketz Pro 1.0+
