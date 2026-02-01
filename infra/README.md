# Azure Data Engineering Infrastructure - Terraform

This directory contains Terraform configuration to provision a complete Azure data engineering infrastructure including Data Factory, ADLS Gen2, and SQL databases.

## 📋 Resources Provisioned

| Resource Type | Name Pattern | Purpose |
|--------------|--------------|---------|
| Resource Group | `rg-data-engineering` | Container for all resources |
| Data Factory | `adf-dataeng-pipeline-{suffix}` | ETL/ELT orchestration |
| Storage Account | `adlsdataeng{suffix}` | ADLS Gen2 data lake |
| Source Container | `source` | Source data storage |
| Target Container | `target` | Target data storage |
| SQL Server (Source) | `sql-source-dataeng-{suffix}` | Source database server |
| SQL Database (Source) | `sourcedb` | Source database |
| SQL Server (Target) | `sql-target-dataeng-{suffix}` | Target database server |
| SQL Database (Target) | `targetdb` | Target database |

**Key Features:**
- System-assigned managed identity for Azure Data Factory
- RBAC-based access (ADF → Storage via Storage Blob Data Contributor role)
- SQL Server Authentication (username/password)
- Hierarchical namespace enabled for ADLS Gen2

---

## 🚀 Quick Start

```bash
# 1. Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# 2. Edit terraform.tfvars with your values
code terraform.tfvars

# 3. Initialize and deploy
terraform init
terraform plan
terraform apply
```

---

## 🔧 Prerequisites

Before you begin, ensure you have:

