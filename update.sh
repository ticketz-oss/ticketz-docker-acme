#!/bin/bash

# Função para mostrar a mensagem de uso
show_usage() {
    echo -e     "Uso: \n\n      curl -sSL https://update.ticke.tz | sudo bash\n\n"
    echo -e "Exemplo: \n\n      curl -sSL https://update.ticke.tz | sudo bash\n\n"
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

if [ -n "$1" ]; then
  BRANCH=$1
fi

CURBASE=$(basename ${PWD})
BACKEND_PUBLIC_VOL=$(docker volume list -q | grep -e "^${CURBASE}_backend_public$")
BACKEND_PRIVATE_VOL=$(docker volume list -q | grep -e "^${CURBASE}_backend_private$")
POSTGRES_VOL=$(docker volume list -q | grep -e "^${CURBASE}_postgres_data")

if [ -f docker-compose-acme.yaml ] && [ -f .env-backend-acme ] && [ -n "${BACKEND_PUBLIC_VOL}" ] && [ -n "${BACKEND_PRIVATE_VOL}" ] && [ -n "${POSTGRES_VOL}" ]; then
   echored "                                               "
   echored "  Este processo irá converter uma instalação   "
   echored "  manual a partir do fonte por uma instalação  "
   echored "  a partir de imagens pré compiladas do        "
   echored "  projeto ticketz                              "
   echored "                                               "
   echored "  Aguarde 20 segundos.                         "
   echored "                                               "
   echored "  Aperte CTRL-C para cancelar                  "
   echored "                                               "
   sleep 20
   echo "Prosseguindo..."

   docker compose -f docker-compose-acme.yaml down

   docker volume create --name ticketz-docker-acme_backend_public || exit 1
   docker run --rm -v ${BACKEND_PUBLIC_VOL}:/from -v ticketz-docker-acme_backend_public:/to alpine ash -c "cd /from ; cp -a . /to"

   docker volume create --name ticketz-docker-acme_backend_private || exit 1
   docker run --rm -v ${BACKEND_PRIVATE_VOL}:/from -v ticketz-docker-acme_backend_private:/to alpine ash -c "cd /from ; cp -a . /to"

   docker volume create --name ticketz-docker-acme_postgres_data || exit 1
   docker run --rm -v ${POSTGRES_VOL}:/from -v ticketz-docker-acme_postgres_data:/to alpine ash -c "cd /from ; cp -a . /to"
   
   . .env-backend-acme
   
   if [ -z "${SUDO_USER}" ] ; then
     cd
   elif [ "${SUDO_USER}" = "root" ] ; then
     cd /root || exit 1
   else
     cd /home/${SUDO_USER} || exit 1
   fi
   curl -sSL get.ticke.tz | bash -s -- -b ${BRANCH-main} ${FRONTEND_HOST} ${EMAIL_ADDRESS}

   echo "Após os testes você pode remover os volumes antigos com o comando:"
   echo -e "\n\n    sudo docker volume rm ${BACKEND_PUBLIC_VOL} ${BACKEND_PRIVATE_VOL} ${POSTGRES_VOL}\n"
   
   exit 0
fi

if [ -d ticketz-docker-acme ] && [ -f ticketz-docker-acme/docker-compose.yaml ] ; then
  cd ticketz-docker-acme
elif [ -f docker-compose.yaml ] ; then
  ## nothing to do, already here
  echo -n "" > /dev/null
elif [ "${SUDO_USER}" = "root" ] ; then
  cd /root/ticketz-docker-acme || exit 1
else
  cd /home/${SUDO_USER}/ticketz-docker-acme || exit 1
fi

echo "Working on $PWD/ticketz-docker-acme folder"

if ! [ -f docker-compose.yaml ] ; then
  echo "docker-compose.yaml não encontrado" > /dev/stderr
  exit 1
fi

if [ -n "${BRANCH}" ] ; then
  if ! git diff-index --quiet HEAD -- ; then
    echo "Salvando alterações locais com git stash push"
    git stash push &> /dev/null
  fi

  echo "Atualizando repositório"
  git fetch

  echo "Alterando para a branch ${BRANCH}"
  if git rev-parse --verify ${BRANCH}; then
    git checkout ${BRANCH}
  else
    if ! git checkout --track origin/$BRANCH; then
      echo "Erro ao alternar para a branch ${BRANCH}"
      exit 1
    fi
  fi
  echo "Trazendo updates da branch ${BRANCH}"
  git pull &> /dev/null
fi


echo "Baixando novas imagens"
docker compose pull || show_error "Erro ao baixar novas imagens"

echo "Finalizando containers"
docker compose down || show_error "Erro ao finalizar containers"

echo "Inicializando containers"
docker compose up -d || show_error "Erro ao iniciar containers"

echo -e "\nSeu sistema já deve estar funcionando"

echo "Removendo imagens anteriores..."
docker system prune -af &> /dev/null

echo "Concluído"
