output "apim_gateway_url" {
  value = "https://${azurerm_api_management.apim.name}.azure-api.net"
}

output "stock_service_api_url" {
  value = "https://${azurerm_api_management.apim.name}.azure-api.net/${azurerm_api_management_api.stock_service_v1.path}/${azurerm_api_management_api.stock_service_v1.version}"
}

output "developer_portal_url" {
  value = "https://${azurerm_api_management.apim.name}.developer.azure-api.net"
}

output "management_url" {
  value = "https://${azurerm_api_management.apim.name}.management.azure-api.net"
}
