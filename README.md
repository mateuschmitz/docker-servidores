# docker-servidores
Repositório com scripts para a disciplina de instalação e manutenção de servidores

# BUILD
docker build -t template/debian .

# RUN
docker run -it --name server1 -h HOSTNAME template/debian bash

# EXEC
docker exec -it server1 bash

# Remover configuração do IP
ssh-keygen -f "/home/USER/.ssh/known_hosts" -R IP

#PARAMS RUN
HOSTNAME

# PARAMS BUILD
## GUEST
USERNAME
USER_PASS
ROOT_PASS

## PARAMS MYSQL
MYSQL_ROOT_PASS
USERNAME (igual usuário máquina)
USER_PASS (igual senha máquina)

# RUNNING
docker build --build-arg USERNAME=XXX --build-arg USER_PASS=102030 --build-arg ROOT_PASS=102030 --build-arg MYSQL_USERNAME=XXX --build-arg MYSQL_USER_PASS=102030 --build-arg MYSQL_ROOT_PASS=102030 -t template/debian .

# REMOVER IMAGENS <NONE>
docker images | awk '{ print $3, $1 }' | grep '<none>' | awk '{ print $1 }' | xargs -I {} docker rmi {}

# CRIAR CONTAINER VIA SCRIPT
./new_container.sh -h server1 -u username -up user_pass -rp root_pass -mrp mysql_root_pass

# RECUPERA O ID DO CONTAINER
docker images | awk '{ print $3, $1 }' | grep 'HOSTNAME' | awk '{ print $1 }'

# RECUPERA IP DO CONTAINER 
docker inspect ID_CONTAINER | grep IPAddress | tail -1 | cut -d '"' -f 4