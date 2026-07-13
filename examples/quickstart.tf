# Minimal Confident AI deployment on Azure.
#
# Prerequisites: an existing resource group + VNet with an AKS subnet and a
# separate subnet delegated to Microsoft.DBforPostgreSQL/flexibleServers.
# See ../DEPLOY.md to create them, or use your own. After `terraform apply`,
# install the confident-ai Helm chart using the outputs.
#
# Set the subscription first:  export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "confident_ai" {
  source  = "confident-ai/confident-ai/azurerm"
  version = "~> 0.1"
  # For local testing before publishing, use a relative path instead:
  # source = "../"

  # --- required: resource group + your existing network ---
  confident_resource_group_name = "confident-prod-rg"
  confident_azure_region        = "centralus"
  confident_virtual_network_id  = "/subscriptions/xxxx/resourceGroups/confident-prod-rg/providers/Microsoft.Network/virtualNetworks/confident-prod-vnet"
  confident_aks_subnet_id       = "/subscriptions/.../subnets/aks"
  confident_database_subnet_id  = "/subscriptions/.../subnets/postgres" # delegated to flexibleServers

  # --- prod naming convention ---
  confident_environment      = "prod"
  confident_environment_code = "p"

  # let you reach the cluster from your machine (false = private-only)
  confident_public_aks = true

  # turn on once you have the sandbox image in ACR
  confident_code_executor_enabled = false
}

output "configure_kubectl" {
  description = "Run this to point kubectl at the new cluster."
  value       = module.confident_ai.configure_kubectl
}

output "database_url" {
  description = "-> Helm secrets.data.DATABASE_URL"
  value       = module.confident_ai.database_url
  sensitive   = true
}

output "storage_connection_string" {
  description = "-> Helm secrets.data.AZURE_STORAGE_CONNECTION_STRING"
  value       = module.confident_ai.storage_connection_string
  sensitive   = true
}
