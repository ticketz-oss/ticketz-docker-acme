#!/bin/bash

#!/bin/bash

# Função para mostrar a mensagem de uso
show_usage() {
    echo -e     "Uso: \n\n      curl -sSL https://in.ticke.tz | sudo bash\n\n"
}

# Função para sair com erro
show_error() {
    echo $1
    echo -e "\n\nAlterações precisam ser verificadas manualmente, procure suporte se necessário\n\n"
    exit 1
}

# Função para mensagem em vermelho
echored() {
   echo -ne "\033[41m\033[37m\033[1m"
   echo -n "$1"
   echo -e "\033[0m"
}

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

if ! [ -f .env-backend ]; then
   echo -e "Arquivo .env-backend não encontrado\n"
   echo -e "Este script deve ser executado dentro de uma pasta de instalação do Ticketz PRO\n"
   exit 1
fi

CURBRANCH=$(git branch --show-current)

if ! [[ "${CURBRANCH}" =~ ^pro ]]; then
   echo -e "Esse comando não pode ser utilizado na branch ${CURBRANCH}\n"
   exit 1
fi

if [[ "${CURBRANCH}" =~ 'typebot' ]]; then
   echo -e "Você já está na branch ${CURBRANCH}, este comando não funciona para quem já utiliza uma branch de typebot\n";
   exit 1
fi

if ! [ -f .env-integrations ]; then
   echo -e "Arquivo .env-integrations não encontrado\n"
   echo -e "Você deve criar o arquivo de configuração das integrações\n"
   exit 1
fi

if [ -f .env-secrets ]; then
   echo -e "Arquivo .env-secrets existe, apague antes de prosseguir\n"
   exit 1
fi

if ! echo "" | docker compose exec -T postgres psql -U ticketz -c "DROP DATABASE IF EXISTS typebot;" -c "CREATE DATABASE typebot;" > /dev/null; then
   echo -e "\nFalha ao (re)criar database typebot\n";
   exit 1
fi

. .env-backend
. .env-integrations

cat << EOF > .env-secrets
## ARQUIVO GERADO AUTOMATICAMENTE
## Mexa apenas se tiver certeza absoluta do que está fazendo...
## se puder não mexa mesmo tendo certeza

S3_ACCESS_KEY=$(head -c 24 /dev/urandom | base64)
S3_SECRET_KEY=$(head -c 24 /dev/urandom | base64)

FRONTEND_HOST=${FRONTEND_HOST}
EMAIL_ADDRESS=${EMAIL_ADDRESS}

TYPEBOT_ENCRYPTION_SECRET=$(openssl rand -base64 24)
TYPEBOT_ADMIN_PASSWORD=$(head -c 6 /dev/urandom | base64)

MINIO_ROOT_CLIENT_ID=$(head -c 24 /dev/urandom | base64)
MINIO_ROOT_CLIENT_SECRET=$(head -c 24 /dev/urandom | base64)
EOF


if ! git diff-index --quiet HEAD -- ; then
  echo "Salvando alterações locais com git stash push"
  git stash push &> /dev/null
fi

echo "Atualizando repositório"
git fetch

BRANCH=${CURBRANCH}-typebot
echo "Alterando para a branch ${BRANCH}"
if git rev-parse --verify ${BRANCH}; then
  git checkout ${BRANCH}
else
  if ! git checkout --track origin/$BRANCH; then
    echo "Erro ao baixar a branch ${BRANCH}"
    exit 1
  fi
fi

echo "Trazendo updates da branch ${BRANCH}"
git pull &> /dev/null

echo "Baixando novos pacotes"
docker compose pull

echo "Finalizando serviços"
docker compose down

echo "Inicializando serviçose"
docker compose -up -d

. .env-secrets

cat << EOF
Configurações de segurança geradas em .env-secrets:

Typebot Builder:

             URL: https://${TYPEBOT_BUILDER_HOST}
            User: ${EMAIL_ADDRESS}
        Password: ${TYPEBOT_ADMIN_PASSWORD}
   
Minio S3 Console:

             URL: https://${FRONTEND_HOST}/minio
       Client ID: ${MINIO_ROOT_CLIENT_ID}
   Client Secret: ${MINIO_ROOT_CLIENT_SECRET}

EOF
