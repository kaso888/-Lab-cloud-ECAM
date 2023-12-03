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
CLIENT(browser, "React")

AWSCLOUD(aws) {

    AMAZONS3(s3) {
        BUCKET(site,"fichier React")
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
- Charger dans le bucket le fichier `s3/index.html` (présent dans ce repo)
- Accéder au fichier chargé sur S3 et cliquer sur l'`URL de l'objet`. Un onglet s'ouvre avec un formulaire contenant `Valeur 1` et `Valeur 2`.
- Tester puis corriger le fichier `index.html`

### Nettoyage
- Supprimer le fichier présent dans le compatiment S3 puis supprimer le compartiment
- Supprimer la fonction Lambda
