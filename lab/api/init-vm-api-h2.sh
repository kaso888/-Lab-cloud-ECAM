#!/bin/bash
sudo apt update
sudo apt -y install openjdk-11-jdk mariadb-client

sudo mkdir /usr/local/applications
sudo chmod 777 /usr/local/applications
cd /usr/local/applications


echo "Downloding API app"
curl https://gitlab.com/ecam-ssg/lab/-/raw/main/lab/api/bplace-h2.jar?inline=false --output bplace.jar

nohup java -jar bplace.jar &
echo "API app started"
