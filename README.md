# Confident AI on Azure: Terraform

Terraform module that stands up the cloud infrastructure for a self-hosted [Confident AI](https://confident-ai.com) deployment on Azure, ready for the `confident-ai` Helm chart. It creates an AKS cluster, a PostgreSQL Flexible Server, a Storage account, and (optionally) an Azure Function code executor. On Azure the app reaches Blob storage with a **connection string** (no OIDC).

> Registry: `confident-ai/confident-ai/azurerm` · deploys into an **existing resource group + VNet** (it never creates them).

## Architecture

![Confident AI on Azure](https://raw.githubusercontent.com/confident-ai/terraform-azurerm-confident-ai/main/public/architecture.png)

Into a resource group and VNet you already have, this module provisions:

- **AKS**: a private cluster with a worker node pool (OIDC issuer + Workload Identity enabled).
- **Azure Database for PostgreSQL Flexible Server**: VNet-integrated (private), the app's primary database.
- **Azure Storage**: a Storage account with two Blob containers (test cases + payloads).
- **App identity**: Blob access via the storage **connection string** (a sensitive output), not workload identity.
- **Code executor** _(optional, on by default)_: an Azure Function (container image from ACR) for code-based metrics.
- **Key Vault** _(optional)_: a vault + a managed identity for the External Secrets Operator.
- **Azure Managed Redis** _(optional)_: managed Redis (behind a private endpoint) instead of the in-cluster one.

ClickHouse and Redis run inside the cluster by default (the Helm chart installs them). Cluster add-ons (ingress controller, cert-manager, External Secrets Operator) are environment choices and are **not** installed here, the module builds infrastructure only; the Helm chart deploys the application.

## Prerequisites

- `terraform` ≥ 1.5, the `az` CLI, `kubectl`, and `helm` ≥ 3.8.
- `az login`, plus the subscription set for the provider: `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`.
- An **existing resource group and VNet** with a subnet for AKS and a **separate subnet delegated** to `Microsoft.DBforPostgreSQL/flexibleServers`. Need to create them? See [the self-hosting guide](https://www.confident-ai.com/docs/self-hosting/azure).

## Usage

```hcl
provider "azurerm" {
  features {}
}

module "confident_ai" {
  source  = "confident-ai/confident-ai/azurerm"
  version = "~> 0.1"

  confident_resource_group_name = "confident-prod-rg"
  confident_azure_region        = "centralus"

  # your existing network
  confident_virtual_network_id = "/subscriptions/.../virtualNetworks/confident-prod-vnet"
  confident_aks_subnet_id      = "/subscriptions/.../subnets/aks"
  confident_database_subnet_id = "/subscriptions/.../subnets/postgres" # delegated to flexibleServers

  # prod naming convention
  confident_environment      = "prod"
  confident_environment_code = "p"

  confident_public_aks = true   # reach the API from your machine (false = private-only)
}
```

```bash
terraform init
terraform apply
eval "$(terraform output -raw configure_kubectl)"   # point kubectl at the new cluster
```

For a complete minimal config see [`examples/quickstart.tf`](./examples/quickstart.tf); for an end-to-end walkthrough that also creates the network and installs the chart, see [the self-hosting guide](https://www.confident-ai.com/docs/self-hosting/azure).

## Deploying the application

This module is infrastructure only. Install the app with the `confident-ai` Helm chart, wiring these outputs into its values:

| Terraform output                              | Helm value                                               |
| --------------------------------------------- | -------------------------------------------------------- |
| `database_url` (sensitive)                    | `secrets.data.DATABASE_URL`                              |
| `storage_connection_string` (sensitive)       | `secrets.data.AZURE_STORAGE_CONNECTION_STRING`           |
| `storage_account_name`                        | `storage.azure.storageAccountName`                       |
| `test_cases_container` / `payloads_container` | `storage.testCasesBucket` / `storage.payloadsBucket`     |
| `code_executor_function_url`                  | `codeExecutor.azure.functionUrl` (append `/api/execute`) |
| `key_vault_uri`                               | `secrets.externalSecrets.azure.vaultUrl`                 |
| `redis_url` (sensitive)                       | `redis.externalUrl`                                      |

Set `config.isAzureEnvironment: true` in the chart. `terraform output helm_values` prints a ready-to-paste values snippet. Full walkthrough (secrets, ingress, managed Redis, code executor): [the self-hosting guide](https://www.confident-ai.com/docs/self-hosting/azure).

## Inputs

**Required**

| Name                            | Description                                                               |
| ------------------------------- | ------------------------------------------------------------------------- |
| `confident_resource_group_name` | Existing resource group.                                                  |
| `confident_virtual_network_id`  | Existing VNet id (for the PostgreSQL private DNS link).                   |
| `confident_aks_subnet_id`       | Existing subnet for AKS nodes.                                            |
| `confident_database_subnet_id`  | Existing subnet delegated to `Microsoft.DBforPostgreSQL/flexibleServers`. |

**Commonly set** (all optional, with sensible prod defaults)

| Name                                                                             | Default                 | Description                                                                    |
| -------------------------------------------------------------------------------- | ----------------------- | ------------------------------------------------------------------------------ |
| `confident_azure_region`                                                         | `centralus`             | Region for the cluster + data plane.                                           |
| `confident_environment` / `confident_environment_code`                           | `stage` / `s`           | Environment name used in resource naming (use `prod` / `p`).                   |
| `confident_public_aks`                                                           | `false`                 | Expose the AKS public endpoint (needed for kubectl/helm from your laptop).     |
| `confident_node_vm_size` / `confident_node_group_desired_size`                   | `Standard_D8s_v5` / `4` | Node pool sizing.                                                              |
| `confident_code_executor_enabled` / `confident_acr_login_server`                 | `true` / `""`           | Code-executor Function (ACR login server required when enabled).               |
| `confident_create_key_vault`                                                     | `false`                 | Key Vault + managed identity for ESO.                                          |
| `confident_managed_redis_enabled` / `confident_redis_private_endpoint_subnet_id` | `false` / `""`          | Provision Azure Managed Redis (private-endpoint subnet required when enabled). |

See [`variables.tf`](./variables.tf) for the complete list (naming, PostgreSQL sizing, storage replication, tags, …).

## Outputs

| Name                                                                          | Description                                                    |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `configure_kubectl`                                                           | `az aks get-credentials …` command.                            |
| `cluster_name`                                                                | AKS cluster name.                                              |
| `database_url` _(sensitive)_                                                  | PostgreSQL connection string for the Helm chart.               |
| `storage_account_name`                                                        | Storage account name.                                          |
| `storage_connection_string` _(sensitive)_                                     | Blob connection string for the Helm chart.                     |
| `test_cases_container` / `payloads_container` / `clickhouse_backup_container` | Blob container names.                                          |
| `code_executor_function_url`                                                  | Function base URL (append `/api/execute`; null when disabled). |
| `key_vault_uri`                                                               | Key Vault URI (null unless enabled).                           |
| `redis_url` _(sensitive)_                                                     | Managed Redis URL (null unless enabled).                       |
| `helm_values`                                                                 | Ready-to-paste Helm values snippet.                            |

## Notes

- **Connection-string auth for Blob (no OIDC)**: the app uses `AZURE_STORAGE_CONNECTION_STRING`. AKS still has Workload Identity enabled as an optional capability (e.g. for ESO + Key Vault).
- **PostgreSQL Flexible Server** is private via the delegated subnet + a private DNS zone the module creates and links to your VNet.
- **Code executor** is an Azure Function running your container image from ACR; set `confident_code_executor_enabled = false` to skip it.
- **Key Vault**, when enabled, creates the vault + a managed identity with _Key Vault Secrets User_, but not the federated credential, see [the self-hosting guide](https://www.confident-ai.com/docs/self-hosting/azure) for the one extra `az` step to finish the Workload-Identity link.
- **Azure Managed Redis** uses the newer Redis-Enterprise-based service (SKUs like `Balanced_B0`) behind a private endpoint, and outputs `redis_url` as `rediss://…:10000` (TLS + key).
- The database password is generated and exposed only through the sensitive `database_url` output.
