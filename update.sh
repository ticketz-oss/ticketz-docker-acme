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
  echo "docker-compose.yaml didn't found" > /dev/stderr
  exit 1
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
