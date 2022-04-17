output "rg_name" {
  value       = azurerm_resource_group.main_rg.name
  description = "Resource group name"
}

output "rg_id" {
  value       = azurerm_resource_group.main_rg.id
  description = "Resource group generated id"
}

output "rg_location" {
  value       = azurerm_resource_group.main_rg.location
  description = "Resource group location (region)"
}

output "rg_tags" {
  value       = azurerm_resource_group.main_rg.tags
  description = "The tags of the resource group"
}

output "rg_lock_id" {
  value       = azurerm_management_lock.resource_group_level_lock.id
  description = "The id of the resource group lock"
}

output "rg_lock_level" {
  value       = azurerm_management_lock.resource_group_level_lock.lock_level
  description = "The lock-level of the resource group lock"
}

