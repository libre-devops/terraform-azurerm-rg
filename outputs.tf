output "ids" {
  description = "Map of resource group name to its id."
  value       = { for k, v in azurerm_resource_group.this : k => v.id }
}

output "locations" {
  description = "Map of resource group name to its location."
  value       = { for k, v in azurerm_resource_group.this : k => v.location }
}

output "lock_ids" {
  description = "Map of resource group name to its management lock id (only groups that set a lock_level)."
  value       = { for k, v in azurerm_management_lock.this : k => v.id }
}

output "names" {
  description = "Map of resource group name to its name."
  value       = { for k, v in azurerm_resource_group.this : k => v.name }
}

output "resource_groups" {
  description = "The full azurerm_resource_group resources, keyed by name."
  value       = azurerm_resource_group.this
}
