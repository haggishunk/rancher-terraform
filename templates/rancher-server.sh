#!/usr/bin/bash

sudo docker run -d \
    --restart=unless-stopped \
    -p 8080:8080 \
    --name ${rancher-server-name} \
    rancher/server:stable \
    --db-host ${db-host}\
    --db-port ${db-port}\
    --db-name ${db-name}\
    --db-user ${db-user}\
    --db-pass ${db-pass}\
    --db-strict-enforcing
