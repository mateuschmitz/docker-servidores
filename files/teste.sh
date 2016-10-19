#!/bin/bash

max=3

for i in `seq 1 $max`
do
    name="teste$i"
    echo "Subindo container teste$i"
    ./new_container.sh -d $name".com" -h $name -u $name -up $name -rp $name -mrp $name
done