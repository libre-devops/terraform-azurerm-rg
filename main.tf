# Resource groups (and their optional management locks) from a list(object), keyed into a map for a
# stable for_each. Standard: resources in main.tf only, "this" as the label, for_each over a map.
locals {
  resource_group_map = { for rg in var.resource_groups : rg.name => rg }

  # Only the resource groups that asked for a lock.
  locked_resource_groups = { for k, rg in local.resource_group_map : k => rg if rg.lock_level != "" }
}

resource "azurerm_resource_group" "this" {
  for_each = local.resource_group_map

  name     = each.value.name
  location = each.value.location
  tags     = each.value.tags
}

# A management lock per resource group that requests one. depends_on every resource group so a lock
# is created after its group and, on destroy, removed before it (so `terraform destroy` works). This
# is self-contained and portable: the module needs no script. The terraform-azure action additionally
# runs a lock-dance (remove the lock for the apply, re-add it after) so an apply is never blocked, but
# that is an operational convenience, not something this module depends on.
resource "azurerm_management_lock" "this" {
  for_each = local.locked_resource_groups

  name       = "lock-${each.value.name}"
  scope      = azurerm_resource_group.this[each.key].id
  lock_level = each.value.lock_level
  notes      = "Resource group '${each.value.name}' is locked at '${each.value.lock_level}'."

  depends_on = [azurerm_resource_group.this]
}
