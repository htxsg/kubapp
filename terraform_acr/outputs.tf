#AKV Outputs
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "keyvault_name" {
  value = azurerm_key_vault.akv.name
}

output "keyvault_uri" {
  value = azurerm_key_vault.akv.vault_uri
}

#ACR Outputs
output "acr_admin_password" {
  value       = azurerm_container_registry.acr.admin_password
  description = "The object ID of the user"
  sensitive = true
}

