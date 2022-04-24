# Example Usage

```hcl
module "rg" {
  source = "../terraform-azurerm-rg"

  rg_name    = "example-rg"
  lock_level = "CanNotDelete"
  tags       = local.tags
}
```

For a full example build, check out the [Libre DevOps Website](https://www.libredevops.org/quickstart/utils/terraform/using-lbdo-tf-modules-example.html)

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.rg_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_resource_group.main_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | Specifies the Level to be used for this RG Lock. Possible values are Empty (no lock), CanNotDelete and ReadOnly. | `string` | `""` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to associate with your network and subnets. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rg_id"></a> [rg\_id](#output\_rg\_id) | Resource group generated id |
| <a name="output_rg_location"></a> [rg\_location](#output\_rg\_location) | Resource group location (region) |
| <a name="output_rg_lock_id"></a> [rg\_lock\_id](#output\_rg\_lock\_id) | The id of the resource group lock |
| <a name="output_rg_lock_level"></a> [rg\_lock\_level](#output\_rg\_lock\_level) | The lock-level of the resource group lock |
| <a name="output_rg_name"></a> [rg\_name](#output\_rg\_name) | Resource group name |
| <a name="output_rg_tags"></a> [rg\_tags](#output\_rg\_tags) | The tags of the resource group |
