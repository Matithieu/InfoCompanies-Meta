#!/bin/bash

# Lancer Docker Compose
docker compose -f "docker-compose-setup.yml" up -d

# Exécuter la commande Certbot pour obtenir les certificats
docker compose -f "docker-compose-setup.yml" run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d matithieu.com -d www.matithieu.com

# Modifier les permissions des fichiers de certificats
sudo chmod -R 777 ./certbot/conf/live/
sudo chmod -R 777 ./certbot/conf/archive/

cp -r ./certbot/conf/archive/* ./certbot/conf/live/
mv ./certbot/conf/archive/matithieu.com/cert1.pem ./certbot/conf/live/matithieu.com/cert.pem
mv ./certbot/conf/archive/matithieu.com/chain1.pem ./certbot/conf/live/matithieu.com/chain.pem
mv ./certbot/conf/archive/matithieu.com/fullchain1.pem ./certbot/conf/live/matithieu.com/fullchain.pem
mv ./certbot/conf/archive/matithieu.com/privkey1.pem ./certbot/conf/live/matithieu.com/privkey.pem

# Convertir les certificats en format PKCS12
# openssl pkcs12 -export -out server.p12 -inkey ./certbot/conf/live/matithieu.com/privkey.pem -in ./certbot/conf/live/matithieu.com/fullchain.pem -certfile ./certbot/conf/live/matithieu.com/chain.pem

# Arrêter Docker Compose
docker compose -f "docker-compose-setup.yml" down
