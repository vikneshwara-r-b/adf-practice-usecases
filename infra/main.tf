# Azure Data Engineering Infrastructure - Main Configuration

# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# ============================================================================
# Resource Group
# ============================================================================

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ============================================================================
# Azure Data Factory v2
# ============================================================================

resource "azurerm_data_factory" "main" {
  name                = "${var.adf_name}-${var.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Enable system-assigned managed identity for authentication
  identity {
    type = "SystemAssigned"
  }

  # GitHub integration for source control
  github_configuration {
    account_name       = var.adf_github_account_name
    branch_name        = var.adf_github_branch_name
    git_url            = "https://github.com"
    repository_name    = var.adf_github_repository_name
    root_folder        = var.adf_github_root_folder
    publishing_enabled = true
  }

  tags = var.tags
}

# ============================================================================
# Azure Data Lake Storage Gen2 (ADLS Gen2)
# ============================================================================

resource "azurerm_storage_account" "adls" {
  name                     = "${var.storage_account_name}${var.resource_suffix}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Enable hierarchical namespace for ADLS Gen2
  is_hns_enabled = true

  # Disable access keys, enforce managed identity access
  shared_access_key_enabled = true # Set to false if you want to enforce MI only

  tags = var.tags
}

# Source Container
resource "azurerm_storage_data_lake_gen2_filesystem" "source" {
  name               = var.source_container_name
  storage_account_id = azurerm_storage_account.adls.id

  depends_on = [azurerm_storage_account.adls]
}

# Target Container
resource "azurerm_storage_data_lake_gen2_filesystem" "target" {
  name               = var.target_container_name
  storage_account_id = azurerm_storage_account.adls.id

  depends_on = [azurerm_storage_account.adls]
}

# ============================================================================
# RBAC - Grant ADF Managed Identity Access to ADLS Gen2
# ============================================================================

# Storage Blob Data Contributor role for ADF on the storage account
# This allows read and write access to both containers
resource "azurerm_role_assignment" "adf_storage_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.main.identity[0].principal_id

  depends_on = [
    azurerm_data_factory.main,
    azurerm_storage_account.adls
  ]
}

# ============================================================================
# Azure SQL Server - Source
# ============================================================================

resource "azurerm_mssql_server" "source" {
  name                         = "${var.sql_source_server_name}-${var.resource_suffix}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_source_admin_login
  administrator_login_password = var.sql_source_admin_password

  tags = var.tags
}

# Firewall rule to allow Azure services to access the source SQL server
resource "azurerm_mssql_firewall_rule" "source_allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.source.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Source SQL Database
resource "azurerm_mssql_database" "source" {
  name                 = var.sql_source_database_name
  server_id            = azurerm_mssql_server.source.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb          = var.sql_database_max_size_gb
  sku_name             = var.sql_database_sku
  zone_redundant       = false
  storage_account_type = "Local" # Locally-redundant backup storage (LRS)

  tags = var.tags
}

# ============================================================================
# Azure SQL Server - Target
# ============================================================================

resource "azurerm_mssql_server" "target" {
  name                         = "${var.sql_target_server_name}-${var.resource_suffix}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_target_admin_login
  administrator_login_password = var.sql_target_admin_password

  tags = var.tags
}

# Firewall rule to allow Azure services to access the target SQL server
resource "azurerm_mssql_firewall_rule" "target_allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.target.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Target SQL Database
resource "azurerm_mssql_database" "target" {
  name                 = var.sql_target_database_name
  server_id            = azurerm_mssql_server.target.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb          = var.sql_database_max_size_gb
  sku_name             = var.sql_database_sku
  zone_redundant       = false
  storage_account_type = "Local" # Locally-redundant backup storage (LRS)

  tags = var.tags
}

# ============================================================================
# Data Source - Current Azure Client Configuration
# ============================================================================

# Get current Azure client configuration (for Key Vault permissions)
data "azurerm_client_config" "current" {}

# ============================================================================
# Azure Key Vault
# ============================================================================

