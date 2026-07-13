output "database_url" {
  description = "PostgreSQL connection string (Helm secrets.data.DATABASE_URL)."
  value       = "postgresql://${var.confident_psql_username}:${urlencode(random_password.postgres.result)}@${azurerm_postgresql_flexible_server.this.fqdn}:5432/${var.confident_psql_db_name}"
  sensitive   = true
}

output "storage_account_name" {
  description = "Helm storage.azure.storageAccountName."
  value       = azurerm_storage_account.this.name
}

output "storage_connection_string" {
  description = "Helm secrets.data.AZURE_STORAGE_CONNECTION_STRING (the app authenticates to Blob with this)."
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "test_cases_container" {
  value = azurerm_storage_container.this["test_cases"].name
}

output "payloads_container" {
  value = azurerm_storage_container.this["payloads"].name
}

output "clickhouse_backup_container" {
  value = try(azurerm_storage_container.this["clickhouse_backup"].name, null)
}

output "redis_url" {
  description = "Azure Managed Redis URL (Helm redis.externalUrl; set redis.internal=false). TLS + access key. Null unless enabled."
  value       = try("rediss://:${azurerm_managed_redis.this[0].default_database[0].primary_access_key}@${azurerm_managed_redis.this[0].hostname}:${azurerm_managed_redis.this[0].default_database[0].port}", null)
  sensitive   = true
}

output "key_vault_uri" {
  description = "Helm externalSecrets.azure.vaultUrl (null unless created)."
  value       = try(azurerm_key_vault.this[0].vault_uri, null)
}

output "eso_identity_client_id" {
  description = "Managed identity client-id ESO uses to read Key Vault (null unless created)."
  value       = try(azurerm_user_assigned_identity.eso[0].client_id, null)
}

output "helm_values" {
  description = "Ready-to-paste Helm values. DATABASE_URL and AZURE_STORAGE_CONNECTION_STRING come from the sensitive outputs above."
  value       = <<-EOT
    config:
      cloudProvider: AZURE
      isAzureEnvironment: true
    storage:
      testCasesBucket: ${azurerm_storage_container.this["test_cases"].name}
      payloadsBucket: ${azurerm_storage_container.this["payloads"].name}
      azure:
        storageAccountName: ${azurerm_storage_account.this.name}
    # secrets.data.AZURE_STORAGE_CONNECTION_STRING = (terraform output -raw storage_connection_string)
  EOT
}
