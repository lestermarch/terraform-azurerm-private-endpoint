locals {
  # A map of private endpoint names to request response
  private_endpoint_request_response = {
    for endpoint in data.azurerm_private_endpoint_connection.validate :
    endpoint.name => endpoint.private_service_connection[0].request_response
  }

  # A map of private endpoint names to connection status
  private_endpoint_status = {
    for endpoint in data.azurerm_private_endpoint_connection.validate :
    endpoint.name => endpoint.private_service_connection[0].status
  }
}