resource "azurerm_key_vault" "main" {
  name                = "${var.key_vault_name}-${var.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable RBAC authorization (recommended approach)
  rbac_authorization_enabled = true

  # Security features
  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Set to true for production

  # Network settings
  public_network_access_enabled = true

  tags = var.tags
}

# ============================================================================
# Key Vault RBAC - Grant Permissions
# ============================================================================

# Grant ADF Managed Identity access to read secrets from Key Vault
resource "azurerm_role_assignment" "adf_keyvault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_factory.main.identity[0].principal_id

  depends_on = [
    azurerm_key_vault.main,
    azurerm_data_factory.main
  ]
}

# Grant current user/service principal admin access to manage secrets
resource "azurerm_role_assignment" "user_keyvault_administrator" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id

  depends_on = [azurerm_key_vault.main]
}

# ============================================================================
# Key Vault Secrets - ADLS Gen2 Connection Details
# ============================================================================

# Store ADLS Gen2 storage account key
resource "azurerm_key_vault_secret" "adls_storage_account_key" {
  name         = "adls-storage-account-key"
  value        = azurerm_storage_account.adls.primary_access_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator,
    azurerm_storage_account.adls
  ]
}

# Store ADLS Gen2 storage account name
resource "azurerm_key_vault_secret" "adls_storage_account_name" {
  name         = "adls-storage-account-name"
  value        = azurerm_storage_account.adls.name
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator,
    azurerm_storage_account.adls
  ]
}

# Store ADLS Gen2 connection string
resource "azurerm_key_vault_secret" "adls_connection_string" {
  name         = "adls-connection-string"
  value        = azurerm_storage_account.adls.primary_connection_string
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator,
    azurerm_storage_account.adls
  ]
}

# ============================================================================
# Key Vault Secrets - SQL Server Credentials
# ============================================================================

# Store Source SQL Server admin username
resource "azurerm_key_vault_secret" "sql_source_admin_username" {
  name         = "sql-source-admin-username"
  value        = var.sql_source_admin_login
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator
  ]
}

# Store Source SQL Server admin password
resource "azurerm_key_vault_secret" "sql_source_admin_password" {
  name         = "sql-source-admin-password"
  value        = var.sql_source_admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator
  ]
}

# Store Target SQL Server admin username
resource "azurerm_key_vault_secret" "sql_target_admin_username" {
  name         = "sql-target-admin-username"
  value        = var.sql_target_admin_login
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator
  ]
}

# Store Target SQL Server admin password
resource "azurerm_key_vault_secret" "sql_target_admin_password" {
  name         = "sql-target-admin-password"
  value        = var.sql_target_admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.user_keyvault_administrator
  ]
}

# ============================================================================
# Azure Data Factory - Global Parameters
# ============================================================================

# NOTE: The AzureRM provider does not currently support creating global parameters via Terraform.
# Global parameters must be created manually in ADF Studio after deployment.
#
# To create global parameters in ADF Studio:
# 1. Open ADF Studio (use the URL from terraform outputs)
# 2. Go to Manage → Global parameters
# 3. Click "+ New" and add the following parameters:
#
# Parameter: adls_source_url
#   Type: String
#   Value: https://${azurerm_storage_account.adls.name}.dfs.core.windows.net
#   Example: https://adlsdepractice20260201.dfs.core.windows.net
#
# Parameter: key_vault_url
#   Type: String
#   Value: ${azurerm_key_vault.main.vault_uri}
#   Example: https://kv-dataeng-20260201.vault.azure.net/
#
# Parameter: sql_source_server_name
#   Type: String
#   Value: ${azurerm_mssql_server.source.fully_qualified_domain_name}
#   Example: sql-source-dataengpractice-20260201.database.windows.net
#
# Parameter: sql_source_database_name
#   Type: String
#   Value: sourcedb
#
# Parameter: sql_target_server_name
#   Type: String
#   Value: ${azurerm_mssql_server.target.fully_qualified_domain_name}
#   Example: sql-target-dataengpractice-20260201.database.windows.net
#
# Parameter: sql_target_database_name
#   Type: String
#   Value: targetdb
#
# The actual values will be available in terraform outputs after deployment.


