<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Resource Group

Creates one or more Azure resource groups from a `list(object)`, each with optional tags and an
optional management lock.

[![CI](https://github.com/libre-devops/terraform-azurerm-rg/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-rg/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-rg?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-rg/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-rg)](./LICENSE)

---

## Overview

A `for_each` over a `list(object)` so one call can create many resource groups, each with its own
tags, optional `managed_by`, and overridable per-action `timeouts` (defaulting to the azurerm defaults:
create/update/delete 90m, read 5m).

### Management locks are operational, not a module resource

`lock_level` (`""`, `CanNotDelete`, or `ReadOnly`) is **declared intent only**, surfaced on the
`lock_levels` output. This module does **not** create an `azurerm_management_lock`, on purpose: a
`ReadOnly` lock blocks all writes, and a lock resource here could only `depends_on` the resource group,
so it would be a sibling of anything you deploy into that group and would race it. Locking is therefore
applied **operationally**, after the resources exist and removed before any change, exactly like the
storage firewall dance:

- the `libre-devops/terraform-azure` action's lock-dance (opt in with
  `remove-resource-group-locks-before-tf-run`, off by default), or
- the `just azure-rg-lock <rg> <level>` / `just azure-remove-lock <rg>` recipes for manual use.

## Usage

```hcl
module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre = "1888/67"
  owner       = "platform@example.com"
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [
    {
      name       = "rg-ldo-uks-prd-001"
      location   = "uksouth"
      tags       = module.tags.tags
      lock_level = "CanNotDelete" # declared intent; applied operationally, not by this module
    },
  ]
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - one resource group, defaults only.
- [`examples/complete`](./examples/complete) - multiple resource groups exercising tags, declared lock
  levels, `managed_by`, and overridden timeouts.

Both examples call the tags module first, then this module, so they advertise both together.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the
recipes wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| _None_   |          |         |               |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Resource groups to create. Each entry takes a name and location, with optional tags, managed\_by,<br/>per-action timeouts, and a declared lock\_level. The list is keyed into a map by name for a stable<br/>for\_each.<br/><br/>lock\_level ("", "CanNotDelete", or "ReadOnly") is declared intent only: this module does NOT create<br/>the lock. A management lock is applied operationally (the terraform-azure action's lock-dance, or<br/>the `just azure-rg-lock` recipe) so a ReadOnly lock never races resources being deployed into the<br/>group. The level is surfaced on the lock\_levels output for that tooling to consume. | <pre>list(object({<br/>    name       = string<br/>    location   = string<br/>    tags       = optional(map(string), {})<br/>    lock_level = optional(string, "")<br/>    managed_by = optional(string, null)<br/>    timeouts = optional(object({<br/>      create = optional(string, "90m")<br/>      read   = optional(string, "5m")<br/>      update = optional(string, "90m")<br/>      delete = optional(string, "90m")<br/>    }), {})<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ids"></a> [ids](#output\_ids) | Map of resource group name to its id. |
| <a name="output_locations"></a> [locations](#output\_locations) | Map of resource group name to its location. |
| <a name="output_lock_levels"></a> [lock\_levels](#output\_lock\_levels) | Declared management lock level per resource group. Intent only: applied operationally by the action lock-dance or the just azure-rg-lock recipe, not by this module. |
| <a name="output_managed_by"></a> [managed\_by](#output\_managed\_by) | Map of resource group name to its managed\_by value (null when unset). |
| <a name="output_names"></a> [names](#output\_names) | Map of resource group name to its name. |
| <a name="output_resource_group_ids_zipmap"></a> [resource\_group\_ids\_zipmap](#output\_resource\_group\_ids\_zipmap) | Map of resource group name to a { name, id } object, so the whole object can be passed where something needs the name and id together. |
| <a name="output_resource_groups"></a> [resource\_groups](#output\_resource\_groups) | The full azurerm\_resource\_group resources, keyed by name. |
| <a name="output_tags"></a> [tags](#output\_tags) | Map of resource group name to its tags. |
<!-- END_TF_DOCS -->
