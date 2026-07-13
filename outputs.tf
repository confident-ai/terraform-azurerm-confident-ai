# --- Cluster ---
output "cluster_name" {
  value = module.aks.cluster_name
}

output "configure_kubectl" {
  description = "Command to point kubectl at the cluster."
  value       = "az aks get-credentials --resource-group ${var.confident_resource_group_name} --name ${module.aks.cluster_name}"
}

# --- Data plane (wire these into the Helm chart) ---
output "database_url" {
  description = "PostgreSQL connection string (Helm secrets.data.DATABASE_URL)."
  value       = module.storage.database_url
  sensitive   = true
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "storage_connection_string" {
  description = "Helm secrets.data.AZURE_STORAGE_CONNECTION_STRING."
  value       = module.storage.storage_connection_string
  sensitive   = true
}

output "test_cases_container" {
  value = module.storage.test_cases_container
}

output "payloads_container" {
  value = module.storage.payloads_container
}

output "clickhouse_backup_container" {
  value = module.storage.clickhouse_backup_container
}

output "code_executor_function_url" {
  description = "Helm codeExecutor.azure.functionUrl base (append /api/execute). Null when disabled."
  value       = local.create_function ? module.function[0].function_url : null
}

output "key_vault_uri" {
  description = "Helm externalSecrets.azure.vaultUrl (null unless confident_create_key_vault=true)."
  value       = module.storage.key_vault_uri
}

output "redis_url" {
  description = "Managed Redis URL (Helm redis.externalUrl; null unless confident_managed_redis_enabled=true)."
  value       = module.storage.redis_url
  sensitive   = true
}

output "helm_values" {
  description = "Ready-to-paste Helm values (DATABASE_URL + AZURE_STORAGE_CONNECTION_STRING come from the sensitive outputs)."
  value       = module.storage.helm_values
}
