
# Démonstration Kubernetes

## Environnement de démonstration

- Windows subsystem Linux : [Ubuntu](https://ubuntu.com/wsl)
- Environnement Kubernetes local: [Microk8s](https://microk8s.io/) 

### Installation de l'environnement

- [Installer WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Activer systemd](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#systemd-support)
- [Installer microk8s](https://ubuntu.com/tutorials/install-a-local-kubernetes-with-microk8s#1-overview)
- [Installer minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download)
- [Iximiuz : environnement en ligne (limité à 1h/jour)](https://labs.iximiuz.com/)


## Introduction

Kubernetes est très complet, il couvre une gamme de concepts allant de l'exécution de containers à la gestion des flux entrants et sortants, en passant par la mise à l'échelle et la gestion de la stratégie de volumes de données.

Pour une introduction à Kubernetes et les différents concepts qu'il manipule, la [documentation officielle](https://kubernetes.io/fr/docs/concepts/overview/what-is-kubernetes/) est un excellent point de départ. 

Cette démonstration va présenter un exemple simple d'un serveur web que l'on va déployer, mettre à l'échelle, vérifier que la  continuité de service est bien assurée et rendre disponible à d'autres pods.


## Démonstration

### Concepts manipulés

- [Node](https://kubernetes.io/fr/docs/concepts/architecture/nodes/)
- [Pod](https://kubernetes.io/fr/docs/concepts/workloads/pods/pod-overview/)
- [Deployment](https://kubernetes.io/fr/docs/concepts/workloads/controllers/deployment/)
- [Rolling updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
- [Service](https://kubernetes.io/fr/docs/concepts/services-networking/service/)
- [Client Kubernetes](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-strong-getting-started-strong-)


### Node d'exécution

Affichage des nodes  du cluster Kubernetes.
```
kubectl get nodes
```

Comme on est sur un environnement de démonstration local, on n'a qu'un seul noeud où déployer les pods, il est fonctionnel et tourne dans la version 1.26.4 :
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   47m   v1.31.0
```

### Déclaration d'objets Kubernetes via des fichiers Yaml

Pour créer [un objet dans Kubernetes](https://kubernetes.io/docs/concepts/overview/working-with-objects/), il faut le déclarer en décrivant l'état souhaité. Pour ce faire, on utilise généralement un fichier au [format YAML](https://kubernetes.io/docs/concepts/overview/working-with-objects/#describing-a-kubernetes-object).


#### Regardons le contenu d'un fichier de déploiement 
```
cat deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
On voit que l'on décrit un pod Nginx en version 1.14.2, exposant le port 80 et déployé en 3 examplaires (replicas).

#### Créons le déploiement

On vérifie qu'on n'a aucun objet existant avant : 

```console
$ kubectl get deployments
No resources found in default namespace.
$ kubectl get pods
No resources found in default namespace.
```


On demande à Kubernetes de créer l'objet décrit dans le fichier deployment.yaml

```
$ kubectl apply -f deployment.yaml
deployment.apps/nginx-deployment created
```

On vérifie que tout a été créé : 
```
$ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           36s
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-85996f8dbd-6vvhk   1/1     Running   0          37s
nginx-deployment-85996f8dbd-v4wrb   1/1     Running   0          37s
nginx-deployment-85996f8dbd-l2lhp   1/1     Running   0          37s
```

On trouve bien que l'on a maintenant un déploiement et 3 instances du pod Nginx.

### Déploiement et replicas

Kubernetes doit assurer de déployer le bon nombre de replicas demandées dans le déploiement.

Que se passe-t-il si j'en supprime un ?
```console
$ kubectl delete pod nginx-deployment-85996f8dbd-6vvhk
pod "nginx-deployment-85996f8dbd-6vvhk" deleted
$ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-85996f8dbd-v4wrb   1/1     Running   0          3m46s
nginx-deployment-85996f8dbd-l2lhp   1/1     Running   0          3m46s
nginx-deployment-85996f8dbd-gjvdd   1/1     Running   0          16s
```
On voit que le pod supprimé n’apparaît plus. Par contre, un nouveau pod ```nginx-deployment-85996f8dbd-gjvdd``` a été créé. En regardant la colonne "AGE", on voit qu'un des pods est plus récent que les autres.


### Gestion du nombre de replicas

Dans la déclaration YAML, on a demandé 3 replicas du pod.  C'est bien ce qu'on a : 
```
$ kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
nginx-deployment-57b465fc78-qwzst   1/1     Running   0          4m30s
nginx-deployment-57b465fc78-66m5m   1/1     Running   0          3m17s
nginx-deployment-57b465fc78-av15r   1/1     Running   0          2m35s
```

On peut toutefois modifier en direct le nombre de replicas avec la commande  ```scale``` du client. On va réduire le nombre de replicas à 2.

```
$ kubectl scale deployment nginx-deployment --replicas=2
deployment.apps/nginx-deployment scaled
```
Si on affiche à nouveau les pods, on voit qu'on en a un de moins qu'avant :
```
$ kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
nginx-deployment-57b465fc78-qwzst   1/1     Running   0          6m20s
nginx-deployment-57b465fc78-66m5m   1/1     Running   0          5m7s
```

Il est possible d'adapter automatiquement le nombre de pods déployés. On parle d'[autoscaling horizontal](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). Kubernetes se base sur un système de *métriques* pour définir des règles.
Exemple : 
- Si le taux de CPU moyen sur 5 minutes est supérieur à 80%, alors augmenter le nombre de pods, pour un maximum de 10 pods.
- Si la quantité de RAM consommée est moins de 50% pendant 2 minutes, alors réduire le nombre de pods, pour un minimum de 3 pods


### Mises à jour sans interruption de service : Rolling updates

Kubernetes permet de mettre à jour les pods (changement de la version de l'image utilisée par exemple) sans interruption de service. Pour cela, Kubernetes met à jour les pods en s'assurant qu'au moins un pod est disponible à tout moment.

- Dans un terminal dédié, lancer la commande suivante pour voir les pods et les images qu'ils utilisent : 
	```console
	watch kubectl get pods -o custom-columns=CONTAINER:.spec.containers[0].name,IMAGE:.spec.containers[0].image,STATUS:status.phase
	```

- Dans un autre terminal, [modifier l'image utilisée](https://kubernetes.io/fr/docs/concepts/workloads/controllers/deployment/#mise-%C3%A0-jour-d-un-d%C3%A9ploiement) (passer à "latest" dans le déploiement et appliquer la modification.)
	```console
	kubectl edit deployment nginx-deployment
	```

- Dans le premier terminal, on voit qu'un nouveau pod est créé puis, quand il est "runnning", un ancien pod est arrêté. Kubernetes fait la même chose pour les autres pods du déploiement. Le service n'est donc jamais interrompu.


### Exposition d'un port de l'application : création d'un service

On souhaite que notre serveur web soit maintenant accessible par un autre pod. Pour cela, il faut créer un service qui permettra de contacter le port 80. 

On fait l'opération via une ligne de commande, mais on pourrait aussi le faire via un fichier YAML . On crée un service ciblant le déploiement ```nginx-deployment``` et permettant d'accéder au port 80 de ses pods.
```console
kubectl expose deployment nginx-deployment --target-port=80
```

On lance un autre pod en utilisant une image [busybox](https://hub.docker.com/_/busybox) et on exécute un shell dedans : 
```console
 kubectl run -i --tty busybox --image=busybox --restart=Never -- sh
 ```
 
Kubernetes fournit un [service DNS interne](https://kubernetes.io/fr/docs/concepts/services-networking/dns-pod-service/) permettant d'accéder à différents types d'objets via leur nom. On va se servir de cela pour accéder au service : 
```console
 wget http://nginx-deployment.default.svc.cluster.local
 
Connecting to nginx-deployment.default.svc.cluster.local (10.152.183.242:80)
saving to 'index.html'
index.html           100% |******************************************************|   612  0:00:00 ETA
'index.html' saved
/ #
/ # cat index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
/ #
```
On a bien réussi à accéder au serveur nginx depuis le 2e pod, cela montre que le service est bien fonctionnel.



### Nettoyage

La démonstration est terminée, on n'oublie pas de netteoyer son environnement. Pour cela on va afficher tous les objets que l'on a créé : 

```console
kubectl get all
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-85996f8dbd-v4wrb   1/1     Running   0          27m
pod/nginx-deployment-85996f8dbd-l2lhp   1/1     Running   0          27m
pod/busybox                             1/1     Running   0          2m11s

NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/kubernetes         ClusterIP   10.152.183.1     <none>        443/TCP   39d
service/nginx-deployment   ClusterIP   10.152.183.242   <none>        80/TCP    10d

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   2/2     2            2           27m

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-85996f8dbd   2         2         2       27m
```

On voit qu'on a :
- 2 pods nginx créés par le déploiement
- 1 pod busybox créé par ligne de commande
- 1 service 'kubernets' qui existait avant la démonstration et que l'on ne va pas toucher
- 1 service 'nginx-deployement' créé en appliquant le fichier ```deployment.yaml```
- 1 replicaset, dont on n' a pas parlé durant la démonstration, mais qui est lié au déploiement


On commence par supprimer le déploiement. Pour cela, on va demander à Kubernetes de supprimer les objets qui sont décrits dans le fichier ```deployment.yaml``` : 

```console
kubectl delete -f deployment.yaml
deployment.apps "nginx-deployment" deleted
```

On regarde ce qui reste :
```console
kubectl get all
NAME          READY   STATUS    RESTARTS   AGE
pod/busybox   1/1     Running   0          6m59s

NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/kubernetes         ClusterIP   10.152.183.1     <none>        443/TCP   39d
service/nginx-deployment   ClusterIP   10.152.183.242   <none>        80/TCP    10d
```

On voit que tout ce qui était lié au déploiement a bien été supprimé.

On supprime manuellement les autres objets : 
```console
kubectl delete svc nginx-deployment
service "nginx-deployment" deleted

kubectl delete pod busybox
pod "busybox" deleted
```

On vérifie qu'il ne reste  que le service 'kubernetes'
```console
kubectl get all
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   39d
```