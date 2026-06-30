locals {
  location = lookup(var.regions, var.loc, "uksouth")
}

# Tags first, then the resource group that consumes them, advertising both modules together. The
# tags module is referenced from the registry; the rg module is this repo.
module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
}

# Minimal call: one resource group, no lock. The environment comes from the Terraform workspace.
module "rg" {
  source = "../../"

  resource_groups = [
    {
      name     = "rg-${var.short}-${var.loc}-${terraform.workspace}-001"
      location = local.location
      tags     = module.tags.tags
    },
  ]
}
