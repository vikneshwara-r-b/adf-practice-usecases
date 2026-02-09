# Outputs for Azure Data Engineering Infrastructure

# ============================================================================
# Resource Group
# ============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

# ============================================================================
# Azure Data Factory
# ============================================================================

output "adf_name" {
  description = "Name of the Azure Data Factory"
  value       = azurerm_data_factory.main.name
}

output "adf_id" {
  description = "ID of the Azure Data Factory"
  value       = azurerm_data_factory.main.id
}

output "adf_principal_id" {
  description = "Principal ID (Object ID) of the ADF managed identity"
  value       = azurerm_data_factory.main.identity[0].principal_id
}

output "adf_tenant_id" {
  description = "Tenant ID of the ADF managed identity"
  value       = azurerm_data_factory.main.identity[0].tenant_id
}

# ============================================================================
# Storage Account (ADLS Gen2)
# ============================================================================

output "storage_account_name" {
  description = "Name of the ADLS Gen2 storage account"
  value       = azurerm_storage_account.adls.name
}

output "storage_account_id" {
  description = "ID of the ADLS Gen2 storage account"
  value       = azurerm_storage_account.adls.id
}

output "storage_account_primary_endpoint" {
  description = "Primary DFS endpoint of the storage account"
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary Blob endpoint of the storage account"
  value       = azurerm_storage_account.adls.primary_blob_endpoint
}

output "source_container_name" {
  description = "Name of the source ADLS Gen2 container"
  value       = azurerm_storage_data_lake_gen2_filesystem.source.name
}

output "target_container_name" {
  description = "Name of the target ADLS Gen2 container"
  value       = azurerm_storage_data_lake_gen2_filesystem.target.name
}

# ============================================================================
# SQL Server - Source
# ============================================================================

output "sql_source_server_name" {
  description = "Name of the source SQL server"
  value       = azurerm_mssql_server.source.name
}

output "sql_source_server_id" {
  description = "ID of the source SQL server"
  value       = azurerm_mssql_server.source.id
}

output "sql_source_server_fqdn" {
  description = "Fully qualified domain name of the source SQL server"
  value       = azurerm_mssql_server.source.fully_qualified_domain_name
}

output "sql_source_database_name" {
  description = "Name of the source SQL database"
  value       = azurerm_mssql_database.source.name
}

output "sql_source_database_id" {
  description = "ID of the source SQL database"
  value       = azurerm_mssql_database.source.id
}

# ============================================================================
# SQL Server - Target
# ============================================================================

output "sql_target_server_name" {
  description = "Name of the target SQL server"
  value       = azurerm_mssql_server.target.name
}

output "sql_target_server_id" {
  description = "ID of the target SQL server"
  value       = azurerm_mssql_server.target.id
}

output "sql_target_server_fqdn" {
  description = "Fully qualified domain name of the target SQL server"
  value       = azurerm_mssql_server.target.fully_qualified_domain_name
}

output "sql_target_database_name" {
  description = "Name of the target SQL database"
  value       = azurerm_mssql_database.target.name
}

output "sql_target_database_id" {
  description = "ID of the target SQL database"
  value       = azurerm_mssql_database.target.id
}

# ============================================================================
# Connection Strings and Configuration
# ============================================================================

output "adf_data_factory_url" {
  description = "URL to access Azure Data Factory Studio"
  value       = "https://adf.azure.com/en-us/home?factory=/subscriptions/${split("/", azurerm_data_factory.main.id)[2]}/resourceGroups/${azurerm_resource_group.main.name}/providers/Microsoft.DataFactory/factories/${azurerm_data_factory.main.name}"
}

# ============================================================================
# Azure Key Vault
# ============================================================================

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_secrets" {
  description = "List of secrets stored in Key Vault"
  value = {
    adls_storage_account_key  = azurerm_key_vault_secret.adls_storage_account_key.name
    adls_storage_account_name = azurerm_key_vault_secret.adls_storage_account_name.name
    sql_source_password       = azurerm_key_vault_secret.sql_source_admin_password.name
    sql_target_password       = azurerm_key_vault_secret.sql_target_admin_password.name
  }
}

# ============================================================================
# ADF Global Parameters (Manual Configuration Required)
# ============================================================================

output "adf_global_parameters_instructions" {
  description = "Instructions and values for creating ADF global parameters"
  sensitive   = true
  value       = <<-EOT
    ╔════════════════════════════════════════════════════════════════════════╗
    ║        ADF GLOBAL PARAMETERS - MANUAL CONFIGURATION REQUIRED           ║
    ╚════════════════════════════════════════════════════════════════════════╝
    
    Create the following global parameters in ADF Studio:
    (Navigate to: Manage → Global parameters → + New)
    
    1. adls_source_url
       Type: String
       Value: https://${azurerm_storage_account.adls.name}.dfs.core.windows.net
    
    2. key_vault_url
       Type: String
       Value: ${azurerm_key_vault.main.vault_uri}
    
    3. sql_source_server_name
       Type: String
       Value: ${azurerm_mssql_server.source.fully_qualified_domain_name}
    
    4. sql_source_database_name
       Type: String
       Value: ${azurerm_mssql_database.source.name}
    
    5. sql_target_server_name
       Type: String
       Value: ${azurerm_mssql_server.target.fully_qualified_domain_name}
    
    6. sql_target_database_name
       Type: String
       Value: ${azurerm_mssql_database.target.name}
    
    7. sql_source_server_password_secret_key
       Type: String
       Value: sql-source-admin-password
       (Key Vault secret name for source SQL password)
    
    8. sql_target_server_password_secret_key
       Type: String
       Value: sql-target-admin-password
       (Key Vault secret name for target SQL password)
    
    9. sql_source_server_username
       Type: String
       Value: ${var.sql_source_admin_login}
    
    10. sql_target_server_username
        Type: String
        Value: ${var.sql_target_admin_login}
    
    ═══════════════════════════════════════════════════════════════════════
    Usage in ADF Pipelines:
    @pipeline().globalParameters.adls_source_url
    @pipeline().globalParameters.key_vault_url
    @pipeline().globalParameters.sql_source_server_name
    @pipeline().globalParameters.sql_source_server_password_secret_key
    @pipeline().globalParameters.sql_source_server_username
    ═══════════════════════════════════════════════════════════════════════
  EOT
}