- [ ] Azure subscription with appropriate permissions (Contributor or Owner)
- [ ] [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) installed (`az --version`)
- [ ] [Terraform](https://www.terraform.io/downloads) >= 1.0 installed (`terraform version`)
- [ ] Authenticated to Azure (`az login`)
- [ ] Correct subscription selected (`az account show`)

---

## 📝 Detailed Deployment Steps

### Step 1: Authenticate to Azure

```bash
# Login to Azure
az login

# Verify subscription
az account show

# Set subscription if you have multiple
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Step 2: Prepare Configuration

```bash
# Navigate to infra directory
cd infra

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your preferred editor
code terraform.tfvars
# OR
nano terraform.tfvars
```

### Step 3: Update Required Values

Edit `terraform.tfvars` and update these **REQUIRED** fields:

```hcl
# Unique suffix for global uniqueness
resource_suffix = "20260102"  # Use your own unique value

# Resource names (suffix will be appended automatically)
storage_account_name = "adlsdataeng"
sql_source_server_name = "sql-source-dataeng"
sql_target_server_name = "sql-target-dataeng"

# IMPORTANT: Use strong passwords!
sql_source_admin_password = "YourStrongPassword123!"
sql_target_admin_password = "YourStrongPassword123!"
```

**Password Requirements:**
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

### Step 4: Initialize Terraform

```bash
terraform init
```

Expected output:
```
✓ Backend initialized
✓ Provider plugins installed
✓ Lock file created
```

### Step 5: Validate Configuration

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 6: Preview Changes

```bash
terraform plan
```

Review the plan carefully. You should see approximately:
- 1 resource group
- 1 data factory
- 1 storage account
- 2 containers
- 2 SQL servers
- 2 SQL databases
- 2 firewall rules
- 1 role assignment

**Total: ~12 resources to be created**

### Step 7: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

Deployment takes approximately **5-10 minutes**.

### Step 8: Review Outputs

```bash
# View all outputs
terraform output

# View specific outputs
terraform output adf_name
terraform output storage_account_name
terraform output sql_source_server_fqdn
```

---

## 📁 File Structure

```
infra/
├── main.tf                    # Main resource definitions
├── variables.tf               # Input variable declarations  
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variables file
├── terraform.tfvars          # Your configuration (gitignored)
├── .terraform.lock.hcl       # Provider version lock file
├── .gitignore                # Git ignore file for sensitive data
├── README.md                 # This comprehensive guide
└── .terraform/               # Terraform working directory (gitignored)
```

---

## 🔑 Authentication & Security

### Managed Identity
All resources use Azure Managed Identity for authentication where possible:
- **ADF to Storage**: Storage Blob Data Contributor role via RBAC
- **ADF Identity**: System-assigned managed identity enabled

### SQL Server Security
- **Authentication**: SQL Server Authentication (username/password)
- **Credentials**: Defined in variables and `terraform.tfvars`
- **Firewall**: Allows Azure services by default
- **Admin Access**: Via credentials in terraform.tfvars

### Sensitive Data Protection
The following files are gitignored to protect sensitive information:
- `terraform.tfvars` - Contains passwords and configuration
- `terraform.tfstate` - Contains resource IDs and sensitive data
- `.terraform/` - Terraform working directory

**⚠️ Never commit these files to version control!**

---

## ✅ Verification & Testing

### 1. Verify in Azure Portal
- Navigate to Azure Portal
- Check that resource group contains all resources
- Verify ADF has system-assigned identity enabled
- Check SQL servers are accessible

### 2. Test Storage Access

```bash
# Upload a test file to source container
az storage blob upload \
  --account-name <storage-account-name> \
  --container-name source \
  --name test.txt \
  --file test.txt \
  --auth-mode login
```

### 3. Test ADF Access to Storage
- Open ADF Studio (use URL from outputs)
- Create a linked service to ADLS Gen2 using managed identity
- Test connection (should succeed)

### 4. Test SQL Connectivity
- Use Azure Data Studio or SSMS
- Connect to SQL servers using credentials from `terraform.tfvars`
- Verify databases exist

---

## 🔄 Managing the Infrastructure

### Update Resources

```bash
# Make changes to .tf files or terraform.tfvars
terraform plan    # Review changes
terraform apply   # Apply changes
```

### View Current State

```bash
# Show current state
terraform show

# List all managed resources
terraform state list

# Show specific resource
terraform state show azurerm_data_factory.main
```

### Add More Resources

1. Edit `main.tf` to add new resources
2. Run `terraform validate` to check syntax
3. Run `terraform plan` to preview changes
4. Run `terraform apply` to create resources

### Destroy Resources

```bash
terraform destroy
```

Type `yes` when prompted.

**⚠️ WARNING:** This will permanently delete:
- All databases and their data
- All storage accounts and their data
- All ADF pipelines and configurations
- The resource group and all contained resources

---

## 🐛 Troubleshooting

### Issue: Name Already Exists

**Problem:** Storage account or SQL server name is not unique globally.

**Solution:** Update `resource_suffix` in `terraform.tfvars`:
```hcl
resource_suffix = "20260102xyz"  # Add more uniqueness
```

### Issue: Subscription ID Not Found

**Problem:** Terraform cannot determine Azure subscription.

**Solutions:**
```bash
# Option 1: Login again
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Option 2: Set environment variable
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Option 3: Reinitialize Terraform
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Issue: Insufficient Permissions

**Problem:** Cannot create resources due to permissions.

**Solution:**
```bash
# Verify subscription and permissions
az account show
az role assignment list --assignee <your-email>
```

Required roles: **Contributor** or **Owner** on subscription or resource group.

### Issue: SQL Password Validation Failed

**Problem:** Password doesn't meet complexity requirements.

**Solution:** Update password in `terraform.tfvars`:
```hcl
sql_source_admin_password = "MyStr0ng!P@ssw0rd123"
```

Ensure it has: uppercase, lowercase, number, special character, 8+ chars

### Issue: Role Assignment Not Working

**Problem:** ADF cannot access storage immediately after deployment.

**Solution:** Wait 2-5 minutes for RBAC propagation:
```bash
# Wait and retry
sleep 300
```

### Issue: Cannot Connect to SQL from Local Machine

**Problem:** SQL connection fails from your local machine.

**Solution:** Add your IP to SQL firewall:
```bash
az sql server firewall-rule create \
  --resource-group <your-rg-name> \
  --server <your-sql-server-name> \
  --name AllowMyIP \
  --start-ip-address <your-ip> \
  --end-ip-address <your-ip>
```

### Enable Debug Logging

```bash
export TF_LOG=DEBUG
terraform apply
```

---

## 📊 Cost Estimation

Approximate monthly costs in US East region (USD):

| Resource | SKU/Tier | Estimated Cost |
|----------|----------|----------------|
| Data Factory | Standard | ~$1 |
| Storage Account (ADLS Gen2) | LRS | $5-20 |
| SQL Database (Source) | Basic | ~$5 |
| SQL Database (Target) | Basic | ~$5 |
| **Total** | | **$16-31/month** |

*Costs vary based on:*
- Data transfer volumes
- Storage usage
- Query execution frequency
- Azure region

---

## 🔒 Security Best Practices

1. **Credential Management**
   - Never commit `terraform.tfvars` to version control
   - Use strong passwords (16+ characters recommended)
   - Rotate credentials regularly (every 90 days)

2. **Production Recommendations**
   - Use Azure Key Vault for password management
   - Enable private endpoints for storage and SQL
   - Implement VNet integration
   - Enable Azure Defender for SQL

3. **Monitoring & Logging**
   - Enable diagnostic logs for all resources
   - Set up alerts for failed pipeline runs
   - Monitor cost and usage regularly

4. **Network Security**
   - Implement network restrictions
   - Use private endpoints in production
   - Restrict SQL firewall rules to specific IPs

---

## 🏷️ Version Information

- **Terraform**: >= 1.0
- **AzureRM Provider**: ~> 4.0
- **Azure Region**: East US (eastus)
- **Authentication**:
  - SQL: Username/Password (SQL Server Authentication)
  - Storage: Managed Identity (RBAC)

---

## 📚 Additional Resources

### Official Documentation
- [Azure Data Factory](https://docs.microsoft.com/azure/data-factory/)
- [ADLS Gen2](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-introduction)
- [Azure SQL Database](https://docs.microsoft.com/azure/azure-sql/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

### Learning Resources
- [ADF Tutorial](https://docs.microsoft.com/azure/data-factory/quickstart-create-data-factory-portal)
- [ADLS Gen2 Best Practices](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-best-practices)
- [Azure SQL Best Practices](https://docs.microsoft.com/azure/azure-sql/database/security-best-practice)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

---

## 📞 Support

If you encounter issues:

1. Check the **Troubleshooting** section above
2. Review Terraform error messages carefully
3. Verify Azure Portal for resource status
4. Ensure Azure CLI authentication is valid
5. Consult Azure documentation

---

## 📝 Next Steps

After successful deployment:

1. **Create ADF Pipelines** - Build data movement and transformation pipelines
2. **Set Up Monitoring** - Configure alerts and monitoring
3. **Implement Data Governance** - Set up data retention and backup policies
4. **Optimize Costs** - Review and optimize resource usage
5. **CI/CD Integration** - Set up automated deployment pipelines

---

## 📄 License

This infrastructure code is provided as-is for educational and development purposes.

---

**[← Back to main README](../README.md)**