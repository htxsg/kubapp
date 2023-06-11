# Introduction
A full example environment build on terraform supporting app running on AKS and ACR.

1. Create a based resource group and keyvault within a subscription
2. Create ACR registry
3. Create AKS Cluster
4. Push docker image to ACR
5. Attach container AKS Cluster
6. Auto deploy updates


| Files | Description |
|------|-------------|
| terraform_aks\akv_main.tf | Create a based resource group and keyvault within a subscription.|
| terraform_aks\acr_main.tf | Add on a container registry.|
| terraform_aks\aks_main.tf | Add on AKS cluster and link it to the ACR registry.|


# Running the Projects

## Create Environment with Terraform

1. The complete terraform files for this project is in the directory `terraform_aks`:
```
$ cd terraform_aks
```

3. Note that the project name is used to generally globally unique name such as AKV and ACR. Edit the project name variable in `teraaform.tfvars`:
```
$ vi teraaform.tfvars
project = "kubappaks"
environment = "dev"
```
4. Login to Azure:
```
$ az login
```
*Note: You may need to login to the specific tenant `az login --tenant xxx` that has your azure subscription.*

5. Execute the following commands to create the resources:
```
$ terraform init
$ terraform plan
$ terraform apply
```

6. Check the output after terraform apply:
```
$ terraform output
acr_admin_password = <sensitive>
aks_cluster_name = "kubappaksdevaks"
client_certificate = <sensitive>
keyvault_name = "kubappaksdevakv"
keyvault_uri = "https://kubappaksdevakv.vault.azure.net/"
kube_config = <sensitive>
resource_group_id = "/subscriptions/xxxxxxxx-b90b-4a32-8386-xxxxxxxxxxxx/resourceGroups/engaging-tick-rg"
resource_group_name = "engaging-tick-rg"
subscription_id = "xxxxxxxx-b90b-4a32-8386-xxxxxxxxxxxx"
tenant_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```



## Check AKS is running
1. We will use kubectl commandline tool to interact with the AKS cluster. First, we need to get the aks crendentials and save it in the .kube/config file:
```
$ az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw aks_cluster_name)
```

2. This will be done automatically, howeever, if you are interested you can view the `~/.kube/config` file. It will contain entry that looks like the following:
```
- name: clusterUser_engaging-tick-rg_kubappaksdevaks
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZIVENDQXdXZ0F3SUJBZ0lRVnJjUVgyWUwzZktvS0tSVkQ1R3lpVEFOQmdrcWhraUc5dzBCQVFzRkFEQU4KTVFzd0NRWURWUVFERXdKallUQWVGdzB5TWpBMk1USXdOelV4TVRoYUZ
    token: e6980eba26e473281b900a
```

3. Check that the AKS cluster is running by listing the namespaces:
```
$ $ kubectl get ns
NAME                STATUS   AGE
default             Active   32m
gatekeeper-system   Active   21m
kube-node-lease     Active   32m
kube-public         Active   32m
kube-system         Active   32m
```

## Example 1: Deploy Service with NGINX Ingress Controller

1. Install ngnix ingress controller using helm
```
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace kubappaks-dev --create-namespace
```

2. Check pods running:
```
$ kubectl get pods --namespace kubappaks-dev
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-z2qkh        0/1     Completed   0          5m35s
ingress-nginx-admission-patch-tzp42         0/1     Completed   0          5m34s
ingress-nginx-controller-7b768967bc-2s85b   1/1     Running     0          5m35s
```

3. Check service is running:
```
$ kubectl get service ingress-nginx-controller --namespace kubappaks-dev
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx-controller   LoadBalancer   10.0.223.49   20.99.142.175   80:32426/TCP,443:31701/TCP   85s
```

### Add Hello World Services
4. Adding 2 hello world services into the cluster.

5. Create and run hello world service in namespace:
```
kubectl apply -f ../aks-hello-world.yml --namespace kubappaks-dev
```

