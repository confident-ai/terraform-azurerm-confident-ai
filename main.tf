locals {
  create_function = var.confident_code_executor_enabled
}


module "aks" {
  source = "./modules/aks"

  confident_application_name = var.confident_application_name
  confident_application_code = var.confident_application_code
  confident_environment      = var.confident_environment
  confident_environment_code = var.confident_environment_code
  confident_region_prefix    = var.confident_region_prefix
  confident_tags             = var.confident_tags

  confident_resource_group_name = var.confident_resource_group_name
  confident_azure_region        = var.confident_azure_region
  confident_aks_subnet_id       = var.confident_aks_subnet_id

  confident_kubernetes_version         = var.confident_kubernetes_version
  confident_public_aks                 = var.confident_public_aks
  confident_aks_admin_group_object_ids = var.confident_aks_admin_group_object_ids
  confident_node_vm_size               = var.confident_node_vm_size
  confident_node_group_min_size        = var.confident_node_group_min_size
  confident_node_group_max_size        = var.confident_node_group_max_size
  confident_node_group_desired_size    = var.confident_node_group_desired_size
}

module "function" {
  source = "./modules/function"
  count  = local.create_function ? 1 : 0

  confident_application_name = var.confident_application_name
  confident_application_code = var.confident_application_code
  confident_environment      = var.confident_environment
  confident_environment_code = var.confident_environment_code
  confident_tags             = var.confident_tags

  confident_resource_group_name = var.confident_resource_group_name
  confident_azure_region        = var.confident_azure_region

  confident_acr_login_server                  = var.confident_acr_login_server
  confident_code_executor_function_image_name = var.confident_code_executor_function_image_name
  confident_code_executor_function_image_tag  = var.confident_code_executor_function_image_tag
  confident_acr_admin_username                = var.confident_acr_admin_username
  confident_acr_admin_password                = var.confident_acr_admin_password
}

module "storage" {
  source = "./modules/storage"

  confident_application_name = var.confident_application_name
  confident_application_code = var.confident_application_code
  confident_environment      = var.confident_environment
  confident_environment_code = var.confident_environment_code
  confident_region_prefix    = var.confident_region_prefix
  confident_database_type    = var.confident_database_type
  confident_tags             = var.confident_tags

  confident_resource_group_name = var.confident_resource_group_name
  confident_azure_region        = var.confident_azure_region

  confident_virtual_network_id = var.confident_virtual_network_id
  confident_database_subnet_id = var.confident_database_subnet_id

  confident_psql_version               = var.confident_psql_version
  confident_psql_sku_name              = var.confident_psql_sku_name
  confident_psql_storage_mb            = var.confident_psql_storage_mb
  confident_psql_db_name               = var.confident_psql_db_name
  confident_psql_username              = var.confident_psql_username
  confident_psql_password              = var.confident_psql_password
  confident_psql_backup_retention_days = var.confident_psql_backup_retention_days
  confident_psql_high_availability     = var.confident_psql_high_availability

  confident_storage_replication_type            = var.confident_storage_replication_type
  confident_test_cases_container                = var.confident_test_cases_container
  confident_payloads_container                  = var.confident_payloads_container
  confident_clickhouse_backup_container_enabled = var.confident_clickhouse_backup_container_enabled
  confident_clickhouse_backup_container         = var.confident_clickhouse_backup_container

  confident_create_key_vault = var.confident_create_key_vault
  confident_keyvault_name    = var.confident_keyvault_name

  confident_managed_redis_enabled            = var.confident_managed_redis_enabled
  confident_redis_sku_name                   = var.confident_redis_sku_name
  confident_redis_high_availability          = var.confident_redis_high_availability
  confident_redis_private_endpoint_subnet_id = var.confident_redis_private_endpoint_subnet_id
}


