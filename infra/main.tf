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
  name           = var.sql_source_database_name
  server_id      = azurerm_mssql_server.source.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = var.sql_database_max_size_gb
  sku_name       = var.sql_database_sku
  zone_redundant = false

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
  name           = var.sql_target_database_name
  server_id      = azurerm_mssql_server.target.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = var.sql_database_max_size_gb
  sku_name       = var.sql_database_sku
  zone_redundant = false

  tags = var.tags
}

