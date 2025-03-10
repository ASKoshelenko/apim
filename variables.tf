variable "subscription_id" {
  type        = string
  description = "ID подписки Azure"
}

variable "resource_group_name" {
  type        = string
  description = "Название ресурсной группы для размещения API Management"
  default     = "rg-apim-stocks"
}

variable "location" {
  type        = string
  description = "Регион Azure для размещения ресурсов"
  default     = "West Europe"
}

variable "apim_name" {
  type        = string
  description = "Название экземпляра API Management"
  default     = "apim-stock-service"
}

variable "publisher_name" {
  type        = string
  description = "Имя издателя API"
  default     = "YourCompany"
}

variable "publisher_email" {
  type        = string
  description = "Email издателя API"
  default     = "admin@yourcompany.com"
}

variable "sku_name" {
  type        = string
  description = "SKU (ценовая категория) API Management"
  default     = "Developer_1"
}

variable "environment_tag" {
  type        = string
  description = "Тег окружения для ресурсов"
  default     = "development"
}

variable "app_tag" {
  type        = string
  description = "Тег приложения для ресурсов"
  default     = "stock-service"
}

variable "api_display_name" {
  type        = string
  description = "Отображаемое имя API"
  default     = "Stock Service"
}

variable "api_path" {
  type        = string
  description = "Базовый путь для API"
  default     = "stock"
}

variable "api_version" {
  type        = string
  description = "Версия API"
  default     = "v1"
}

variable "backend_url" {
  type        = string
  description = "URL бэкенд-сервиса для API"
  default     = "https://your-backend-service.azurewebsites.net"
}

variable "product_display_name" {
  type        = string
  description = "Отображаемое имя продукта API Management"
  default     = "Stock Service Product"
}

variable "product_id" {
  type        = string
  description = "ID продукта API Management"
  default     = "stock-service"
}

variable "product_description" {
  type        = string
  description = "Описание продукта API Management"
  default     = "Product for Stock Service APIs"
}

variable "rate_limit_calls" {
  type        = number
  description = "Количество разрешенных вызовов API в заданный промежуток времени"
  default     = 5
}

variable "rate_limit_renewal_period" {
  type        = number
  description = "Период обновления для ограничения скорости вызовов API (в секундах)"
  default     = 60
}
