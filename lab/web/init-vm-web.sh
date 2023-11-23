#!/bin/bash
sudo apt update
sudo apt -y install nginx

echo "Downloding React app"
cd /tmp/
curl https://gitlab.com/ecam-ssg/lab/-/raw/main/lab/web/lab-web.tar?inline=false --output lab-web.tar
tar xvf lab-web.tar
sudo cp build/*  /var/www/html/

curl https://gitlab.com/ecam-ssg/lab/-/raw/main/lab/web/nginx.conf?inline=false --output nginx.conf
sudo cp nginx.conf /etc/nginx/sites-available/default
sudo chmod 774 /etc/nginx/sites-available/default
sudo systemctl restart nginx.service


echo "Web app started"