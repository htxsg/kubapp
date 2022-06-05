# Introduction
A full example environment build on terraform supporting app running on AKS and ACR.

1. Create a based resource group and keyvault within a subscription
2. Create AKS Cluster
3. Create ACR registry
4. Push docker image to ACR
5. Attach container AKS CLuster
6. Auto deploy updates

Link the tasks together with Ansible.

| Directory | Description |
|------|-------------|
| terraform_akv | Create a based resource group and keyvault within a subscription.|
 


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
  