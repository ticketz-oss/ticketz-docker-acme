#!/bin/bash

# Função para mostrar a mensagem de uso
show_usage() {
    echo -e     "Uso: \n\n      curl -sSL https://get.ticke.tz | sudo bash -s [-b <branchname>] <frontend_host> <email>\n\n"
    echo -e "Exemplo: \n\n      curl -sSL https://get.ticke.tz | sudo bash -s ticketz.exemplo.com.br email@exemplo.com.br\n\n"
}

# Verifica se está rodando usando o bash

if ! [ -n "$BASH_VERSION" ]; then
   echo "Este script deve ser executado como utilizando o bash\n\n" 
   show_usage
   exit 1
fi

# testa se pediu branch
if [ "$1" = "-b" ] ; then
   BRANCH=$2
   shift
   shift
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

# salva pasta atual
CURFOLDER=${PWD}

# Passo 1: Providencia uma VPS zerada e aponta os hostnames do teu DNS para ela
# Passo 2: Instala o docker / apenas se já não tiver instalado
which docker > /dev/null || curl -sSL https://get.docker.com | sh

# Passo 3: Baixa o projeto e entra na pasta
[ -d ticketz-docker-acme ] || git clone https://github.com/ticketz-oss/ticketz-docker-acme.git
cd ticketz-docker-acme
if ! git diff-index --quiet HEAD -- ; then
  echo "Salvando alterações locais com git stash push"
  git stash push &> /dev/null
fi

echo "Atualizando repositório"
git fetch

if [ -n "${BRANCH}" ] ; then
  echo "Alterando para a branch ${BRANCH}"
  if git rev-parse --verify ${BRANCH}; then
    git checkout ${BRANCH}
  else
    if ! git checkout --track origin/$BRANCH; then
      echo "Erro ao alternar para a branch ${BRANCH}"
      exit 1
    fi
  fi
fi

echo "Atualizando área de trabalho"
if ! git pull &> pull.log; then
  echo "Falha ao Atualizar repositório, verifique arquivo pull.log"
  echo -e "\n\nAlterações precisam ser verificadas manualmente, procure suporte se necessário\n\n"
  exit 1
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


latest_backup_file=$(ls -t ${CURFOLDER}/ticketz-backup-*.tar.gz 2>/dev/null | head -n 1)

if [ -n "${latest_backup_file}" ] && ![ -d "backups" ]; then
    echo "Backup encontrado. Preparando para restauração..."

    mkdir backups

    # Cria um link para o arquivo ou pasta de backup no diretório de instalação
    ln "${latest_backup_file}" backups/

    # Executa o sidekick restore
    docker exec -it sidekick /bin/bash -c "sidekick restore"

    echo "Restauração concluída."
else
    echo "Continuando a instalação..."
fi

# Inicia todos os serviços do Docker Compose
if ! ( docker compose down && docker compose up -d ); then
    echo "Falha ao reiniciar containers"
    echo -e "\n\nAlterações precisam ser verificadas manualmente, procure suporte se necessário\n\n"
    exit 1
fi

# Passo 6: Sobe os containers
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
