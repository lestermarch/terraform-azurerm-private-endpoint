variable "endpoints" {
  description = <<-EOT
  A list of objects used to configure one or more private endpoints for one or more resources, in the format:
  ```hcl
  [
    {
      resource_id  = "/subscriptions/storageAccounts/stexample"
      auto_approve = true
      subresource = {
        blob = {
          endpoint_name          = "pe-stexample-blob"
          network_interface_name = "pe-nic-stexample-blob"
          private_dns_zone_ids   = ["/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"]
        }
        dfs = {
          endpoint_name          = "pe-stexample-dfs"
          network_interface_name = "pe-nic-stexample-dfs"
          private_dns_zone_ids   = ["/subscriptions/.../privateDnsZones/privatelink.dfs.core.windows.net"]
        }
      }
    }
  ]
  ```
  Notes:
  - Setting `auto_approve` to `true` requires that the deployment prinicpal has the appropriate RBAC role assigned on the target `resource_id`.
  - Endpoint and network interface names will be automatically generated unless `endpoint_name` or `network_interface_name` are specified.
  EOT
  type = list(object({
    resource_id  = string
    auto_approve = optional(bool)
    subresource = map(object({
      endpoint_name          = optional(string)
      network_interface_name = optional(string)
      private_dns_zone_ids   = list(string)
    }))
  }))
}

variable "location" {
  description = "The primary region into which resources will be deployed."
  type        = string
}

variable "log_analytics_workspace_id" {
  default     = null
  description = "The ID of a log analytics workspace to forward network interface metrics to."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group into which resources will be deployed."
  type        = string
}

variable "resource_tags" {
  default     = {}
  description = "A map of key/value pairs to be assigned as resource tags on taggable resources."
  type        = map(string)
}

variable "subnet_id" {
  description = "The ID of the virtual network subnet in which private endpoints will be provisioned."
  type        = string
}
