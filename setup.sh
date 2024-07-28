#!/bin/bash

# Função para mostrar a mensagem de uso
show_usage() {
    echo -e     "Uso: \n\n      curl -sSL https://get.ticke.tz | sudo bash -s <frontend_host> <email>\n\n"
    echo -e "Exemplo: \n\n      curl -sSL https://get.ticke.tz | sudo bash -s ticketz.exemplo.com.br email@exemplo.com.br\n\n"
}

# Verifica se está rodando usando o bash

if ! [ -n "$BASH_VERSION" ]; then
   echo "Este script deve ser executado como utilizando o bash\n\n" 
   show_usage
   exit 1
fi

# Verifica se está rodando como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root" 
   exit 1
fi

# Verifica se os parâmetros estão corretos
if [ -z "$2" ]; then
    show_usage
    exit 1
fi

emailregex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"

# Atribui os valores dos parâmetros a variáveis
if [ -n "$3" ] ; then
    backend_host="$1"
    backend_path=""
    frontend_host="$2"
    email="$3"
else 
    backend_host="$1"
    backend_path="\\/backend"
    frontend_host="$1"
    email="$2"
fi

emailregex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
if ! [[ $email =~ $emailregex ]] ; then
    echo "email inválido"
    show_usage
    exit 1
fi

# Passo 1: Providencia uma VPS zerada e aponta os hostnames do teu DNS para ela
# Passo 2: Instala o docker / apenas se já não tiver instalado
which docker > /dev/null || curl -sSL https://get.docker.com | sh

# Passo 3: Baixa o projeto e entra na pasta
[ -d ticketz-docker-acme ] || git clone https://github.com/ticketz-oss/ticketz-docker-acme.git
cd ticketz-docker-acme
if git diff-index --quiet HEAD -- ; then
  git stash push &> /dev/null
  echo "Atualizando repositório"
  if ! git pull &> pull.log; then
    echo "Falha ao Atualizar repositório, verifique arquivo pull.log"
    echo -e "\n\nAlterações precisam ser verificadas manualmente, procure suporte se necessário\n\n"
    exit 1
  fi
  if ! git stash pop &> stash-pop.log; then
    echo "Falha ao recuperar alterações salvas, verifique arquivo stash-pop.log"
    echo -e "\n\nAlterações precisam ser verificadas manualmente, procure suporte se necessário\n\n"
    exit 1
  fi
fi

# Passo 4: Configura os hostnames
cat example.env-backend \
  | sed -e "s/^BACKEND_HOST=.*/BACKEND_HOST=$backend_host/g"  \
  | sed -e "s/^BACKEND_PATH=.*/BACKEND_PATH=$backend_path/g"  \
  | sed -e "s/^FRONTEND_HOST=.*/FRONTEND_HOST=$frontend_host/g" \
  | sed -e "s/^EMAIL_ADDRESS=.*/EMAIL_ADDRESS=$email/g"  > .env-backend

cat example.env-frontend \
  | sed -e "s/^BACKEND_HOST=.*/BACKEND_HOST=$backend_host/g" \
  | sed -e "s/^BACKEND_PATH=.*/BACKEND_PATH=$backend_path/g" \
  | sed -e "s/^FRONTEND_HOST=.*/FRONTEND_HOST=$frontend_host/g" \
  | sed -e "s/^EMAIL_ADDRESS=.*/EMAIL_ADDRESS=$email/g" > .env-frontend

## inclui configuração para o acme-companion se o backend tiver host a parte
[ -z "$backend_path" ] && cat >> .env-backend << EOF
# Normalmente não é necessário alterar estes valores
VIRTUAL_HOST=\${BACKEND_HOST}
VIRTUAL_PORT=3000
LETSENCRYPT_HOST=\${BACKEND_HOST}
LETSENCRYPT_EMAIL=\${EMAIL_ADDRESS}
EOF

# Passo 5: Sobe os containers
if ! ( docker compose down && docker compose up -d ); then
    echo "Falha ao reiniciar containers"
    echo -e "\n\nAlterações precisam ser verificadas manualmente, procure suporte se necessário\n\n"
    exit 1
fi

cat << EOF
A geração dos certificados e a inicialização do serviço pode levar
alguns minutos.

Após isso você pode acessar o Ticketz pela URL

        https://${frontend_host}
        
EOF

echo "Removendo imagens anteriores..."
docker system prune -af &> /dev/null
