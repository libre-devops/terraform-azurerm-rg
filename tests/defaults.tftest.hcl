# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_groups = [
    {
      name     = "rg-ldo-uks-tst-rg"
      location = "uksouth"
    },
  ]
}

run "creates_the_resource_group" {
  command = plan

  assert {
    condition     = azurerm_resource_group.this["rg-ldo-uks-tst-rg"].location == "uksouth"
    error_message = "The resource group should be created in the requested location."
  }

  assert {
    condition     = length(azurerm_resource_group.this) == length(var.resource_groups)
    error_message = "One resource group should be created per list entry."
  }
}

run "no_lock_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_management_lock.this) == 0
    error_message = "No management lock should be created when lock_level is not set."
  }
}

run "creates_a_lock_when_requested" {
  command = plan

  variables {
    resource_groups = [
      {
        name       = "rg-ldo-uks-tst-locked"
        location   = "uksouth"
        lock_level = "CanNotDelete"
      },
      {
        name     = "rg-ldo-uks-tst-open"
        location = "uksouth"
      },
    ]
  }

  assert {
    condition     = length(azurerm_management_lock.this) == 1
    error_message = "Exactly one lock should be created (only the group that set a lock_level)."
  }

  assert {
    condition     = azurerm_management_lock.this["rg-ldo-uks-tst-locked"].lock_level == "CanNotDelete"
    error_message = "The lock should use the requested lock_level."
  }

  assert {
    condition     = azurerm_management_lock.this["rg-ldo-uks-tst-locked"].name == "lock-rg-ldo-uks-tst-locked"
    error_message = "The lock name should be lock-<rg name>."
  }
}

run "rejects_an_invalid_lock_level" {
  command = plan

  variables {
    resource_groups = [
      {
        name       = "rg-ldo-uks-tst-bad"
        location   = "uksouth"
        lock_level = "Frozen"
      },
    ]
  }

  expect_failures = [var.resource_groups]
}
