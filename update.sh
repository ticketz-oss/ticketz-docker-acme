#!/bin/bash

# Função para mostrar a mensagem de uso
show_usage() {
    echo -e     "Uso: \n\n      curl -sSL https://update.ticke.tz | sudo bash\n\n"
    echo -e "Exemplo: \n\n      curl -sSL https://update.ticke.tz | sudo bash\n\n"
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

cd /home/${SUDO_USER}/ticketz-docker-acme || exit 1
echo "Baixando serviços"
sudo docker compose down || exit 1

echo "Removendo imagens Docker"
sudo docker image prune -a -f || exit 1

echo "Baixando novas imagens e Inicializando serviços"
sudo docker compose up -d
