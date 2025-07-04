#!/bin/bash

# Set variables
RESOURCE_GROUP="myThreeTierAppRG"
LOCATION="eastus"
ACR_NAME="myacrthreetierapp"
SQL_SERVER_NAME="mythreetiersqlserver"
SQL_ADMIN_USER="sqladmin"
SQL_ADMIN_PASSWORD="P@ssw0rd1234"
SQL_DATABASE_NAME="myThreeTierDB"
AKS_NAME="myThreeTierAKS"

# Log in to Azure (comment out if using Cloud Shell or already authenticated)
az login

# Set the subscription (replace <subscription-id> with your actual subscription ID)
# az account set --subscription "<subscription-id>"

# Create a resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create an Azure Container Registry (ACR)
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic

# Create an Azure SQL Server
az sql server create --resource-group $RESOURCE_GROUP --name $SQL_SERVER_NAME \
  --admin-user $SQL_ADMIN_USER --admin-password $SQL_ADMIN_PASSWORD --location $LOCATION

# Create a firewall rule to allow Azure services to access the SQL Server
az sql server firewall-rule create --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME \
  --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# Create a SQL Database
az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME \
  --name $SQL_DATABASE_NAME --service-objective S0

# Create an AKS cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count 1 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Grant AKS access to ACR
az aks update --resource-group $RESOURCE_GROUP --name $AKS_NAME --attach-acr $ACR_NAME

# Get AKS credentials for kubectl
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

echo "Azure resources provisioned successfully!"