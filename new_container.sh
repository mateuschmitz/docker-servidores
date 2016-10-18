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
        HOSTNAME="$2"
        shift
        ;;
    -u|--username)
        USERNAME="$2"
        shift
        ;;
    -up|--user_pass)
        USER_PASS="$2"
        shift
        ;;
    -rp|--root_pass)
        ROOT_PASS="$2"
        shift
        ;;
    -mrp|--mysql_root_pass)
        MYSQL_ROOT_PASS="$2"
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

if [[ -z $HOSTNAME ]]; then
    echo 'Parâmetro -h|--hostname obrigatório' 
    exit
fi

if [[ -z $USERNAME ]]; then
    echo 'Parâmetro -u|--username obrigatório' 
    exit
fi

if [[ -z $USER_PASS ]]; then
    echo 'Parâmetro -up|--user_pass obrigatório' 
    exit
fi

if [[ -z $ROOT_PASS ]]; then
    echo 'Parâmetro -rp|--root_pass obrigatório' 
    exit
fi

if [[ -z $MYSQL_ROOT_PASS ]]; then
    echo 'Parâmetro -mrp|--mysql_root_pass obrigatório' 
    exit
fi

# faz o build da imagem
docker build --build-arg USERNAME=$USERNAME --build-arg USER_PASS=$USER_PASS \
--build-arg ROOT_PASS=$ROOT_PASS --build-arg MYSQL_USERNAME=$USERNAME \
--build-arg MYSQL_USER_PASS=$USER_PASS --build-arg MYSQL_ROOT_PASS=$MYSQL_ROOT_PASS \
-t template/debian .

# roda a imagem
docker run -it -d --name $HOSTNAME -h $HOSTNAME template/debian /bin/bash

# dá start na imagem
docker start $HOSTNAME

# Recupera o id do container
ID_CONTAINER=$(docker ps | awk '{ print $1, $16 }' | grep "$HOSTNAME" | awk '{ print $1 }')

# Recupera o IP do container
IP_CONTAINER=$(docker inspect $ID_CONTAINER | grep IPAddress | tail -1 | cut -d '"' -f 4)

# Limpa o terminal e exibe os dados do container instanciado
# echo -e \\033c
echo "$DOMAIN ($HOSTNAME) -> $IP_CONTAINER ($ID_CONTAINER)"

# Limpa possíveis imagens intermediárias
docker images | awk '{ print $3, $1 }' | grep '<none>' | awk '{ print $1 }' | xargs -I {} docker rmi {}

# Para evitar erros no ssh, remove dados salvos do antigo IP
ssh-keygen -f "/home/"$USER"/.ssh/known_hosts" -R $IP_CONTAINER