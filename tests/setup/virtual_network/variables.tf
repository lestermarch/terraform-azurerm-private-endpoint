variable "address_space" {
  description = "The CIDR range assign as the root address space for the virtual network."
  type        = string
}

variable "location" {
  description = "The primary region into which resources will be deployed."
  type        = string
}
