# Variables for Azure Data Engineering Infrastructure

# General Configuration
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "resource_suffix" {
  description = "Unique suffix for resource names to ensure global uniqueness (e.g., '001', 'dev01', your initials)"
  type        = string
  default     = "001"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-data-engineering"
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
}

# Azure Data Factory
variable "adf_name" {
  description = "Name of the Azure Data Factory (will be appended with suffix)"
  type        = string
  default     = "adf-dataeng-pipeline"
}

# Storage Account (ADLS Gen2)
variable "storage_account_name" {
  description = "Name of the ADLS Gen2 storage account (must be globally unique, lowercase, no hyphens, will be appended with suffix)"
  type        = string
  default     = "adlsdataeng"
}

variable "source_container_name" {
  description = "Name of the source container in ADLS Gen2"
  type        = string
  default     = "source"
}

variable "target_container_name" {
  description = "Name of the target container in ADLS Gen2"
  type        = string
  default     = "target"
}

# SQL Server - Source
variable "sql_source_server_name" {
  description = "Name of the source SQL server (must be globally unique, will be appended with suffix)"
  type        = string
  default     = "sql-source-dataeng"
}

variable "sql_source_admin_login" {
  description = "Admin login username for source SQL server"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_source_admin_password" {
  description = "Admin password for source SQL server"
  type        = string
  sensitive   = true
}

variable "sql_source_database_name" {
  description = "Name of the source SQL database"
  type        = string
  default     = "sourcedb"
}

# SQL Server - Target
variable "sql_target_server_name" {
  description = "Name of the target SQL server (must be globally unique, will be appended with suffix)"
  type        = string
  default     = "sql-target-dataeng"
}

variable "sql_target_admin_login" {
  description = "Admin login username for target SQL server"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_target_admin_password" {
  description = "Admin password for target SQL server"
  type        = string
  sensitive   = true
}

variable "sql_target_database_name" {
  description = "Name of the target SQL database"
  type        = string
  default     = "targetdb"
}

# SQL Database SKU
variable "sql_database_sku" {
  description = "SKU for SQL databases"
  type        = string
  default     = "Basic"
}

variable "sql_database_max_size_gb" {
  description = "Maximum size of the SQL database in GB"
  type        = number
  default     = 2
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "DataEngineering"
  }
}