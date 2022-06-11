# Introduction
A full example environment build on terraform supporting app running on AKS and ACR.

1. Create a based resource group and keyvault within a subscription
2. Create ACR registry
3. Create AKS Cluster
4. Push docker image to ACR
5. Attach container AKS CLuster
6. Auto deploy updates

Link the tasks together with Ansible.

| Files | Description |
|------|-------------|
| akv_main.tf | Create a based resource group and keyvault within a subscription.|
 


## Terraform KV

This project does the following:
- Create a resource group
- Create an azure key value
- Get tenant and subscription information using [Client Config Datasource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)

### Creating the resourcess

1. Execute the following commands to create the resources:
```
$ terraform init
$ terrform plan
$ az login
$ terraform apply
```

2. Cheek the output after terraform apply:
```
$ terraform output
keyvault_name = "pyxbringodevakv"
keyvault_uri = "https://pyxbringodevakv.vault.azure.net/"
resource_group_id = "/subscriptions/xxxxxxxx-b90b-4a32-8386-xxxxxxxxxxxx/resourceGroups/wondrous-reindeer-rg"
subscription_id = "xxxxxxxx-b90b-4a32-8386-xxxxxxxxxxxx"
tenant_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

```

3. Check Azure portal for the resouces created.


## Terraform ACR

Manage Azure Active Directory service principals for automation authentication.

Generate service principal and store secret in keyvault.


[az ad sp command](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac)

[Terraform example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)

| File | Description |
|------|-------------|
| main.tf |             |
| variable.tf|             |
| terraform.tfvars|             |
| outputs.tf    |             |

```
$ terraform init
$ terrform plan
$ az login
$ terraform apply
```

# Terraform AKS Cluster
- reference network


A service principal or managed identity is needed by AKS to dynamically create and manage other Azure resources such as an Azure load balancer or container registry (ACR).

There are many ways to authenticate to the Azure provider. In this tutorial, you will use an Active Directory service principal account. You can learn how to authenticate using a different method here.

First, you need to create an Active Directory service principal account using the Azure CLI. You should see something like the following.

  ```
  $ az ad sp create-for-rbac
    {
    "appId": "4a94e2d3-4541-4103-b9da-b8fb6c5b8122",
    "displayName": "azure-cli-2022-06-11-08-58-13",
    "name": "4a94e2d3-4541-4103-b9da-b8fb6c5b8122",
    "password": "KB3muvxsXooMRq-63kJtGvnssqI0u6b~.7",
    "tenant": "b8b23322-4422-44f4-850d-cc4d30dff5b3"
    }
  ```

```
  az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw aks_cluster_name)
````


First, pull a public Nginx image to your local computer. This example pulls an image from Microsoft Container Registry.

```
docker pull mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
docker run -it --rm -p 8080:80 mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine

```
`ctrl-c`

```
$ docker tag mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine pyxbringodevacr.azurecr.io/example/nginx
$ az login
$ az acr login --name pyxbringodevacr.azurecr.io
$ docker push pyxbringodevacr.azurecr.io/example/nginx
```

docker rmi pyxbringodevacr.azurecr.io/example/nginx

https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app

 $ docker tag mcr.microsoft.com/oss/bitnami/redis:6.0.8 pyxbringodevacr.azurecr.io/example/redis
 $ docker tag mcr.microsoft.com/azuredocs/azure-vote-front:v1 pyxbringodevacr.azurecr.io/example/vote



