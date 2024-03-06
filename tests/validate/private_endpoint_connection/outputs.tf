output "private_endpoint_request_response" {
  description = "A map of private endpoint names to request response."
  value       = local.private_endpoint_request_response
}

output "private_endpoint_status" {
  description = "A map of private endpoint names to connection status."
  value       = local.private_endpoint_status
}
