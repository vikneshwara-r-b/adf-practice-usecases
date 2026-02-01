# Azure Data Factory Practice Use Cases

This repository contains Terraform infrastructure code and practice use cases for Azure Data Factory and related Azure data engineering resources.

## 📁 Repository Structure

```
.
├── README.md                       # This file - Project overview
└── infra/                         # Infrastructure as Code (Terraform)
    ├── main.tf                    # Main resource definitions
    ├── variables.tf               # Input variable declarations
    ├── outputs.tf                 # Output values
    ├── terraform.tfvars.example   # Example configuration
    ├── README.md                  # Complete deployment guide
    └── .gitignore                 # Git ignore rules
```

## 🎯 What's Included

### Infrastructure (Terraform)
Complete Azure data engineering infrastructure including:
- **Azure Data Factory v2** - ETL/ELT orchestration with managed identity
- **ADLS Gen2 Storage** - Data lake with hierarchical namespace
- **Azure SQL Databases** - Source and target databases for data movement
- **RBAC Configuration** - Secure access using managed identities

### Use Cases (Coming Soon)
Practical ADF pipeline examples demonstrating:
- Data ingestion from various sources
- Data transformation workflows
- Incremental data loading patterns
- Error handling and monitoring

## 🚀 Quick Start

### Prerequisites
- Azure subscription with appropriate permissions
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) installed
- [Terraform](https://www.terraform.io/downloads) >= 1.0 installed

### Deploy Infrastructure

1. **Authenticate to Azure:**
   ```bash
   az login
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```

2. **Navigate to infrastructure directory:**
   ```bash
   cd infra
   ```

3. **Follow the complete deployment guide:**
   
   📘 See [infra/README.md](infra/README.md) for detailed step-by-step instructions

## 📚 Documentation

- **[Complete Deployment Guide](infra/README.md)** - Comprehensive guide for deploying and managing the infrastructure
- Terraform variable documentation in `infra/variables.tf`
- Output documentation in `infra/outputs.tf`

## 💡 Learning Objectives

This repository helps you practice:
- Infrastructure as Code (IaC) with Terraform
- Azure Data Factory pipeline development
- Azure data services integration
- Managed identity authentication
- ETL/ELT design patterns

## 🛠️ Technologies Used

- **Terraform** - Infrastructure provisioning
- **Azure Data Factory** - Data orchestration
- **Azure Data Lake Storage Gen2** - Data lake storage
- **Azure SQL Database** - Relational databases
- **Azure Managed Identity** - Secure authentication

## 📄 License

This project is provided as-is for educational and development purposes.

## 🤝 Contributing

Feel free to fork this repository and submit pull requests with improvements or additional use cases.
