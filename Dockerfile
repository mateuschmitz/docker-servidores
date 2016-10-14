FROM debian:jessie
MAINTAINER Mateus Schmitz <matteuschmitz@gmail.com>

# Atualizando os repositórios
RUN echo "deb http://httpredir.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list
RUN echo "deb http://httpredir.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org jessie/updates main contrib non-free" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

# Configuração do MySQL
RUN echo mysql-server mysql-server/root_password password $SENHA | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password $SENHA | debconf-set-selections

# Expõe portas
EXPOSE 80
EXPOSE 3306

# Instala apache, mysql e php
RUN apt-get install mysql-server php5 php5-mysql php5-mcrypt apache2 vim git php5-dev libpcre3-dev build-essential net-tools -y
RUN service apache2 stop

# Muda o index do apache pra exibir a configuração do PHP
RUN rm /var/www/html/index.html
RUN printf "<?php\nphpinfo();" > /var/www/html/index.php

# Módulo rewrite
RUN a2enmod rewrite

# Garante que apache e mysql rodarao no start da sessao
RUN echo "service apache2 restart" > /root/.bashrc
RUN echo "service mysql restart" >> /root/.bashrc

# Habilita o mysql para acesso externo
RUN sed s/127.0.0.1/0.0.0.0/ < /etc/mysql/my.cnf > /etc/mysql/my.cnf.new && mv /etc/mysql/my.cnf.new /etc/mysql/my.cnf
RUN service mysql restart && echo "grant all on *.* to 'root'@'%' identified by '$SENHA'" > /root/grant.sql && mysql -u root -p$SENHA < /root/grant.sql && rm /root/grant.sql 

