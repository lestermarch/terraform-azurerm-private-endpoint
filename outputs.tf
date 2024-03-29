output "endpoints" {
  description = <<-EOT
  A map of private endpoints to private dns zone records, in the format:
  ```
  {
    stexample_blob = {
      privatelink.blob.core.windows.net = {
        stexample = {
          blob = {
            fqdn         = "pe-stexample.privatelink.blob.core.windows.net"
            ip_addresses = ["10.0.0.5"]
          }
        }
      }
    stexample_dfs = {
      privatelink.dfs.core.windows.net = {
        stexample = {
          dfs = {
            fqdn         = "pe-stexample.privatelink.dfs.core.windows.net"
            ip_addresses = ["10.0.0.6"]
          }
        }
      }
    }
  }
  ```
  EOT
  value = {
    for endpoint in azurerm_private_endpoint.main :
    endpoint.name => {
      for zone in endpoint.private_dns_zone_configs :
      zone.name => {
        for record in zone.record_sets :
        record.name => {
          fqdn       = record.fqdn
          ip_address = one(record.ip_addresses)
        }
      }
    }
  }
}
