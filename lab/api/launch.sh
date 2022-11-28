#!/bin/bash

while true
do
 . launch.env
 mysql -u $USERNAME -h $HOST --password=$PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB;"
 java -jar bplace.jar --spring.datasource.url=jdbc:mariadb://$HOST:3306/$DB --spring.datasource.username=$USERNAME --spring.datasource.password=$PASSWORD
 sleep 30
done