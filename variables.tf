# --- Naming ---
variable "confident_application_name" {
  type    = string
  default = "confidentai"
}

variable "confident_application_code" {
  type    = string
  default = "cai"
}

variable "confident_environment" {
  type    = string
  default = "stage"
}

variable "confident_environment_code" {
  type    = string
  default = "s"
}

variable "confident_region_prefix" {
  type    = string
  default = "azew"
}

variable "confident_database_type" {
  type    = string
  default = "pos"
}

variable "confident_tags" {
  type    = map(string)
  default = {}
}

# --- Location / RG (existing) ---
variable "confident_resource_group_name" {
  description = "Existing resource group."
  type        = string
}

variable "confident_azure_region" {
  type    = string
  default = "centralus"
}

# --- Networking (existing VNet — never created here) ---
variable "confident_virtual_network_id" {
  description = "Existing VNet ID (for the PostgreSQL private DNS link)."
  type        = string
}

variable "confident_aks_subnet_id" {
  description = "Existing subnet for AKS nodes."
  type        = string
}

variable "confident_database_subnet_id" {
  description = "Existing subnet delegated to Microsoft.DBforPostgreSQL/flexibleServers."
  type        = string
}

# --- AKS cluster (always created) ---
variable "confident_kubernetes_version" {
  type    = string
  default = "1.34.2"
}

variable "confident_public_aks" {
  type    = bool
  default = false
}

variable "confident_aks_admin_group_object_ids" {
  type    = list(string)
  default = []
}

variable "confident_node_vm_size" {
  type    = string
  default = "Standard_D8s_v5"
}

variable "confident_node_group_min_size" {
  type    = number
  default = 2
}

variable "confident_node_group_max_size" {
  type    = number
  default = 8
}

variable "confident_node_group_desired_size" {
  type    = number
  default = 4
}

# --- Data plane — PostgreSQL ---
variable "confident_psql_version" {
  type    = string
  default = "17"
}

variable "confident_psql_sku_name" {
  type    = string
  default = "GP_Standard_D4s_v3"
}

variable "confident_psql_storage_mb" {
  type    = number
  default = 65536
}

variable "confident_psql_db_name" {
  type    = string
  default = "confident_db"
}

variable "confident_psql_username" {
  type    = string
  default = "confident"
}

variable "confident_psql_password" {
  description = "PostgreSQL password. Leave empty to auto-generate a random one."
  type        = string
  default     = ""
  sensitive   = true
}

variable "confident_psql_backup_retention_days" {
  type    = number
  default = 7
}

variable "confident_psql_high_availability" {
  type    = bool
  default = true
}

# --- Data plane — object storage ---
variable "confident_storage_replication_type" {
  type    = string
  default = "ZRS"
}

variable "confident_test_cases_container" {
  type    = string
  default = "testcases"
}

variable "confident_payloads_container" {
  type    = string
  default = "payloads"
}

variable "confident_clickhouse_backup_container_enabled" {
  type    = bool
  default = false
}

variable "confident_clickhouse_backup_container" {
  type    = string
  default = "chbackups"
}

# --- Code executor (Azure Function) — created by default ---
variable "confident_code_executor_enabled" {
  type    = bool
  default = true
}

variable "confident_acr_login_server" {
  description = "ACR login server (e.g. myregistry.azurecr.io). Required when confident_code_executor_enabled=true."
  type        = string
  default     = ""
}

variable "confident_code_executor_function_image_name" {
  type    = string
  default = "confident-code-sandbox"
}

variable "confident_code_executor_function_image_tag" {
  type    = string
  default = "latest"
}

variable "confident_acr_admin_username" {
  type    = string
  default = ""
}

variable "confident_acr_admin_password" {
  type      = string
  default   = ""
  sensitive = true
}

# --- Optional secret store (Key Vault) ---
variable "confident_create_key_vault" {
  type    = bool
  default = false
}

variable "confident_keyvault_name" {
  type    = string
  default = "cai"
}

# --- Optional Azure Managed Redis ---
variable "confident_managed_redis_enabled" {
  type    = bool
  default = false
}

variable "confident_redis_sku_name" {
  description = "Azure Managed Redis SKU (e.g. Balanced_B0, MemoryOptimized_M10)."
  type        = string
  default     = "Balanced_B0"
}

variable "confident_redis_high_availability" {
  type    = bool
  default = true
}

variable "confident_redis_private_endpoint_subnet_id" {
  description = "Subnet for the Redis private endpoint. Required when confident_managed_redis_enabled=true."
  type        = string
  default     = ""
}
