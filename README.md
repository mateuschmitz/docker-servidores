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

# REDE
## Seta novo IP e máscara
ifconfig eth0 192.168.1.164 netmask 255.255.255.0 up
ifconfig eth0 192.168.1.164 netmask 255.255.255.0 up

## MONTAGEM
sudo mount -t nfs 10.0.3.15:/export/Containers /var/lib/docker/containers

## FSTAB
10.0.3.15:/export/Containers /var/lib/docker/containers nfs noatime,auto,defaults 0 0

## NGINX 1.10.1
wget 'http://nginx.org/download/nginx-1.10.1.tar.gz'

## COMPILAR NGINX
sudo ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx  --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --with-ipv6 --with-http_ssl_module --with-threads --with-stream --with-http_slice_module
OU
sudo ./configure --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' --with-ld-opt=-Wl,-z,relro --sbin-path=/usr/sbin/nginx --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-ipv6 --with-threads --with-stream --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_addition_module --with-http_dav_module --with-http_gzip_static_module --with-http_sub_module --with-mail --with-mail_ssl_module
make
sudo make install

## TCP MODULE
git clone git@github.com:yaoweibin/nginx_tcp_proxy_module.git

## ADD MODULE
patch -p1 < /path/to/nginx_tcp_proxy_module/tcp.patch

## CONFIGURA COM O NOVO MÓDULO
sudo ./configure --add-module=/path/to/nginx_tcp_proxy_module

## INSTALA
sudo make && sudo make install

## TESTAR CONFIG NGINX
sudo nginx -t

## LINK SIMBÓLICO NGINX
sudo ln -s /etc/nginx/sites-available/teste1-mysql /etc/nginx/sites-enabled/teste1-mysql

## PERMITE EXECUTAR SEM SENHA(SUDO)
username ALL = NOPASSWD: /etc/init.d/nginx

## Unit do Nginx
/lib/systemd/system/nginx.service
sudo systemctl daemon-reload

sudo /etc/init.d/nginx reload
sudo /etc/init.d/nginx restart

## COMPILAR 1.11.5
--prefix=/etc/nginx 
--sbin-path=/usr/sbin/nginx  
--conf-path=/etc/nginx/nginx.conf 
--pid-path=/var/run/nginx.pid 
--lock-path=/var/run/nginx.lock 
--with-ipv6 
--with-http_ssl_module 
--with-threads 
--with-stream 
--with-http_slice_module

## COMPILAR 1.6.5
--with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' 
--with-ld-opt=-Wl,-z,relro 
--prefix=/usr/share/nginx 
--conf-path=/etc/nginx/nginx.conf 
--http-log-path=/var/log/nginx/access.log 
--error-log-path=/var/log/nginx/error.log 
--lock-path=/var/lock/nginx.lock 
--pid-path=/run/nginx.pid 
--http-client-body-temp-path=/var/lib/nginx/body 
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi 
--http-proxy-temp-path=/var/lib/nginx/proxy 
--http-scgi-temp-path=/var/lib/nginx/scgi 
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi 
--with-debug 
--with-pcre-jit 
--with-ipv6 
--with-http_ssl_module 
--with-http_stub_status_module 
--with-http_realip_module 
--with-http_auth_request_module 
--with-http_addition_module 
--with-http_dav_module 
--with-http_geoip_module 
--with-http_gzip_static_module 
--with-http_image_filter_module 
--with-http_spdy_module 
--with-http_sub_module 
--with-http_xslt_module 
--with-mail 
--with-mail_ssl_module 
--add-module=/build/nginx-ryOGNl/nginx-1.6.2/debian/modules/nginx-auth-pam 
--add-module=/build/nginx-ryOGNl/nginx-1.6.2/debian/modules/nginx-dav-ext-module 
--add-module=/build/nginx-ryOGNl/nginx-1.6.2/debian/modules/nginx-echo 
--add-module=/build/nginx-ryOGNl/nginx-1.6.2/debian/modules/nginx-upstream-fair 
--add-module=/build/nginx-ryOGNl/nginx-1.6.2/debian/modules/ngx_http_substitutions_filter_module

## MERGE DE AMBOS
--with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' 
--with-ld-opt=-Wl,-z,relro
--sbin-path=/usr/sbin/nginx  
--prefix=/usr/share/nginx 
--conf-path=/etc/nginx/nginx.conf 
--http-log-path=/var/log/nginx/access.log 
--error-log-path=/var/log/nginx/error.log 
--lock-path=/var/lock/nginx.lock 
--pid-path=/run/nginx.pid 
--http-client-body-temp-path=/var/lib/nginx/body 
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi 
--http-proxy-temp-path=/var/lib/nginx/proxy 
--http-scgi-temp-path=/var/lib/nginx/scgi 
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi 
--with-debug 
--with-pcre-jit 
--with-ipv6 
--with-threads
--with-stream 
--with-http_slice_module
--with-http_ssl_module 
--with-http_stub_status_module 
--with-http_realip_module 
--with-http_auth_request_module 
--with-http_addition_module 
--with-http_dav_module 
--with-http_gzip_static_module 
--with-http_sub_module 
--with-mail 
--with-mail_ssl_module 