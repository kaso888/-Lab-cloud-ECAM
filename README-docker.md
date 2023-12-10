

docker run --name mariadb -e MYSQL_ROOT_PASSWORD=mypass -e MYSQL_USER=admin -e MYSQL_PASSWORD=Ecam123! -e MYSQL_DATABASE=lab -p 3306:3306 -d docker.io/library/mariadb:10.3

docker run -p 8080:8080 --network host lab-back