#!/bin/bash

while [[ $# -gt 1 ]]
do

option="$1"

case $option in
    -d|--domain)
        DOMAIN="$2"
        shift
        ;;
    -h|--hostname)
        DOCKER_HOSTNAME="$2"
        shift
        ;;
    *)            
    ;;
esac
shift
done

if [[ -z $DOMAIN ]]; then
    echo 'Parâmetro -d|--domain obrigatório' 
    exit
fi

if [[ -z $DOCKER_HOSTNAME ]]; then
    echo 'Parâmetro -h|--hostname obrigatório' 
    exit
fi

# verifica quantos containers estão habilitados
numdocker="$(docker ps -a | grep -c template/debian)"

#caso já existam 10, exibe erro e termina a execução
if [ $numdocker == 10 ]; then 
    echo "Já existem 10 containers"
    exit
fi

# caso já exista algum
if [ $numdocker > 0 ]; then
    numdocker=$((numdocker + 1))
fi

# caso não tenha nenhum ainda, monta com o primeiro volume
if [ $numdocker == 0 ]; then 
    numdocker=1
fi

# roda a imagem
docker run -it -d --name $DOCKER_HOSTNAME -h $DOCKER_HOSTNAME \
-v /opt/volumes/docker$numdocker:/var/www template/debian /bin/bash

# dá start na imagem
docker start $DOCKER_HOSTNAME

# Recupera o IP do container
IP_CONTAINER=$(docker inspect $DOCKER_HOSTNAME | grep IPAddress | tail -1 | cut -d '"' -f 4)

# Limpa o terminal e exibe os dados do container instanciado
# echo -e \\033c
echo "$DOMAIN ($DOCKER_HOSTNAME) -> $IP_CONTAINER"

# Limpa containers doidos que ficam na lista
docker ps -a | awk '{ print $1, $3 }' | grep "/bin/sh" | awk '{ print $1 }' | xargs -I {} docker rm -f {}

# Limpa possíveis imagens intermediárias
docker images | awk '{ print $3, $1 }' | grep '<none>' | awk '{ print $1 }' | xargs -I {} docker rmi -f {}

# Para evitar erros no ssh, remove dados salvos do antigo IP
ssh-keygen -f "/home/"$USER"/.ssh/known_hosts" -R $IP_CONTAINER
ssh-keygen -f "/home/"$USER"/.ssh/known_hosts" -R $DOCKER_HOSTNAME
ssh-keygen -f "/home/"$USER"/.ssh/known_hosts" -R $DOMAIN

# cria proxy web
echo "Configurando WEB"
echo "server {  
        listen 80;
        server_name $DOMAIN;
        location / {
             proxy_pass http://$IP_CONTAINER:80;
        }
}" > /etc/nginx/sites-available/$DOMAIN

# cria o link simbólico
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

# define o final da porta utilizada no serviço
porta_ssh=$((3306 + numdocker))
porta_db=$((2200 + numdocker))

# cria proxy mysql e ssh
echo "Configurando MySQL - Porta -> "$porta_db
echo "Configurando SSH - Porta -> "$porta_ssh
echo "server {
        listen "$porta_db";
        proxy_pass "$DOCKER_HOSTNAME"_db;
    }
    upstream "$DOCKER_HOSTNAME"_db {
        server $IP_CONTAINER:3306;
    }
    server {
        listen "$porta_ssh";
        proxy_pass "$DOCKER_HOSTNAME"_ssh;
    }
    upstream "$DOCKER_HOSTNAME"_ssh {
        server $IP_CONTAINER:22;
}" > /etc/nginx/proxies-available/$DOMAIN

# cria o link simbólico
ln -s /etc/nginx/proxies-available/$DOMAIN /etc/nginx/proxies-enabled/$DOMAIN

# reload no nginx
echo "Reiniciando o Nginx"
sudo /etc/init.d/nginx reload
sudo /etc/init.d/nginx restart

# ./new_container.sh -d naughtyhost.com -h naughtyhost -u teste -up teste -rp teste -mrp teste
# unlink /etc/nginx/proxies-enabled/naughtyhost.com &&
# unlink /etc/nginx/proxies-available/naughtyhost.com &&
# unlink /etc/nginx/sites-available/naughtyhost.com &&
# unlink /etc/nginx/sites-enabled/naughtyhost.com 