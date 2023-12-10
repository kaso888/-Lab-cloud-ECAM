

docker run -e MYSQL_ROOT_PASSWORD=mypass -e MYSQL_USER=admin -e MYSQL_PASSWORD=Ecam123! -e MYSQL_DATABASE=lab -p 3306:3306 docker.io/library/mariadb:10.3

## Build de l'image Docker pour la partie API
- Dans le dossier `lab/docker/api`, un `Dockerfile` est présent pour pouvoir builder l'image
    - Le mot-clé `FROM` permet d'indiquer l'image de base (ici Ubuntu)
    - `COPY` permet de copier les ressources de l'application (ici le binaire `lab-api` et le fichier de configuration)
    - `EXPOSE` permet d'indiquer sur quel port écoute l'application (ici 8080)
    - `CMD` permet d'indiquer la commande à lancer quand le conteneur démarre
- Builder l'image
    - Via le terminal, aller dans le dossier contenant le `Dockerfile` : `cd lab/docker/api`
    - Lancer la commande de build de l'image : `docker build . -t lab-api`
        - l'option `-t` permet d'indique le nom de l'image
- Lancer le conteneur avec :
    - Mapping de port `80` -> `80`
    - `network` : `host`

<details>
        <summary>Solution</summary>
        docker run -p 8080:8080 --network host lab-api
</details>


## Création d'une image Docker pour le composant web
- Dans le dossier `lab/docker/web`, créer un `Dockerfile` avec les éléments suivants :
    - Image de base : `nginx:1.25.3`
    - Nom de la nouvelle image `lab-web`
    - Copier le dossier `lab-web` dans `/var/www/html`
    - Copier le fichier `default.conf` dans `/etc/nginx/conf.d`
- Lancer le conteneur avec :
    - Mapping de port `80` -> `80`
    - `network` : `host`
- Accéder à l'URL de l'application créée (Dans Gitpod > onglet *Ports* > Port *80*)
    - L'application doit fonctionner complètement
- 

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
