# Lab - Partie 1 - IaaS sur AWS 

## Architecture

```plantuml
@startuml
'Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
'SPDX-License-Identifier: MIT (For details, see https://github.com/awslabs/aws-icons-for-plantuml/blob/master/LICENSE)

!define AWSPuml https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/v14.0/dist
!include AWSPuml/AWSCommon.puml
!include AWSPuml/AWSSimplified.puml
!include AWSPuml/Compute/EC2.puml
!include AWSPuml/Compute/EC2Instance.puml
!include AWSPuml/Database/RDS.puml
!include AWSPuml/Groups/AWSCloud.puml
!include AWSPuml/Groups/VPC.puml
!include AWSPuml/Groups/AvailabilityZone.puml
!include AWSPuml/Groups/PublicSubnet.puml
!include AWSPuml/Groups/PrivateSubnet.puml
!include AWSPuml/NetworkingContentDelivery/VPCNATGateway.puml
!include AWSPuml/NetworkingContentDelivery/VPCInternetGateway.puml
!include AWSPuml/General/Users.puml

hide stereotype
skinparam linetype ortho


Users(users, "utilisateurs", "millions of users")

AWSCloudGroup(cloud) {
  VPCGroup(vpc) {

    AvailabilityZoneGroup(az_1, "\tAvailability Zone 1\t") {
      PublicSubnetGroup(az_1_public, "Public subnet") {

        EC2Instance(ec2_web, "EC2 Web", "")
        EC2Instance(ec2_api, "EC2 API", "")
        RDS(rds, "RDS - MariaDB", "")
      }
    }

    ec2_web --> ec2_api
    ec2_api --> rds

  }
}

users-->ec2_web
@enduml

```

- Sur `EC2 Web` : un serveur NGINX est déployé et écoute sur le port `80`. Il permet de :
    - Exposer les ressources Angular (html, js, css, etc.) lors de l'accès sur la racine du serveur
    - Jouer le rôle de reverse proxy pour les API : les appels sur le `\api` sont routées vers l'instance `EC2 API` sur le port `8080`
- Sur `EC2 API` : une application java est déployée et écoute sur le port `8080`. Elle accède à la base de données `RDS MariaDB`.
- `RDS Maria DB` est une base de données MariaDB qui écoute sur le port `3306`.

*Remarque :* Cette architecture ne respecte pas les bonnes pratiques. En principe, `EC2 API` et `RDS Maria DB` aurait dû être déployés dans des subnets privés.

## Connexion à la console AWS
- Se connecter à la console avec les informations communiquées
- Sélectionner la zone Paris (eu-west-3)

## Création d'une base de données MariaDB avec AWS RDS

