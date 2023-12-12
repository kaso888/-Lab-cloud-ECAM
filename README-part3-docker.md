# Lab - Partie 3 - Découverte de Docker

## Découverte de la CLI Docker

- Lancer un premier conteneur : `docker run -d -p 80:80 marcincuber/2048-game:latest`
    - La commande permet de, s'il n'existe pas en local, récupérer une image sur le repository Dockerhub et de lancer le conteneur associé.
    - Accéder à la webapp (dans Gitpod > onglet *Ports* > Port *80*)
- Lancer un deuxième conteneur (un serveur web NGINX): `docker run -d -p 8080:80 nginx` 
- Utiliser `docker ps` pour lister les conteneurs présents et récupérer l'id des conteneurs
- Utiliser `docker logs <containerId>` pour récupérer les logs du conteneur NGINX
- Arrêter le conteneur NGINX avec `docker stop <containerId>` et vérifier que l'application ne fonctionne plus
- Démarrer le conteneur NGINX avec `docker start <containerId>` et vérifier que l'application refonctionne
- Arrêter les conteneur et supprimer les avec `docker rm <containerId>`

## Déploiement de l'application du premier lab

L'objectif de cette partie est de déployer l'application du premier lab sur Docker.

### Lancement d'un conteneur MariaDB
- Lancer un conteneur MariaDB avec la commande suivante :
```sh
docker run \
    -e MYSQL_ROOT_PASSWORD=mypass \
    -e MYSQL_USER=admin \
    -e MYSQL_PASSWORD=Ecam123! \
    -e MYSQL_DATABASE=lab \
    -p 3306:3306 \
    -d \
    docker.io/library/mariadb:10.3
```
- Description des paramètres
    - L'option `-e` permet de définir un paramètre pour le conteneur
    - `-p` permet de faire du mapping de port (par défaut, les ports du conteneur ne sont pas accessibles)
    - `-d` permet de lancer le conteneur en mode détaché (i.e. en tâche de fond)
    - `docker.io/library/mariadb:10.3` indique le nom et la version de l'image à utiliser
- Récupérer l'id du conteneur et accéder aux logs de celui-ci
  - Quelles sont les dernières lignes de logs ?
        <details>
        <summary>Solution</summary>
        ```
        2023-12-11 17:13:12 0 [Note] Added new Master_info '' to hash table
        2023-12-11 17:13:12 0 [Note] mysqld: ready for connections.
        Version: '10.3.39-MariaDB-1:10.3.39+maria~ubu2004'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  mariadb.org binary distribution
        ```
        </details>

### Build et lancement de l'image Docker pour le composant API
- Dans le dossier `lab/docker/api`, un `Dockerfile` est présent pour pouvoir builder l'image. Consulter le contenu du fichier : 
    - Le mot-clé `FROM` permet d'indiquer l'image de base 
    - `COPY` permet de copier les ressources de l'application depuis le dossier local vers l'image (ici le binaire `lab-api` et le fichier de configuration)
    - `EXPOSE` permet d'indiquer sur quel port écoute l'application 
    - `CMD` permet d'indiquer la commande à lancer quand le conteneur démarre
- Builder l'image
    - Via le terminal, aller dans le dossier contenant le `Dockerfile` : `cd lab/docker/api`
    - Lancer la commande de build de l'image : `docker build . -t lab-api`
        - l'option `-t` permet d'indique le nom de l'image
- Lancer le conteneur avec :
    - Mapping de port `8080` -> `8080`
    - `network` : `host`
            <details>
            <summary>Solution</summary>
            `docker run -p 8080:8080 --network host lab-api`
            </details>


### Création d'une image Docker pour le composant web
- Dans le dossier `lab/docker/web`, créer un `Dockerfile` avec les éléments suivants :
    - Image de base : `nginx:1.25.3`
    - Nom de la nouvelle image `lab-web`
    - Copier le dossier `lab-web` dans `/var/www/html`
    - Copier le fichier `default.conf` dans `/etc/nginx/conf.d`
- Lancer le conteneur avec :
    - Mapping de port `80` -> `80`
    - `network` : `host`
- Accéder à l'URL de l'application créée (dans Gitpod > onglet *Ports* > Port *80*)
    - L'application doit fonctionner complètement
        <details>
        <summary>Solution</summary>
        
        Contenu du `Dockerfile`
        ```
        FROM nginx:1.25.3

        COPY lab-web/ /var/www/html
        COPY default.conf /etc/nginx/conf.d
        ```

        Commande à lancer :
        - Pour builder l'image : `docker build . -t lab-web`
        - Pour lancer le conteneur : `docker run -p 80:80 --network host lab-web`
        </details>
- Supprimer les conteneur
