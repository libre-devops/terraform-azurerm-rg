variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "lock_level" {
  description = "Specifies the Level to be used for this RG Lock. Possible values are Empty (no lock), CanNotDelete and ReadOnly."
  type        = string
  default     = ""
  validation {
    condition     = var.lock_level == "" || var.lock_level == "CanNotDelete" || var.lock_level == "ReadOnly"
    error_message = "The name of the log is not valid."
  }
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
  validation {
    condition     = length(var.rg_name) > 1 && length(var.rg_name) <= 24
    error_message = "Resource group name is not valid."
  }
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
}
