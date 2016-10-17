# docker-servidores
Repositório com scripts para a disciplina de instalação e manutenção de servidores

# BUILD
docker build -t template/debian .

# RUN
docker run -it --name server1 template/debian bash

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
USERNAME
USER_PASS

# RUNNING
docker build --build-arg USERNAME=mateus --build-arg USER_PASS=102030 --build-arg ROOT_PASS=102030 --build-arg MYSQL_USERNAME=mateus --build-arg MYSQL_USER_PASS=102030 --build-arg MYSQL_ROOT_PASS=102030 -t template/debian .