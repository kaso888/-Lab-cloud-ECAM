# Lab - Partie 2 - IaC sur AWS

## Prérequis du LAB
- Connaitre les commandes de base en shell : export, cd, mkdir, vi
- Connaitre les bases en réseau :
	- Adresse ip
	- Protocole
	- Port
	- Réseau ou host Source / destination
- Connaitre les commandes de base Terraform (cf cours précédent)
- Connaitre la déclaration des ressources principales en Terraform (cf cours précédent)

## Objectifs du LAB
- Déployer la même infrastructure du lab n°1 mais uniquement avec un outil de IaC (Terraform)
- Déployer les instances EC2
- Personnaliser les instances lors du primo déploiement (cloud-init)

## Aide
- Vous pouvez vous appuyer sur le support de cours Terraform présent dans lab/terraform/2023-12-15 Support terraform.pptx
- Si vous ne vous en sortez pas, n'hésitez pas à demander
- Les réponses se trouvent dans lab/terraform/aws.zip protégé par mot de passe :-)

## Initialisation de l'environnement
### Mise en place de l'environnement Terraform
- Dans le repository Gitlab, lancer l'outil gitpod
- Accepter la connexion avec votre compte gitlab
- Cliquer sur continue lorsque demandé
- Vous devriez basculer sur une url du type https://ecamssg-lab-yanpngswo9n.ws-eu106.gitpod.io/

### Test installation Terraform
- Pour gagner du temps dans l'exécution du lab, nous avons préinstaller dans un docker file la version du client Terraform
- Ouvrir un invite de commande puis lancer la commande permettant d'obtenir la version de Terraform. Vous devriez obtenir :
```
Terraform v1.6.5
on linux_amd64
```

### Initialisation du workspace
- Dans le terminal de la session Gitpod, créer un répertoire de travail, nommé par exemple workspace_aws, puis se placer dans ce répertoire
- Exporter les variables d'environnement suivantes avec les contenus communiqués au démarrage du LAB :
	- AWS_ACCESS_KEY_ID : l'id de la clé d'accès
	- AWS_SECRET_ACCESS_KEY : le secret de la clé
- Ces variables constituent les crendentials pour joindre l'api AWS depuis Terraform

## Provisioning des ressources via Terraform
### Création du provider AWS
- Dans le répertoire workspace, créer un fichier provider.tf avec les déclarations suivantes (voir slide 12 du support) :
	- la version minimum du provider AWS : 4.16
	- la version minimum de Terraform : 1.2.0
	- provider AWS
	- la région "eu-west-3"
- Dans l'invite de commande de gitpod, lancer la commande d'initialisation de l'environnement terraform
	- Vous devriez obtenir l'output suivant :
	
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 4.16"...
- Installing hashicorp/aws v4.67.0...
- Installed hashicorp/aws v4.67.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Création des groupes de sécurité pour les instances ec2 à déployer
- Créer un nouveau fichier terraform security.tf puis ajouter le contenu suivant en remplaçant <TRI> par votre trigrame :
```
resource "aws_security_group" "web-sg" {
  name        = "web-sg-<TRI>"
  description = "Allow inbound traffic to Web Server"
  vpc_id      = "vpc-0f94b22e7479bcb8f"

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "WebServer-sg-<TRI>"
  }
}

resource "aws_security_group" "api-sg" {
  name        = "api-sg-<TRI>"
  description = "Allow inbound traffic to API Server"
  vpc_id      = "vpc-0f94b22e7479bcb8f"

  ingress {
    description      = "HTTP from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "APIServer-sg-<TRI>"
  }
}

resource "aws_security_group" "db-sg" {
  name        = "db-sg-<TRI>"
  description = "Allow inbound traffic to data server"
  vpc_id      = "vpc-0f94b22e7479bcb8f"

  ingress {
    description      = "MYSQL/AURA from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "DataServer-sg-<TRI>"
  }
}

resource "aws_security_group" "all-sg" {
  name        = "allserver-sg-<TRI>"
  description = "Allow outbound traffic to all servers"
  vpc_id      = "vpc-0f94b22e7479bcb8f"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "AllServer-out-sg-<TRI>"
  }
}
```

