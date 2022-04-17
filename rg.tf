resource "azurerm_resource_group" "main_rg" {
  name     = var.rg_name
  location = var.location

  tags = var.tags
}

resource "azurerm_management_lock" "rg_lock" {
  name       = "lock-${var.rg_name}"
  scope      = azurerm_resource_group.main_rg.id
  lock_level = var.lock_level
  notes      = "Resource Group '${var.rg_name}' is locked with '${var.lock_level}' level."

  count = var.lock_level == "" ? 0 : 1
}