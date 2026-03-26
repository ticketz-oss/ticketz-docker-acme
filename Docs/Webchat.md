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

### Criar uma Conexão Webchat

1. Acesse o **Painel Administrativo** do Ticketz
2. Vá para **Conexões** → **Nova Conexão**
3. Selecione **Webchat** como tipo de conexão
4. Configure:
   - **Nome**: Nome descritivo (ex: `webchat-principal`)
   - **Título da Janela**: Texto exibido no topo (ex: `Atendimento Online`)
   - **Subtítulo da Janela**: Descrição breve (ex: `Responderemos em breve`)
   - **Cor Primária**: Cor do botão FAB (ex: `#0066CC`)
   - **Cor Secundária**: Cor de destaque (ex: `#00AA00`)

Após salvar, você receberá um **ID da Conexão** (um código único). Copie este ID para usar na integração.

---

## Integração Básica

### Exemplo Mínimo

Adicione este código no final do arquivo HTML do seu website, antes de `</body>`:

```html
<script>
  window.WebchatChannelId = 'seu-id-conexao-aqui';
</script>
<script src="https://seu-ticketz.com/webchat-fab.js" async></script>
```

**Substitua:**
- `seu-ticketz.com` → URL da sua instalação do Ticketz (ex: `chat.suaempresa.com`)
- `seu-id-conexao-aqui` → ID da Conexão copiado do painel

Pronto! Um botão flutuante aparecerá automaticamente no canto inferior direito da página.

---

## Personalização

### Método 1: Via Painel (Recomendado)

Ao criar ou editar a **Conexão Webchat** no painel, configure:

| Campo | Descrição | Exemplo |
|-------|-----------|----------|
| **Título da Janela** | Título exibido no topo do chat | `Suporte Online` |
| **Subtítulo da Janela** | Descrição breve | `Equipe disponível 24/7` |
| **Mensagem de Chamada (CTA)** | Texto curto exibido ao lado do ícone flutuante | `Fale com a gente` |
| **Cor Primária** | Cor do botão e elementos principais | `#0066CC` |
| **Cor Secundária** | Cor de destaques e bordas | `#00AA00` |

Essas configurações serão aplicadas automaticamente e sobrescrevem os padrões do sistema.

### Método 2: Via Variáveis Globais (Opcional)

Você pode sobrescrever o comportamento visual direto na página com variáveis `window`:

| Variável | Descrição | Valor padrão |
|-----------|-----------|----------|
| `window.WebchatCtaMessage` | Sobrescreve a mensagem de chamada (CTA) do painel | Vazio (usa painel) |
| `window.WebchatFabPulseEnabled` | Ativa/desativa pulsação do botão | `true` |
| `window.WebchatFabPulseDuration` | Duração da animação (em segundos) | `0.3` |
| `window.WebchatFabPulseScale` | Escala máxima da pulsação | `1.05` |

**Exemplo com sobrescrita por variáveis:**

```html
<script>
  window.WebchatChannelId = 'seu-id-conexao';
  window.WebchatCtaMessage = 'Atendimento imediato';
  window.WebchatFabPulseEnabled = true;
  window.WebchatFabPulseDuration = 0.3;
  window.WebchatFabPulseScale = 1.05;
</script>
<script src="https://seu-ticketz.com/webchat-fab.js" async></script>
```

### Método 3: Via URL do webchat (Opcional)

Para ajustes da janela interna do chat, você pode informar parâmetros no `WebchatPath`:

| Parâmetro | Descrição | Formato |
|-----------|-----------|----------|
| `title` | Título da janela | `title=Suporte` |
| `subtitle` | Subtítulo | `subtitle=Equipe%20Online` |
| `lang` | Idioma da interface | `lang=pt` (pt, en, es, fr, de, id, it) |
| `primary` | Cor primária | `primary=%230066CC` (hex RGB com %) |
| `secondary` | Cor secundária | `secondary=%2300AA00` |
| `surface` | Cor de fundo | `surface=%23FFFFFF` |
| `text` | Cor de texto | `text=%23333333` |

**Exemplo com parâmetros na URL do webchat:**

```html
<script>
  window.WebchatChannelId = 'seu-id-conexao';
  window.WebchatPath = '/webchat.html?lang=pt&primary=%230066CC&secondary=%2300AA00&surface=%23FFFFFF&text=%23333333';
</script>
<script src="https://seu-ticketz.com/webchat-fab.js" async></script>
```

**Dica:** Configuração da Conexão no painel é a base. Variáveis `window` e parâmetros de URL sobrescrevem quando informados.

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
2. Confirme que o ID da Conexão é exato (copie novamente do painel)
3. Abra o Console do navegador (F12) e procure por erros
4. Verifique na aba **Network** se `webchat-fab.js` está sendo carregado com sucesso

### O botão aparece, mas não abre?

1. Clique novamente no botão
2. Verifique se o servidor Ticketz está rodando e acessível
3. Procure por erros no Console do navegador

---

**Versão:** 1.0  
**Atualizado:** Março 2026