- Lancer la commande terraform pour valider la configuration
	- vous devriez avoir 4 ressources à créer
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Se rendre sur la console AWS et constater l'apparition des nouvelles ressources


### Création de l'instance EC2 API server
- Pour personnaliser l'installation de l'instance ec2, créer un script user-data-api.sh et ajouter les lignes suivantes :
```
#!/bin/bash
curl https://gitlab.com/ecam-ssg/lab/-/raw/main/lab/api/init-vm-api-local.sh | bash
```

- Créer un nouveau fichier terraform et déclarer la ressource ec2 api server avec les caractéristiques suivantes (voir slide 15 du support) :
	- type de la ressource : aws_instance
	- nom de la ressource : api_server (par exemple, doit être un nom unique dans le même workspace terraform)
	- identifiant de l'image : ami-0493936afbe820b28 (correspondant à une image ubuntu)
	- gabarit de l'instance : t2.micro
	- groupes de sécurité : [aws_security_group.all-sg.id,aws_security_group.api-sg.id]
	- nom de l'instance dans l'ihm aws : API_Server_TRIGRAMME (TRIGRAMME : 1iere lettre prenom + 2 1iere lettre nom)
	- déclarer le script user-data-api.sh dans la configuration de l'instance
- Lancer la commande terraform pour valider la configuration
	- vous devriez avoir 1 ressource à créer
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Se rendre sur la console AWS et constater l'apparition de la nouvelle ressource

### Récupération d'output pour l'instance EC2 API Server
Pour pouvoir configurer le lien entre l'instance Web et l'instance API, il faut que vous récupériez avec Terraform l'adresse ip publique en IPV4 de l'instance
API précédemment créée. Pour cela :
- Créer un nouveau fichier terraform output.tf par exemple et déclarer la sortie suivante de l'instance API Server (voir slide 15 du support) :
	- id
	- public_ip
- Lancer la commande terraform pour valider la configuration
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Vous devriez obtenir l'output suivant
```
Outputs:

instance_api_server_id = "i-04e47f567f694e901"
instance_api_server_public_ip = "13.37.240.116"
```

### Création de l'instance EC2 Web server
- Pour personnaliser l'installation de l'instance ec2, créer un script user-data-web.sh et ajoute les commandes suivantes en remplaçant 
 ${DNS_IPV4_PUBLIC_API} par l'adresse ip publique obtenue à l'étape précédente
```
#!/bin/bash
curl https://gitlab.com/ecam-ssg/lab/-/raw/main/lab/web/init-vm-web.sh | bash
sudo sed -i "s/localhost/${DNS_IPV4_PUBLIC_API}/" /etc/nginx/sites-available/default
sudo systemctl restart nginx.service
```

- Créer un nouveau fichier terraform et déclarer la ressource ec2 web server avec les caractéristiques suivantes :
	- type de la ressource : aws_instance
	- nom de la ressource : web_server (par exemple, doit être un nom unique dans le même workspace terraform)
	- identifiant de l'image : ami-0493936afbe820b28 (correspondant à une image ubuntu)
	- gabarit de l'instance : t2.micro
	- groupes de sécurité : [aws_security_group.all-sg.id,aws_security_group.web-sg.id]
	- nom de l'instance dans l'ihm aws : Web_Server_TRIGRAMME (TRIGRAMME : 1iere lettre prenom + 2 1iere lettre nom)
	- déclarer le script user-data-web.sh dans la configuration de l'instance
- Lancer la commande terraform pour valider la configuration
	- vous devriez avoir 1 ressource à créer
- Une fois la validation effectuée, lancer la commande d'application de la configuration en confirmant l'action lorsque demandé
- Se rendre sur la console AWS et constater l'apparition de la nouvelle ressource

### Tests de l'application
- Vous pouvez dérouler les mêmes tests de l'application réalisés pour le lab n°1

## Destruction des ressources via Terraform
### Libération des ressources
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
### Consultation de la console AWS
- Se rendre sur la console AWS et vérifier que vos ressources ont bien été supprimées : à l'état résilié
