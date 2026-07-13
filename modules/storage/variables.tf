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
  type = string
}

variable "confident_azure_region" {
  type = string
}

# --- Networking (existing VNet) ---
variable "confident_virtual_network_id" {
  description = "VNet ID to link the PostgreSQL private DNS zone to."
  type        = string
}

variable "confident_database_subnet_id" {
  description = "Subnet delegated to Microsoft.DBforPostgreSQL/flexibleServers."
  type        = string
}

# --- PostgreSQL (Flexible Server) ---
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

variable "confident_psql_backup_retention_days" {
  type    = number
  default = 7
}

variable "confident_psql_high_availability" {
  type    = bool
  default = true
}

# --- Object storage (Blob) ---
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

# --- Optional secret store (Key Vault) ---
variable "confident_create_key_vault" {
  description = "Create an EMPTY Key Vault + a managed identity with read access, for the External Secrets Operator. No secret values are written."
  type        = bool
  default     = false
}

variable "confident_keyvault_name" {
  type    = string
  default = "cai"
}

# --- Optional Azure Managed Redis — alternative to the bundled StatefulSet ---
variable "confident_managed_redis_enabled" {
  description = "Provision Azure Managed Redis (private endpoint) and output redis_url (set the chart's redis.internal=false, redis.externalUrl)."
  type        = bool
  default     = false
}

variable "confident_redis_sku_name" {
  description = "Azure Managed Redis SKU, e.g. Balanced_B0, MemoryOptimized_M10, ComputeOptimized_X10."
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
