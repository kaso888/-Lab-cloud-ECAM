import en local des images pour l'utilisation dans microk8s

Depuis le dossier lab/docker/api

```console
podman build -t localhost/lab-api:latest .

podman save localhost/lab-api:latest -o lab-api.tar

microk8s ctr image import lab-api.tar 
```

depuis le dossier lab/docker/web

```console
podman build -t localhost/lab-web:latest .

podman save localhost/lab-web:latest -o lab-web.tar

microk8s ctr image import lab-web.tar 
```

Obtenir l'IP de votre WSL ubuntu:

```console
wsl -d Ubuntu -- hostname -I
```

Installation de l'application dans le cluster kubernetes:

depuis le répertoire helm
```console
microk8s helm install -f values.yaml demo .
```

Visualisation de l'application directement depuis le navigateur à partir de l'IP du WSL

http://IP