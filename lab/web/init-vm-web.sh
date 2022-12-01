#!/bin/bash
sudo apt update
sudo apt -y install nginx

echo "Downloding angular app"
cd /tmp/
curl https://gitlab.com/ecam/lab/-/raw/main/lab/web/bplace.tar?inline=false --output bplace.tar
tar xvf bplace.tar
sudo cp dist/*  /var/www/html/

curl https://gitlab.com/ecam/lab/-/raw/main/lab/web/nginx.conf?inline=false --output nginx.conf
sudo cp nginx.conf /etc/nginx/sites-available/default
sudo chmod 774 /etc/nginx/sites-available/default
sudo systemctl restart nginx.service


echo "Web app started"