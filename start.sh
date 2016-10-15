#!/bin/bash
if pgrep "apache2" > /dev/null
then
    # rodando
else
    service apache2 start
fi