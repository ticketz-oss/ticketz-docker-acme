# Webchat - Guia para Administrador

## 📋 Índice

1. [Sobre o Webchat](#sobre-o-webchat)
2. [Configuração no Ticketz](#configuração-no-ticketz)
3. [Integração Básica](#integração-básica)
4. [Personalização](#personalização)
5. [Verificação](#verificação)

---

## Sobre o Webchat

O **Webchat** é um widget flutuante que permite que seus clientes iniciem conversas diretamente do seu website. Responsivo e funciona em desktop e mobile.

---

## Configuração no Ticketz

### Criar um Canal Webchat

1. Acesse o **Painel Administrativo** do Ticketz
2. Vá para **Canais** → **Novo Canal**
3. Selecione **Webchat** como tipo de canal
4. Configure:
   - **Nome**: Nome do canal (ex: `webchat-principal`)
   - **Título da Janela**: Texto exibido no topo (ex: `Atendimento Online`)
   - **Subtítulo da Janela**: Descrição breve (ex: `Responderemos em breve`)
   - **Cor Primária**: Cor do botão (ex: `#0066CC`)

Após salvar, você receberá um **Channel ID** (um código único). Copie este ID para usar na integração.

---

## Integração Básica

### Exemplo Mínimo

Adicione este código no final do arquivo HTML do seu website, antes de `</body>`:

```html
<script>
  window.WebchatChannelId = 'seu-channel-id-aqui';
</script>
<script src="https://seu-ticketz.com/webchat-fab.js" async></script>
```

**Substitua:**
- `seu-ticketz.com` → URL da sua instalação do Ticketz (ex: `chat.suaempresa.com`)
- `seu-channel-id-aqui` → Channel ID copiado do painel

Pronto! Um botão flutuante aparecerá automaticamente no canto inferior direito da página.

---

## Personalização

Você pode personalizar o Webchat adicionando parâmetros antes de carregá-lo:

### Parâmetros da Janela (via Painel)

As cores e títulos podem ser definidos no painel do Ticketz ao criar/editar o canal. Elas serão aplicadas automaticamente.

### Parâmetros via URL (webchat.html)

Ao carregar o `webchat.html`, você pode passar parâmetros adicionais:

| Parâmetro | Descrição | Alternativas |
|-----------|-----------|---|
| `channel` | ID do canal | Essencial |
| `title` | Título customizado | Padrão vem do painel |
| `subtitle` | Subtítulo customizado | Padrão vem do painel |
| `lang` | Idioma (pt, en, es, fr, de, id, it) | Detectado automaticamente |
| `primary` | Cor primária (#RRGGBB) | Padrão vem do painel |
| `secondary` | Cor secundária (#RRGGBB) | Padrão vem do painel |
| `surface` | Cor de fundo (#RRGGBB) | Padrão: branco |
| `text` | Cor de texto (#RRGGBB) | Padrão: escuro |

**Exemplo com personalização:**

```html
<script>
  window.WebchatChannelId = 'seu-channel-id';
</script>
<script src="https://seu-ticketz.com/webchat-fab.js?title=Suporte&lang=pt&primary=%230066CC&secondary=%234DB8FF&surface=%23FFFFFF&text=%23333333" async></script>
```

### Idiomas Disponíveis

O Webchat detecta automaticamente o idioma do navegador. Idiomas suportados:

- 🇵🇹 Português (pt)
- 🇺🇸 Inglês (en)
- 🇪🇸 Espanhol (es)
- 🇫🇷 Francês (fr)
- 🇩🇪 Alemão (de)
- 🇮🇩 Indonésio (id)
- 🇮🇹 Italiano (it)

---

## Verificação

### O chat não aparece?

1. Verifique a URL do seu Ticketz está acessível
2. Confirme que o Channel ID é exato (copie novamente do painel)
3. Abra o Console do navegador (F12) e procure por erros
4. Verifique na aba **Network** se `webchat-fab.js` está sendo carregado com sucesso

### O botão aparece, mas não abre?

1. Clique novamente no botão
2. Verifique se o servidor Ticketz está rodando e acessível
3. Procure por erros no Console do navegador

---

**Versão:** 1.0  
**Atualizado:** Março 2026
