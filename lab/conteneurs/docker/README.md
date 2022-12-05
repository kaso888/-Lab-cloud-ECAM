Commandes
```bash
# Création de l'image
docker build -t exemple-image .

# Lancement de l'image
docker run -it --rm -d -p 80:80 --name exemple-conteneur exemple-image

# Tag et push sur le registry
docker tag nom-image:latest registry/nom-image:1.0
docker push registry/nom-image:1.0
```
