#!/bin/bash
sudo mkdir /usr/local/applications
sudo chmod 777 /usr/local/applications
cd /usr/local/applications


echo "Downloding API app"
curl https://gitlab.com/ecam-ssg/lab/-/raw/main/lab/api/lab-back?inline=false --output lab-back
curl https://gitlab.com/ecam-ssg/lab/-/raw/main/lab/api/launch.sh?inline=false --output launch.sh
curl https://gitlab.com/ecam-ssg/lab/-/raw/main/lab/api/properties.ini?inline=false --output properties.ini

chmod +x launch.sh lab-back
nohup ./launch.sh &

echo "API app created"