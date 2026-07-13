data "azurerm_client_config" "current" {}

locals {
  name = "${var.confident_application_name}-${var.confident_environment}"

  # Cryptic org scheme, e.g. azewdposcais001.
  db_server_name = "${var.confident_region_prefix}d${var.confident_database_type}${var.confident_application_code}${var.confident_environment_code}001"

  # Storage account: 3-24 chars, lowercase alphanumeric only.
  storage_account_name = substr(lower("${var.confident_application_name}${var.confident_environment_code}sa"), 0, 24)
  key_vault_name       = substr("${var.confident_keyvault_name}${var.confident_environment_code}kv", 0, 24)

  containers = merge(
    {
      test_cases = var.confident_test_cases_container
      payloads   = var.confident_payloads_container
    },
    var.confident_clickhouse_backup_container_enabled ? {
      clickhouse_backup = var.confident_clickhouse_backup_container
    } : {},
  )
}

resource "random_password" "postgres" {
  length  = 24
  special = false
}

# ---------------------------------------------------------------------------
# PostgreSQL (Flexible Server, VNet-integrated)
# ---------------------------------------------------------------------------

resource "azurerm_private_dns_zone" "postgres" {
  name                = "${local.name}.private.postgres.database.azure.com"
  resource_group_name = var.confident_resource_group_name
  tags                = var.confident_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${local.name}-pg-link"
  resource_group_name   = var.confident_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.confident_virtual_network_id
  tags                  = var.confident_tags
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = local.db_server_name
  resource_group_name           = var.confident_resource_group_name
  location                      = var.confident_azure_region
  version                       = var.confident_psql_version
  administrator_login           = var.confident_psql_username
  administrator_password        = random_password.postgres.result
  delegated_subnet_id           = var.confident_database_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false
  sku_name                      = var.confident_psql_sku_name
  storage_mb                    = var.confident_psql_storage_mb
  backup_retention_days         = var.confident_psql_backup_retention_days
  zone                          = "1"

  dynamic "high_availability" {
    for_each = var.confident_psql_high_availability ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }

  tags = var.confident_tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.confident_psql_db_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# ---------------------------------------------------------------------------
# Object storage (Blob)
# ---------------------------------------------------------------------------

resource "azurerm_storage_account" "this" {
  name                            = local.storage_account_name
  resource_group_name             = var.confident_resource_group_name
  location                        = var.confident_azure_region
  account_tier                    = "Standard"
  account_replication_type        = var.confident_storage_replication_type
  account_kind                    = "StorageV2"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }

  tags = var.confident_tags
}

resource "azurerm_storage_container" "this" {
  for_each              = local.containers
  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

# ---------------------------------------------------------------------------
# Optional: empty Key Vault + managed identity for the External Secrets Operator
# ---------------------------------------------------------------------------

resource "azurerm_key_vault" "this" {
  count                      = var.confident_create_key_vault ? 1 : 0
  name                       = local.key_vault_name
  resource_group_name        = var.confident_resource_group_name
  location                   = var.confident_azure_region
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  tags                       = var.confident_tags
}

resource "azurerm_user_assigned_identity" "eso" {
  count               = var.confident_create_key_vault ? 1 : 0
  name                = "${local.name}-eso-identity"
  resource_group_name = var.confident_resource_group_name
  location            = var.confident_azure_region
  tags                = var.confident_tags
}

resource "azurerm_role_assignment" "eso_kv_reader" {
  count                = var.confident_create_key_vault ? 1 : 0
  scope                = azurerm_key_vault.this[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.eso[0].principal_id
}

# ---------------------------------------------------------------------------
# Optional Azure Managed Redis (private endpoint, access-key auth)
# ---------------------------------------------------------------------------

resource "azurerm_managed_redis" "this" {
  count                     = var.confident_managed_redis_enabled ? 1 : 0
  name                      = "${local.name}-redis"
  resource_group_name       = var.confident_resource_group_name
  location                  = var.confident_azure_region
  sku_name                  = var.confident_redis_sku_name
  high_availability_enabled = var.confident_redis_high_availability
  public_network_access     = "Disabled"

  default_database {
    # Access-key auth so the app can use a connection-string REDIS_URL (no Entra).
    access_keys_authentication_enabled = true
    client_protocol                    = "Encrypted"
  }

  tags = var.confident_tags
}

resource "azurerm_private_dns_zone" "redis" {
  count               = var.confident_managed_redis_enabled ? 1 : 0
  name                = "privatelink.redis.azure.net"
  resource_group_name = var.confident_resource_group_name
  tags                = var.confident_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count                 = var.confident_managed_redis_enabled ? 1 : 0
  name                  = "${local.name}-redis-link"
  resource_group_name   = var.confident_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = var.confident_virtual_network_id
  tags                  = var.confident_tags
}

resource "azurerm_private_endpoint" "redis" {
  count               = var.confident_managed_redis_enabled ? 1 : 0
  name                = "${local.name}-redis-pe"
  resource_group_name = var.confident_resource_group_name
  location            = var.confident_azure_region
  subnet_id           = var.confident_redis_private_endpoint_subnet_id

  private_service_connection {
    name                           = "${local.name}-redis-psc"
    private_connection_resource_id = azurerm_managed_redis.this[0].id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "redis"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis[0].id]
  }

  tags = var.confident_tags
}
