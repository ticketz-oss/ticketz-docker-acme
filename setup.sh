#!/bin/bash

# Função para mostrar a mensagem de uso
show_usage() {
    echo -e     "Uso: \n\n      curl -sSL https://get.ticke.tz | sudo bash -s $0 <backend_host> <frontend_host> <email>\n\n"
    echo -e "Exemplo: \n\n      curl -sSL https://get.ticke.tz | sudo bash -s api.ticketz.exemplo.com.br ticketz.exemplo.com.br email@exemplo.com.br\n\n"
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
if [ -z "$3" ]; then
    show_usage
    exit 1
fi

# Atribui os valores dos parâmetros a variáveis
backend_host="$1"
frontend_host="$2"
email="$3"

# Passo 1: Providencia uma VPS zerada e aponta os hostnames do teu DNS para ela
# Passo 2: Instala o docker
curl -sSL https://get.docker.com | sh

# Passo 3: Baixa o projeto e entra na pasta
git clone https://github.com/ticketz-oss/ticketz-docker-acme.git
cd ticketz-docker-acme

# Passo 4: Configura os hostnames
sed -e "s/^BACKEND_HOST=.*/BACKEND_HOST=$backend_host/g"  \
  | sed -e "s/^FRONTEND_HOST=.*/FRONTEND_HOST=$frontend_host/g" \
  | sed -e "s/^EMAIL_ADDRESS=.*/EMAIL_ADDRESS=$email/g" < example.env-backend > .env-backend

sed -e "s/^BACKEND_HOST=.*/BACKEND_HOST=$backend_host/g" \
  | sed -e "s/^FRONTEND_HOST=.*/FRONTEND_HOST=$frontend_host/g" \
  | sed -e "s/^EMAIL_ADDRESS=.*/EMAIL_ADDRESS=$email/g" < example.env-frontend > .env-frontend

# Passo 5: Sobe os containers
docker compose up -d

cat << EOF
A geração dos certificados e a inicialização do serviço pode levar
alguns minutos.

Após isso você pode acessar o Ticketz pela URL

        https://${frontend_host}
        
EOF
