# Introduction
A full example environment build on terraform supporting app running on AKS and ACR.

1. Create AKS Cluster
2. Create ACR registry
3. Push docker image to ACR
4. Auto deploy to AKS CLuster

Link the tasks together with Ansible

# Terraform ACR

| File | Description |
|------|-------------|
| main.tf |             |
| variable.tf|             |
| terraform.tfvars|             |
| outputs.tf|             |

```
$ terraform init
$ terrform plan
$ az login
$ terraform apply
```

# Terraform AKS Cluster
- reference network
  