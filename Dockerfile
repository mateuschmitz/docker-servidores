FROM debian:jessie
MAINTAINER Mateus Schmitz <matteuschmitz@gmail.com>

# argumentos utilizados no build
ARG USERNAME
ARG USER_PASS
ARG ROOT_PASS

ARG MYSQL_USERNAME
ARG MYSQL_USER_PASS
ARG MYSQL_ROOT_PASS

ENV DEBIAN_FRONTEND noninteractive

# Adiciona novos repositórios
RUN echo "deb http://httpredir.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list
RUN echo "deb http://httpredir.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org jessie/updates main contrib non-free" >> /etc/apt/sources.list

# Atualiza tudo
RUN apt-get update
RUN apt-get upgrade -y

# Configuração do MySQL
RUN echo mysql-server mysql-server/root_password password 102030 | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password 102030 | debconf-set-selections

# Expõe portas(apache, mysql, ssh, ftp)
EXPOSE 80
EXPOSE 3306
EXPOSE 22
EXPOSE 20
EXPOSE 21
EXPOSE 30000-30009

# Instala apache, mysql e php
RUN apt-get install -y --fix-missing apt-utils mysql-server php5 php5-mysql php5-mcrypt apache2 vim git net-tools wget sudo openssh-server
RUN service apache2 stop

# Muda o index do apache pra exibir a configuração do PHP
RUN rm /var/www/html/index.html
RUN printf "<?php\nphpinfo();" > /var/www/html/index.php

# Módulo rewrite
RUN a2enmod rewrite

# muda a senha do root
RUN echo "root:102030" | chpasswd

# Adiciona as configurações necessárias para start da máquina
ADD ./files/.bashrc /root/.bashrc

# Habilita o mysql para acesso externo
RUN sed s/127.0.0.1/0.0.0.0/ < /etc/mysql/my.cnf > /etc/mysql/my.cnf.new && mv /etc/mysql/my.cnf.new /etc/mysql/my.cnf
RUN service mysql restart && echo "grant all on *.* to 'root'@'%' identified by '102030';" > /root/grant.sql && mysql -u root -p102030 < /root/grant.sql && rm /root/grant.sql

# Adiciona inicialização de serviços ao .bashrc
RUN touch /var/log/startup_logs.log

RUN echo "# Verifica se os serviços estão ok\n\
# Caso não estejam, inicia-os\n\
if pgrep \"apache2\" > /dev/null\n\
then\n\
    echo Apache: OK\n\
else\n\
    echo 102030 | sudo -S service apache2 start >> /var/log/startup_logs.log\n\
fi\n\
\n\
if pgrep \"mysql\" > /dev/null\n\
then\n\
    echo MySQL: OK\n\
else\n\
    echo 102030 | sudo -S service mysql start >> /var/log/startup_logs.log\n\
fi\n\
\n\
if pgrep \"ssh\" > /dev/null\n\
then\n\
    echo SSH: OK\n\
else\n\
    echo 102030 | sudo -S service ssh start >> /var/log/startup_logs.log\n\
fi\n\
" >> /root/.bashrc

# configura o ssh
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Mudando o timezone pq eu quero
RUN echo "America/Sao_Paulo" > /etc/timezone
RUN export TZ=America/Sao_Paulo