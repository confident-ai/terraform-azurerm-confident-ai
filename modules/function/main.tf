locals {
  name                 = "${var.confident_application_name}-${var.confident_environment}"
  function_name        = "${local.name}-codesandbox"
  storage_account_name = substr(lower("${var.confident_application_code}${var.confident_environment_code}sandboxsa"), 0, 24)
}

resource "azurerm_service_plan" "this" {
  name                = "${local.function_name}-plan"
  location            = var.confident_azure_region
  resource_group_name = var.confident_resource_group_name
  os_type             = "Linux"
  sku_name            = var.confident_code_executor_plan_sku
  tags                = var.confident_tags
}

resource "azurerm_storage_account" "this" {
  name                            = local.storage_account_name
  resource_group_name             = var.confident_resource_group_name
  location                        = var.confident_azure_region
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.confident_tags
}

resource "azurerm_linux_function_app" "this" {
  name                       = local.function_name
  location                   = var.confident_azure_region
  resource_group_name        = var.confident_resource_group_name
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  site_config {
    application_stack {
      docker {
        registry_url      = "https://${var.confident_acr_login_server}"
        image_name        = var.confident_code_executor_function_image_name
        image_tag         = var.confident_code_executor_function_image_tag
        registry_username = var.confident_acr_admin_username
        registry_password = var.confident_acr_admin_password
      }
    }
  }

  tags = var.confident_tags
}
