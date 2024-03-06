variable "private_endpoint_names" {
  description = "A list of private endpoint names to validate."
  type        = list(string)
}

variable "resource_group_name" {
  description = "The resource group in which the private endpoints are located."
  type        = string
}
