# Lab - Partie 2 - IaC sur AWS

## Prérequis du LAB
- Connaitre les commandes de base en shell : export, cd, mkdir, vi
- Connaitre les bases en réseau :
	- Adresse ip
	- Protocole
	- Port
	- Source / destination
- Connaitre les commandes de base Terraform (cf cours précédent)
- Connaitre la déclaration des ressources principales en Terraform (cf cours précédent)

## Objectifs du LAB
- Déployer la même infrastructure du lab n°1 mais uniquement avec un outil de IaC (Terraform)
- Déployer les groupes de sécurité
- Déployer les instances EC2
- Personnaliser les instances lors du primo déploiement (cloud init)

## Initialisation de l'environnement
### Mise en place de l'environnement Terraform
- Dans le repository Gitlab, lancer l'outil gitpod
- Accepter la connexion avec votre compte gitlab
- Vous devriez basculer sur une url du type https://ecam-lab-r6h491jsld3.ws-eu77.gitpod.io/

### Test installation Terraform
- Pour gagner du temps dans l'exécution du lab, nous avons préinstaller dans un docker file la version du client Terraform
- Ouvrir un invite de commande puis lancer la commande permettant d'obtenir la version de Terraform. Vous devriez obtenir :
```
Terraform v1.3.6
on linux_amd64
```

### Initialisation du workspace
- Dans le terminal de la session Gitpod, créer un répertoire de travail, nommé par exempleworkspace_aws, puis se placer dans ce répertoire
- Exporter les variables d'environnement suivantes avec les contenus communiqués au démarrage du LAB :
	- AWS_ACCESS_KEY_ID : l'id de la clé d'accès
	- AWS_SECRET_ACCESS_KEY : le secret de la clé
- Ces variables constituent les crendentials pour joindre l'api AWS depuis Terraform

## Provisioning des ressources via Terraform
### Création du provider AWS
- Dans le répertoire workspace, créer un fichier provider.tf avec les déclarations suivantes :
	- la version minimum de Terraform : 1.2.0
	- la version minimum du provider AWS : 4.16
	- provider AWS
	- la région "eu-west-3"
- Dans l'invite de commande de gitpod, lancer la commande d'initialisation de l'environnement terraform
	- Vous devriez obtenir l'output suivant :
	
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 4.16"...
- Installing hashicorp/aws v4.45.0...
- Installed hashicorp/aws v4.45.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

### Création des groupes de sécurité pour les instances ec2 à déployer
- Créer un nouveau fichier terraform pour déclarer 4 groupes de sécurité :
	- 1 groupe de sécurité autorisant le protocole TCP, ports 443, 80 et 22 de l'instance web
	- 1 groupe de sécurité autorisant le protocole TCP pour les ports 8080 et 22 de l'instance api
	- 1 groupe de sécurité autorisant le protocole TCP pour le port 3306 de l'instance db
	- 1 groupe de sécurité autorisant tout le traffic sortant pour tous les protocoles et ports pour toutes les 3 instances EC2
- Utiliser l'id de vpc suivant : vpc-0777f2a2c8769e96d
- Lancer la commande terraform pour valider la configuration
	- vous devriez avoir 4 ressources à créer
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Se rendre sur la console AWS et constater l'apparition des nouvelles ressources

### Création de l'instance EC2 API server
- Pour personnaliser l'installation de l'instance ec2, créer un script user-data-api.sh et ajouter les lignes suivantes :
```
#!/bin/bash
curl https://gitlab.com/ecam/lab/-/raw/main/lab/api/init-vm-api-h2.sh | bash
```

- Créer un nouveau fichier terraform et déclarer la ressource ec2 api server avec les caractéristiques suivantes :
	- type de la ressource : aws_instance
	- nom de la ressource : api_server (par exemple, doit être un nom unique dans le même workspace terraform)
	- identifiant de l'image : ami-0493936afbe820b28 (correspondant à une image ubuntu)
	- gabarit de l'instance : t2.micro
	- groupes de sécurité créé précédemment (inbound and outbound)
	- nom de l'instance dans l'ihm aws : API_Server_TRIGRAMME (TRIGRAMME : 1iere lettre prenom + 2 1iere lettre nom)
	- déclarer le script user-data-api.sh dans la configuration de l'instance
- Lancer la commande terraform pour valider la configuration
	- vous devriez avoir 1 ressource à créer
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Se rendre sur la console AWS et constater l'apparition de la nouvelle ressource

### Récupération d'output pour l'instance EC2 API Server
Pour pouvoir configurer le lien entre l'instance Web et l'instance API, il faut que vous récupériez avec Terraform l'adresse ip publique en IPV4 de l'instance
API précédemment créée. Pour cela :
- Créer un nouveau fichier terraform et déclarer la sortie suivante de l'instance API Server :
	- id
	- public_ip
