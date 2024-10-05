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


DIDRESTORE=""

## baixa todos os componentes
docker compose pull

if [ -f ${CURFOLDER}/retrieved_data.tar.gz ]; then
   echo "Dados de importação encotrados, iniciando o processo de carga..."

   [ -d retrieve ] || mkdir retrieve
   cp ${CURFOLDER}/retrieved_data.tar.gz retrieve
   
   tmplog=/tmp/loadretrieved-$$-${RANDOM}
   echo "" | docker compose run --rm -T -v ${PWD}/retrieve:/retrieve backend &> ${tmplog}-retrieve.log
   
   if [ $? -gt 0 ] ; then
      echo -e "\n\nErro ao carregar dados de retrieved_data.tar.gz.\n\nLog de erros pode ser encontrado em ${tmplog}-retrieve.log\n\n"
      exit 1
   fi
   
   if [ -f ${CURFOLDER}/public_data.tar.gz ]; then
      echo "Encontrado arquivo com dados para a pasta public, iniciando processo de restauração..."
      
      docker volume create --name ticketz-docker-acme_backend_public &> ${tmplog}-createpublic.log
      
      if [ $? -gt 0 ]; then
         echo -e "\n\nErro ao criar volume public\n\nLog de erros pode ser encontrado em ${tmplog}-createpublic.log\n\n"
         exit 1
      fi
      
      cat ${CURFOLDER}/public_data.tar.gz | docker run -i --rm -v ticketz-docker-acme_backend_public:/public alpine ash -c "tar -xzf - -C /public" &> ${tmplog}-restorepublic.log

      if [ $? -gt 0 ]; then
         echo -e "\n\nErro ao restaurar volume public\n\nLog de erros pode ser encontrado em ${tmplog}-restorepublic.log\n\n"
         exit 1
      fi
      
   fi
   
   # Evita restaurar backup após carga de dados, embora pouco provável
   DIDRESTORE=1
fi

if ! [ "${DIDRESTORE}" ]; then
    latest_backup_file=$(ls -t ${CURFOLDER}/ticketz-backup-*.tar.gz 2>/dev/null | head -n 1)
fi

if [ -n "${latest_backup_file}" ] && ! [ -d "backups" ]; then
    echo "Backup encontrado. Preparando para restauração..."

    mkdir backups

    # Cria um link para o arquivo ou pasta de backup no diretório de instalação
    ln "${latest_backup_file}" backups/

    # Executa o sidekick restore
    echo "" | docker compose run --rm -T sidekick restore
    
    if [ $? -gt 0 ] ; then
      echo "Falha ao restaurar backup"
      exit 1
    fi
    
    DIDRESTORE=1
fi

echo "Continuando a instalação..."

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

[ "${DIDRESTORE}" ] || cat << EOF

O login é ${email} e a senha é 123456

EOF

[ "${DIDRESTORE}" ] && cat << EOF

Dados foram restaurados, logins e senhas são as mesmas do sistema de origem.

EOF

echo "Removendo imagens anteriores..."
docker system prune -af &> /dev/null
