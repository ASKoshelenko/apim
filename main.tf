provider "azurerm" {
  features {}
  
  # Указываем ID подписки через переменную
  subscription_id = var.subscription_id
}

# 1. Создаем ресурсную группу
resource "azurerm_resource_group" "apim_rg" {
  name     = var.resource_group_name
  location = var.location
  
  tags = {
    environment = var.environment_tag
    app         = var.app_tag
  }
}

# 2. Создаем API Management сервис
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name = azurerm_resource_group.apim_rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  sku_name = var.sku_name

  security {
    enable_backend_ssl30                  = false
    enable_backend_tls10                  = false
    enable_backend_tls11                  = false
    enable_frontend_ssl30                 = false
    enable_frontend_tls10                 = false
    enable_frontend_tls11                 = false
  }

  protocols {
    enable_http2 = true
  }

  tags = {
    environment = var.environment_tag
    app         = var.app_tag
  }
}

# 3. Создаем набор версий API для Stock Service
resource "azurerm_api_management_api_version_set" "stock_service" {
  name                = "stock-service"
  resource_group_name = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = var.api_display_name
  versioning_scheme   = "Segment"
}

# 4. Создаем API Stock Service v1
resource "azurerm_api_management_api" "stock_service_v1" {
  name                = "stock-service-v1"
  resource_group_name = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = var.api_display_name
  path                = var.api_path
  protocols           = ["https"]
  
  version             = var.api_version
  version_set_id      = azurerm_api_management_api_version_set.stock_service.id

  import {
    content_format = "openapi+json"
    content_value  = file("${path.module}/stock-service-openapi.json")
  }
}

# 5. Создаем схемы JSON для операций API
resource "azurerm_api_management_api_schema" "stock_limitation_request" {
  api_name            = azurerm_api_management_api.stock_service_v1.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.apim_rg.name
  schema_id           = "stock-limitation-request"
  content_type        = "application/json"
  value               = <<JSON
{
  "type": "object",
  "properties": {
    "cartId": {
      "type": "string"
    },
    "skus": {
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  },
  "required": ["cartId", "skus"]
}
JSON
}

# 6. Создаем бэкенд для API
resource "azurerm_api_management_backend" "stock_service_backend" {
  name                = "stock-service-backend"
  resource_group_name = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  protocol            = "http"
  url                 = var.backend_url
  
  description         = "Backend for Stock Service API"
  
  tls {
    validate_certificate_chain = true
    validate_certificate_name  = true
  }
}

# 7. Создаем продукт API Management
resource "azurerm_api_management_product" "stock_product" {
  product_id            = var.product_id
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = azurerm_resource_group.apim_rg.name
  display_name          = var.product_display_name
  description           = var.product_description
  subscription_required = true
  approval_required     = false
  published             = true
}

# 8. Привязываем API к продукту
resource "azurerm_api_management_product_api" "stock_product_api" {
  api_name            = azurerm_api_management_api.stock_service_v1.name
  product_id          = azurerm_api_management_product.stock_product.product_id
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.apim_rg.name
}

# 9. Создаем политику на уровне всего API
resource "azurerm_api_management_api_policy" "stock_service_policy" {
  api_name            = azurerm_api_management_api.stock_service_v1.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.apim_rg.name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <cors>
      <allowed-origins>
        <origin>*</origin>
      </allowed-origins>
      <allowed-methods>
        <method>GET</method>
        <method>POST</method>
        <method>PATCH</method>
      </allowed-methods>
      <allowed-headers>
        <header>Content-Type</header>
        <header>Authorization</header>
      </allowed-headers>
    </cors>
    <rate-limit calls="${var.rate_limit_calls}" renewal-period="${var.rate_limit_renewal_period}" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
}

# 10. Создаем операционную политику для операции getStockLimitation
resource "azurerm_api_management_api_operation_policy" "get_stock_limitation_policy" {
  api_name            = azurerm_api_management_api.stock_service_v1.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.apim_rg.name
  operation_id        = "getStockLimitation"

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <set-backend-service id="apim-generated-policy" backend-id="${azurerm_api_management_backend.stock_service_backend.name}" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML

  depends_on = [azurerm_api_management_api.stock_service_v1]
}
