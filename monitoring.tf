resource "azurerm_monitor_diagnostic_setting" "private_endpoint_network_interface" {
  for_each = local.network_interface_ids

  name                       = each.key
  target_resource_id         = each.value
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
