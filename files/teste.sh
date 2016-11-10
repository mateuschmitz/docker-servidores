#!/bin/bash

max=3

for i in `seq 1 $max`
do
    name="teste$i"
    echo "Subindo container teste$i"
    ./new_container.sh -d $name".com" -h $name -u $name -up $name -rp $name -mrp $name
done

#unlink /etc/nginx/proxies-enabled/naughtyhost.com && unlink /etc/nginx/proxies-available/naughtyhost.com && unlink /etc/nginx/sites-available/naughtyhost.com && unlink /etc/nginx/sites-enabled/naughtyhost.com 