# Diagrammes PlantUML

Ce dossier contient les diagrammes PlantUML utilisés dans la documentation.

## Utilisation

Les diagrammes sont rendus automatiquement dans GitHub en utilisant le serveur PlantUML public :

```markdown
![Nom du diagramme](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/yoann2968/enib-cloud/main/diagrams/nom-du-fichier.puml)
```

## Fichiers

- `aws-architecture.puml` - Architecture IaaS sur AWS (EC2, RDS)
- `faas-architecture.puml` - Architecture FaaS sur AWS (Lambda, S3)

## Alternatives pour le rendu

### Option 1 : Serveur PlantUML public (recommandé)
- Avantages : Simple, aucune maintenance
- Inconvénients : Dépendance externe

### Option 2 : Images statiques
- Générer les images localement et les commiter
- Plus fiable mais nécessite une mise à jour manuelle

### Option 3 : GitHub Actions
- Automatiser la génération d'images via CI/CD
- Plus complexe mais entièrement automatisé