- Lancer la commande terraform pour valider la configuration
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Vous devriez onbtenir l'output suivant
```
Outputs:

instance_api_server_id = "i-04e47f567f694e901"
instance_api_server_public_ip = "13.37.240.116"
```

### Création de l'instance EC2 Web server
- Pour personnaliser l'installation de l'instance ec2, créer un script user-data-web.sh et ajoute les commandes suivantes en remplaçant 
 ${DNS_IPV4_PUBLIC_API} par l'adresse ip obtenue à l'étape précédente
	```
#!/bin/bash
curl https://gitlab.com/ecam/lab/-/raw/main/lab/web/init-vm-web.sh | bash
sudo sed -i "s/localhost/${DNS_IPV4_PUBLIC_API}/" /etc/nginx/sites-available/default
sudo systemctl restart nginx.service
```

- Créer un nouveau fichier terraform et déclarer la ressource ec2 web server avec les caractéristiques suivantes :
	- type de la ressource : aws_instance
	- nom de la ressource : web_server (par exemple, doit être un nom unique dans le même workspace terraform)
	- identifiant de l'image : ami-0493936afbe820b28 (correspondant à une image ubuntu)
	- gabarit de l'instance : t2.micro
	- groupes de sécurité créés précédemment (inbound and outbound)
	- nom de l'instance dans l'ihm aws : Web_Server_TRIGRAMME (TRIGRAMME : 1iere lettre prenom + 2 1iere lettre nom)
	- déclarer le script user-data-web.sh dans la configuration de l'instance
- Lancer la commande terraform pour valider la configuration
	- vous devriez avoir 1 ressource à créer
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Se rendre sur la console AWS et constater l'apparition de la nouvelle ressource

### Création de l'instance EC2 Data server
- Créer un nouveau fichier terraform et déclarer la ressource ec2 data server avec les caractéristiques suivantes :
	- type de la ressource : aws_instance
	- nom de la ressource : data_server (par exemple, doit être un nom unique dans le même workspace terraform)
	- identifiant de l'image : ami-0493936afbe820b28 (correspondant à une image ubuntu)
	- gabarit de l'instance : t2.micro
	- groupes de sécurité créé précédemment (inbound and outbound)
	- nom de l'instance dans l'ihm aws : Data_Server_TRIGRAMME (TRIGRAMME : 1iere lettre prenom + 2 1iere lettre nom)
- Lancer la commande terraform pour valider la configuration
	- vous devriez avoir une ressource à créer
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Se rendre sur la console AWS et constater l'apparition de la nouvelle ressource

### Tests de l'application
- Vous pouvez dérouler les mêmes tests de l'application réalisés pour le lab n°1

## Destruction des ressources via Terraform
## Libération des ressources
- Lancer la commande de destruction de toutes les ressources terraform
	- vous devriez avoir 7 ressources à Supprimer
- Confirmer la commande en entrant yes
- Vous devriez obtenir la sortie suivante :
	```
	aws_instance.web_server: Destroying... [id=i-08b759cc1ffca6d0f]
	aws_instance.db_server: Destroying... [id=i-0944d265e59d2ed85]
	aws_instance.api_server: Destroying... [id=i-04e47f567f694e901]
	aws_instance.web_server: Still destroying... [id=i-08b759cc1ffca6d0f, 10s elapsed]
	aws_instance.db_server: Still destroying... [id=i-0944d265e59d2ed85, 10s elapsed]
	aws_instance.api_server: Still destroying... [id=i-04e47f567f694e901, 10s elapsed]
	aws_instance.web_server: Still destroying... [id=i-08b759cc1ffca6d0f, 20s elapsed]
	aws_instance.api_server: Still destroying... [id=i-04e47f567f694e901, 20s elapsed]
	aws_instance.db_server: Still destroying... [id=i-0944d265e59d2ed85, 20s elapsed]
	aws_instance.web_server: Destruction complete after 30s
	aws_security_group.web-sg: Destroying... [id=sg-052a0569b975be8de]
	aws_instance.api_server: Still destroying... [id=i-04e47f567f694e901, 30s elapsed]
	aws_instance.db_server: Still destroying... [id=i-0944d265e59d2ed85, 30s elapsed]
	aws_security_group.web-sg: Destruction complete after 1s
	aws_instance.api_server: Destruction complete after 40s
	aws_instance.db_server: Destruction complete after 40s
	aws_security_group.api-sg: Destroying... [id=sg-0ef4eb6af1c931c0c]
	aws_security_group.all-sg: Destroying... [id=sg-04a5db48a035d8dd9]
	aws_security_group.db-sg: Destroying... [id=sg-0d467f870b1583ddc]
	aws_security_group.api-sg: Destruction complete after 1s
	aws_security_group.all-sg: Destruction complete after 1s
	aws_security_group.db-sg: Destruction complete after 1s

	Destroy complete! Resources: 7 destroyed.
	```
## Consultation de la console AWS
- Se rendre sur la console AWS et vérifier que vos ressources ont bien été supprimées : à l'état résilié