### Description de RDS
[Amazon Relational Database](https://aws.amazon.com/fr/rds/) Service (Amazon RDS) est un ensemble de services gérés qui facilite la configuration, l'utilisation et la mise à l'échelle des bases de données dans le cloud. 

Le service permet d'utiliser sept moteurs : Amazon Aurora compatible avec MySQL, Amazon Aurora compatible avec PostgreSQL, MySQL, MariaDB, PostgreSQL, Oracle, et SQL Server

### Tâches
- Accéder au [service RDS](https://eu-west-3.console.aws.amazon.com/rds/home?region=eu-west-3#) via la console 
- Créer une base de données
    - Informations
        - Identifiant d'instance de base de données : `${PRENOM}-db`
        - Mode : création standard
        - Moteur : dernière version de MariaDB 
        - Modèle : **Offre gratuite** - db.t3.micro
        - Identifiant principal : `admin`
        - Mot de passe : `admin123!`
        - Stockage alloué : 20Go
        - Groupes de sécurité VPC existants : sélectionner `db-sg`
- La création de l'instance va prendre 5/10 minutes. Passer à la suite.

## Création d'une VM pour l'application Angular via AWS EC2

### Description de AWS EC2
[Amazon Elastic Compute Cloud](https://aws.amazon.com/fr/ec2/) ou EC2 est un service permettant à des tiers de louer des serveurs sur lesquels exécuter leurs propres applications web. EC2 permet un déploiement extensible des applications en fournissant une interface web par laquelle un client peut créer des machines virtuelles, c'est-à-dire des instances du serveur, sur lesquelles le client peut charger n'importe quel logiciel de son choix.

### Tâches
- Accéder au [service EC2](https://eu-west-3.console.aws.amazon.com/ec2/home?region=eu-west-3#Home:) via la console 
- Créer une instance EC2
	- Nom : `${PRENOM}-web-ec2`
    - Image OS : `Ubuntu 22.04 LTS`
	- Type d'instance : `t2.micro`
	- Paire de clé : `admin-key`
	- Groupe de sécurité (Pare-feu) : `web-sg`
- Après quelques minutes : l'instance est disponible
- Accéder à la description de l'instance (Menu à gauche > Instances > Cliquer sur l'id de votre instance)
    - Noter la valeur de `DNS IPv4 public`. Cet URL vous permettra d'accéder à l'API via votre navigateur
    - Vérifier que l'état est `En cours d'exécution`
- Installation de l'application API Java
    - Depuis la page de l'instance, cliquer sur `Se connecter`
    - Sélectionner `EC2 Instance Connecter` puis cliquer sur `Se connecter`. Un terminal s'ouvre dans un nouvel onglet
    - Exécuter le script d'installation : `curl https://gitlab.com/ecam/lab/-/raw/main/lab/web/init-vm-web.sh | bash`
    - Le script se termine avec `Web app started`
- Vérifier son fonctionnement en accédant via un navigateur à `http://${DNS_IPV4_PUBLIC}`. Une application doit apparaitre avec un gros carré noir au milieu. Ce carré noir implique que l'application Angular fonctionne mais qu'il n'y a pas d'API.



## Création d'une VM pour l'application API Java via AWS EC2

### Tâches
- Accéder au [service EC2](https://eu-west-3.console.aws.amazon.com/ec2/home?region=eu-west-3#Home:) via la console 
- Créer une instance EC2
	- Nom : `${PRENOM}-api-ec2`
    - Image OS : `Ubuntu 22.04 LTS`
	- Type d'instance : `t2.micro`
	- Paire de clé : `admin-key`
	- Groupe de sécurité (Pare-feu) : `api-sg`
- Après quelques minutes : l'instance est disponible
- Accéder à la description de l'instance (Menu à gauche > instances > Cliquer sur le nom de votre instance)
    - Noter la valeur de `DNS IPv4 public`. Cet URL vous permettra d'accéder à l'API via votre navigateur
    - Vérifier que l'état est `En cours d'exécution`
- Installation de l'application API Java
    - Depuis la page de l'instance, cliquer sur `Se connecter`
    - Sélectionner `EC2 Instance Connector` puis cliquer sur `Se connecter`. Un terminal s'ouvre dans un nouvel onglet
    - Exécuter le script d'installation : `curl https://gitlab.com/ecam/lab/-/raw/main/lab/api/init-vm-api.sh | bash`
    - Le script se termine avec `API app created`

## Connexion des instances entre elles
Les deux instances EC2 et la base de données ont été créées mais elles ne communiquent pas entre elles.

### Connexion entre l'API et la base de données
- Via la console RDS, noter la valeur du `Point de terminaison` (i.e. l'url d'accès à la base de données)
- Via `EC2 Instance Connector`, se connecter au terminal de l'instance EC2 API
    - Accéder aux logs de l'application avec la commande `tail -100 /usr/local/applications/nohup.out`.
    - Identifier le problème et corriger le fichier de configuration de l'application `/usr/local/applications/launch.env`.
        <details>
        <summary>Solution</summary>
        
        L'URL de la base de données est incorrecte (`FIXME`). Il faut la remplacer avec le `Point de terminaison`.
        Il faut utiliser un éditeur (`vim` ou `nano`) pour éditer le fichier ou exécuter la commande `sed -i "s/FIXME/${POINT_DE_TERMINAISON}/" /usr/local/applications/launch.env`

        </details>

- Après quelques minutes, l'application devrait être disponible
    - Vérifier son fonctionnement en accédant via un navigateur à `http://${DNS_IPV4_PUBLIC_API}:8080/api/place/1`
    - Un JSON doit apparaître.

### Connexion entre l'application Angular et l'API
- Via `EC2 Instance Connector`, se connecter au terminal de l'instance EC2 **Web**
    - Accéder aux logs de l'application avec la commande `tail -100 /var/log/nginx/nginx_error.log`.
    - Identifier le problème et corriger le fichier de configuration de l'application `/etc/nginx/sites-available/default`.
        <details>
        <summary>Solution</summary>
        
        L'URL de l'API est incorrecte (`localhost`). Il faut la remplacer avec le `DNS IPv4 public` de l'instance API.
        Il faut utiliser un éditeur (`vim` ou `nano`) pour éditer le fichier ou exécuter la commande `sudo sed -i "s/localhost/${DNS_IPV4_PUBLIC_API}/" /etc/nginx/sites-available/default`.


        </details>
    - Après correction, redémarrer le serveur Nginx : `sudo systemctl restart nginx.service`.
- Après quelques instants, l'application Angular doit être fonctionnelle.
    - Vérifier son fonctionnement en accédant via un navigateur à `http://${DNS_IPV4_PUBLIC_WEB}`

## Nettoyage
Supprimer les ressources créées :
- RDS 
    - Sur la page listant les bases, sélectionner la base et cliquer sur `Modifier` > `Supprimer`
    - Décocher les cases `Créer un instantané final ?` et `Conserver les sauvegardes automatiques`, et cocher `Je reconnais qu'au moment de la suppression de l'instance, les sauvegardes automatiques, y compris les instantanés système et la récupération à un moment donné, ne seront plus disponibles.`
    - Supprimer l'instance
- EC2 
    - Sur la page listant les instances EC2, sélectionner les instances `${PRENOM}-web-ec2` et `${PRENOM}-api-ec2`
    - Cliquer sur `Etat de l'instance` > `Résilier`


# Lab - Partie 2 - FaaS sur AWS 

## Architecture

```plantuml
@startuml component
!include <aws/common>
!include <aws/Storage/AmazonS3/AmazonS3>
!include <aws/Compute/AWSLambda/AWSLambda>
!include <aws/Compute/AWSLambda/LambdaFunction/LambdaFunction>
!include <aws/Database/AmazonDynamoDB/AmazonDynamoDB>
!include <aws/Database/AmazonDynamoDB/table/table>


!include <aws/common>
!include <aws/ApplicationServices/AmazonAPIGateway/AmazonAPIGateway>
!include <aws/Compute/AWSLambda/AWSLambda>
!include <aws/Compute/AWSLambda/LambdaFunction/LambdaFunction>
!include <aws/Database/AmazonDynamoDB/AmazonDynamoDB>
!include <aws/Database/AmazonDynamoDB/table/table>
!include <aws/General/AWScloud/AWScloud>
!include <aws/General/client/client>
!include <aws/General/user/user>
!include <aws/SDKs/JavaScript/JavaScript>
!include <aws/Storage/AmazonS3/AmazonS3>
!include <aws/Storage/AmazonS3/bucket/bucket>
!define AWSPuml https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/v11.1/dist

!includeurl AWSPuml/AWSCommon.puml

!includeurl AWSPuml/SecurityIdentityCompliance/Cognito.puml



USER(user) 
CLIENT(browser, "Angular")

AWSCLOUD(aws) {

    AMAZONS3(s3) {
        BUCKET(site,"fichier Angular")
    }

    AWSLAMBDA(lambda) {
        LAMBDAFUNCTION(lambda_add,todos)
    }
}

user - browser

browser -> site

browser -> lambda_add

@enduml
```

L'application à déployer est un multiplicateur :
- Le site web static est exposé dans un bucket S3 public
- La fonction de multiplication est déployée via Lambda

## Utilisation de AWS Lambda
### Description de AWS Lambda
[AWS Lambda](https://aws.amazon.com/fr/lambda/) est un FaaS. C'est-à-dire, un service qui permet d'exécuter du code pour presque tout type d'application ou de service de backend, sans vous soucier de l'allocation ou de la gestion des serveurs.  

### Tâches
- Accéder au [service Lambda](https://eu-west-3.console.aws.amazon.com/lambda/home?region=eu-west-3#/functions) via la console AWS
- Créer une première fonction
    - nom : `${PRENOM}-add-lambda`
    - Techno : `Node.js 18.x`
    - Role : utiliser un role existant : `xavier-add-lambda-role-5wn8pt93`
    - Activer `Activer l'URL de fonction` avec l'authentification `NONE` afin d'avoir accès à la fonction depuis un navigateur
    - Code source :
```javascript 
export const handler = async(event) => {
    console.log("Received event: ", event);
    const response = {
        statusCode: 200,
        headers: {
            "Access-Control-Allow-Headers" : "Content-Type",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "OPTIONS,GET"
        },
        body: '{"result":"' + (Number(event["queryStringParameters"]['val1']) + Number(event["queryStringParameters"]['val2'])) +'"}',
    };
    return response;
};
```
- Depuis la page de la fonction, récupérer l'`URL de fonction`
- Via un navigateur, accéder à l'url `https://${URL_FONCTION}?val1=1&val2=14`
- Modifier la fonction pour réaliser une multiplication au lieu d'une addition

## Déploiemet d'un site web static via AWS S3
### Description de AWS S3
Amazon Simple Storage Service ([Amazon S3](https://aws.amazon.com/fr/s3/)) est un service de stockage d'objets qui offre une capacité de mise à l'échelle, une disponibilité des données, une sécurité et des performances de pointe. 

Il peut être utilisé pour exposer des [sites web static](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html).


### Tâches
- Accéder au [service S3](https://s3.console.aws.amazon.com/s3/buckets?region=eu-west-3) via la console AWS
- Créer un bucket/compatiment (espace de stockage)
    - nom : `${PRENOM}-ecam-lab-s3`
    - Region `eu-west-3`
    - Décocher `Bloquer tous les accès publics`
- Accéder au compartiment et modifier la `Stratégie de compartiment` dans l'onglet `Autorisations`
    - Politique de sécurité
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::${PRENOM}-ecam-lab-s3/*"
            ]
        }
    ]
}
```
- Charger dans le bucket le fichier `s3/index.html`
- Accéder au fichier chargé sur S3 et cliquer sur l'`URL de l'objet`. Un onglet s'ouvre avec un formulaire contenant `Valeur 1` et `Valeur 2`.
- Tester puis corriger le fichier `index.html`