6. Check if service added:
```
$ kubectl get service --namespace kubappaks-dev
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                      AGE
aks-helloworld-one                   ClusterIP      10.0.154.230   <none>          3001/TCP                     43s
aks-helloworld-two                   ClusterIP      10.0.180.177   <none>          3002/TCP                     42s
ingress-nginx-controller             LoadBalancer   10.0.223.49    20.99.142.175   80:32426/TCP,443:31701/TCP   2m57s
ingress-nginx-controller-admission   ClusterIP      10.0.163.166   <none>          443/TCP                      2m57s
```

7. Add ingress route for services:
```
kubectl  apply -f ../ingress-route.yml --namespace kubappaks-dev
```

8. Use your browser to acess the public IP of the ingress controller e.g. 20.99.142.175, you should see the hello world pages at `/`, `/hello-world-one` and `/hello-world-one`
   

## Example 2: Deploy Frontend and Backend Services
1. This is an example of 1 frontend service and 1 backsend service.

### Host images in ACR

2. We will e using a multi container example based off [Microsoft Tutorial](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app). Pull the 2 images from public repository:
```
$ docker pull mcr.microsoft.com/oss/bitnami/redis:6.0.8
$ docker pull mcr.microsoft.com/azuredocs/azure-vote-front:v1
```

3. Tag the images with the project ACR name. In this case `kubappaksdevacr.azurecr.io`:
```
$ docker tag mcr.microsoft.com/oss/bitnami/redis:6.0.8 kubappaksdevacr.azurecr.io/example/redis
$ docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 kubappaksdevacr.azurecr.io/example/vote
```

4. Login to Azure ACR and push container to repository:
```
$ az acr login --name kubappaksdevacr.azurecr.io
$ docker push kubappaksdevacr.azurecr.io/example/redis
$ docker push kubappaksdevacr.azurecr.io/example/vote
```

5. List repository to confirm if image is pushed:
```
$ az acr repository list -n kubappaksdevacr
[
  "example/redis",
  "example/vote"
]
```

### Deploy Application to Cluster

6. Check that the AKS cluster is running by getting the nodes status:
```
$ kubectl get nodes
NAME                              STATUS   ROLES   AGE   VERSION
aks-default-30452755-vmss000000   Ready    agent   24m   v1.22.6
aks-default-30452755-vmss000001   Ready    agent   24m   v1.22.6
```

7. The configuration of the service is described in `azure-vote-all-in-one-redis.yaml'. Edit lines 19 and 60 to replace with the correct image name based on the ACR we created:
```
        image: kubappaksdevacr.azurecr.io/example/redis
        image: kubappaksdevacr.azurecr.io/example/vote  
```

8. Create a namespace `vote` and deploy services to AKS cluster:
```
$ kubectl create namespace vote
$ kubectl apply -f azure-vote-all-in-one-redis.yaml -n=vote
```

9. Check if services are running:
```
$ kubectl get service -n=vote
NAME               TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
azure-vote-back    ClusterIP      10.0.169.94   <none>         6379/TCP       3m34s
azure-vote-front   LoadBalancer   10.0.7.186    20.252.24.75   80:31166/TCP   3m33s
```

10. Go to public IP to verify that app is acessible from internet. In our example http://20.190.16.45.


## Clean Up

To Remove infrastructure. In the folder that you ran `terraform` earlier:
```
$ terraform destroy

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

```

# More Information

## akv_main.tf
This project does the following:
- Create a resource group
- Create an azure key vault
- Get tenant and subscription information using [Client Config Datasource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)


## Resources
- [Tutorial: Prepare an application for AKS](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app)
- [Terraform azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Terraform azurerm_container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)
- [Azure Container Registry](https://docs.microsoft.com/en-sg/azure/container-registry/)
- [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-sg/azure/aks/)
- [mtls betwwen AGW and AKS](https://techcommunity.microsoft.com/t5/azure-paas-blog/mtls-between-aks-and-api-management/ba-p/1813887)


# SPIKE
- Integrate AGW with Nginx Ingress Controller
- Add public IP and CDN
- Auto-rotate certificates
  