FROM debian:jessie
MAINTAINER Mateus Schmitz <matteuschmitz@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Adiciona novos repositórios
RUN echo "deb http://httpredir.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list
RUN echo "deb http://httpredir.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org jessie/updates main contrib non-free" >> /etc/apt/sources.list

# Atualiza tudo
RUN apt-get update
RUN apt-get upgrade -y
# RUN apt-get dist-upgrade -y
# RUN apt-get -y --force-yes install dpkg-dev debhelper

# Configuração do MySQL
#RUN echo mysql-server mysql-server/root_password password 102030 | debconf-set-selections
#RUN echo mysql-server mysql-server/root_password_again password 102030 | debconf-set-selections

# Expõe portas(apache, mysql, ssh, ftp)
EXPOSE 80
#EXPOSE 3306
#EXPOSE 22
#EXPOSE 20
#EXPOSE 21
#XPOSE 30000-30009

# Instala apache, mysql e php
#RUN apt-get install mysql-server php5 php5-mysql php5-mcrypt apache2 vim git php5-dev libpcre3-dev build-essential net-tools wget -y
RUN apt-get install apache2 -y
RUN service apache2 stop

# Muda o index do apache pra exibir a configuração do PHP
RUN rm /var/www/html/index.html
RUN printf "<?php\nphpinfo();" > /var/www/html/index.php

# Módulo rewrite
RUN a2enmod rewrite

# Garante que apache e mysql rodarao no start da sessao
RUN echo "#service apache2 restart\n\
#service mysql restart\n\
force_color_prompt=yes\n\
\n\
if [ -n \"$force_color_prompt\" ]; then\n\
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then\n\
    color_prompt=yes\n\
    else\n\
    color_prompt=\n\
    fi\n\
fi\n\
\n\
if [ \"$color_prompt\" = yes ]; then\n\
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '\n\
else\n\
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '\n\
fi\n\
unset color_prompt force_color_prompt\n\
\n\
case \"$TERM\" in\n\
xterm*|rxvt*)\n\
    PS1=\"\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1\"\n\
    ;;\n\
*)\n\
    ;;\n\
esac\n\
\n\
if [ -x /usr/bin/dircolors ]; then\n\
    test -r ~/.dircolors && eval \"$(dircolors -b ~/.dircolors)\" || eval \"$(dircolors -b)\"\n\
    alias ls='ls --color=auto'\n\
    alias dir='dir --color=auto'\n\
    alias vdir='vdir --color=auto'\n\
    alias grep='grep --color=auto'\n\
    alias fgrep='fgrep --color=auto'\n\
    alias egrep='egrep --color=auto'\n\
fi\n\
\n\
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'\n\
\n\
alias ll='ls -l'\n\
alias la='ls -A'\n\
alias l='ls -CF'\n\
\n\
if [ -f ~/.bash_aliases ]; then\n\
    . ~/.bash_aliases\n\
fi\n\
\n\
if ! shopt -oq posix; then\n\
  if [ -f /usr/share/bash-completion/bash_completion ]; then\n\
    . /usr/share/bash-completion/bash_completion\n\
  elif [ -f /etc/bash_completion ]; then\n\
    . /etc/bash_completion\n\
  fi\n\
fi\n\
\n\
if pgrep "apache2" > /dev/null\n\
then\n\
    echo Apache: OK\n\
else\n\
    service apache2 start\n\
fi\n\
" > /root/.bashrc

# Habilita o mysql para acesso externo
#RUN sed s/127.0.0.1/0.0.0.0/ < /etc/mysql/my.cnf > /etc/mysql/my.cnf.new && mv /etc/mysql/my.cnf.new /etc/mysql/my.cnf
#RUN service mysql restart && echo "grant all on *.* to 'root'@'%' identified by '102030'" > /root/grant.sql && mysql -u root -p102030 < /root/grant.sql && rm /root/grant.sql 

# Baixa o PROFTPD
# RUN cd /opt
# RUN wget ftp://ftp.proftpd.org/distrib/source/proftpd-1.3.6rc2.tar.gz
# RUN tar zxvf proftpd-1.3.6rc2.tar.gz
# RUN rm proftpd-1.3.6rc2.tar.gz
# RUN cd proftpd-1.3.6rc2

# Instala o PROTFPD
# RUN ./configure --sysconfdir=/etc --prefix=/usr/local/
# RUN make
# RUN make install
# RUN ln -s /opt/proftpd-1.3.6rc2/proftpd /etc/init.d/proftpd

# Instala o PROFTPD
#RUN echo '/bin/false' >> /etc/shells
#RUN apt-get install proftpd -y

# cria um usuário FTP
#RUN useradd -ms /bin/bash pedro
#RUN echo 'pedro:102030' | chpasswd

#ENTRYPOINT ["/user/sbin/apache2"] & CMD ["-D", "FOREGROUND"]
#ENTRYPOINT ["/usr/sbin/apache2ctl"]
# ENTRYPOINT service apache2 start
# ENTRYPOINT ["/etc/init.d/apache2", "-DFOREGROUND", "start"]
# ENTRYPOINT ["/etc/init.d/apache2"] && CMD ["start"]
# ENTRYPOINT ["/etc/init.d/apache2"]
# CMD ["service apache2 start"]

# Inicia os serviços necessários
# CMD /etc/init.d/apache2 start
# CMD /etc/init.d/mysql start
# CMD /etc/init.d/proftpd start
# CMD /usr/sbin/apache2ctl -D FOREGROUND

# Isso mantém os serviços acima rodando
#CMD touch /opt/still_running.txt && tail -f /opt/still_running.txt
# SHELL ["/bin/bash", "-c"]
# CMD /usr/sbin/apache2ctl -D FOREGROUND

# ADD start.sh /usr/local/bin/start.sh
# RUN chmod +x /usr/local/bin/start.sh
# CMD ["./usr/local/bin/start.sh"]