# Resource groups from a list(object), keyed into a map for a stable for_each. Standard: resources in
# main.tf only, "this" as the label, for_each over a map.
#
# Management locks are deliberately NOT created here. A ReadOnly lock blocks all writes, and a lock
# resource in this module could only depend_on the resource group, so it would be a sibling of any
# resources a caller deploys into the group and would race them. Locking is therefore operational
# (the terraform-azure action's lock-dance, or the `just azure-rg-lock` recipe), applied after the
# resources exist and removed before any change. This module just declares the level (lock_levels
# output) for that tooling.
locals {
  resource_group_map = { for rg in var.resource_groups : rg.name => rg }
}

resource "azurerm_resource_group" "this" {
  for_each = local.resource_group_map

  name       = each.value.name
  location   = each.value.location
  tags       = each.value.tags
  managed_by = each.value.managed_by

  timeouts {
    create = each.value.timeouts.create
    read   = each.value.timeouts.read
    update = each.value.timeouts.update
    delete = each.value.timeouts.delete
  }
}
