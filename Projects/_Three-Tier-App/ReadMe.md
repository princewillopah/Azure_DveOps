<span style="color:rgb(0, 238, 255); font-size:50px; font-weight: bold;">Three Tier Application</span>

<p style="color:111111; font-size:15px; font-weight: 600;">Deploying a three-tier application using Azure DevOps pipelines involves setting up Azure resources (Resource Group, AKS Kubernetes Cluster, Azure Container Registry, SQL Server, and SQL Database) and configuring a CI/CD pipeline to automate the build and deployment process.<br> 
Below is a comprehensive, beginner-friendly guide with well-documented steps, prerequisites, and Azure CLI commands to provision the resources, along with an Azure DevOps pipeline configuration. <br>
The three-tier application typically consists of a presentation layer (frontend), an application layer (backend), and a data layer (database). For this guide, we’ll assume a simple web application with a frontend, backend, and SQL database.
</p>

This project is based on this guide: (https://github.com/Microsoft/azuredevopslabs/tree/master/labs/vstsextend/kubernetes/)

## Pre-requisites
Before you begin, ensure you have the following:

### Azure Prerequisites
1. **Azure Account:**
    - Sign up for a free Azure account at azure.microsoft.com if you don’t have one. This provides $200 in credits and free access to certain services for 30 days.
    - Ensure you have permissions to create resources (Owner or Contributor role in your Azure subscription).
2. **Azure CLI:**
    - Install the Azure CLI on your local machine or use Azure Cloud Shell (available in the Azure Portal). To install locally, follow the instructions at Install Azure CLI.
    - Verify installation: `az --version`.
3. **kubectl:**
    - Install the Kubernetes command-line tool to interact with the AKS cluster: az aks install-cli.
    - Verify installation: kubectl `version --client`.

4. **Docker:**
    - Install Docker Desktop to build and test container images locally: Docker Desktop.
    - Verify installation: `docker --version`.

5. **Git**
    - Install Git for version control: Git Downloads.
    - Verify installation: `git --version`.




### + Azure DevOps Prerequisites

1. Azure DevOps Account:
    - Create a free Azure DevOps account at dev.azure.com.
    - Create an organization and a project in Azure DevOps.
2. GitHub Account (Optional):
    - A GitHub account to host your application code. Fork or create a repository with your application code. For this guide, we’ll use a sample repository: MicrosoftDocs/pipelines-javascript-docker.
3. Service Connections:
    - You’ll need to set up service connections in Azure DevOps for Azure Resource Manager (ARM) and Docker Registry to allow the pipeline to interact with Azure resources.

### Application Prerequisites

- A sample three-tier application (frontend, backend, and database schema). For this guide, we’ll assume:
    - Frontend: A simple Node.js or React app.
    - Backend: A .NET Core or Node.js API that connects to a SQL database.
    - Database: An Azure SQL Database with a sample schema.
- A `Dockerfile` for both frontend and backend, and a Kubernetes manifest file (`deployment.yml`, `service.yml`) to deploy the application to AKS.
- A SQL DACPAC file or SQL scripts for database deployment.



### Infrastructure provisioning

**Using the below script, you can provision infra for this demo**

The following resources will be provisioned:

* A Resource Group
* An Image container registry
* An AKS Kubernetes Cluster
* A SQL Server
* A SQL Database


## Steps:

``` bash
#!/bin/bash
REGION="westus"
RG="threeTierApp-rg"                           # RG is resouce group
CLUSTER_NAME="threeTierApp-cluster"
ACR_NAME="day11demoacr"
SQLSERVER="threeTierApp-sqlserver"
DB="mhcdb"


#Create Resource group
az group create --name $RG --location $REGION

#Deploy AKS
az aks create --resource-group $RG --name $CLUSTER_NAME --enable-addons monitoring --generate-ssh-keys --location $REGION

#Deploy ACR
az acr create --resource-group $RG --name $ACR_NAME --sku Standard --location $REGION

#Authenticate with ACR to AKS
az aks update -n $CLUSTER_NAME -g $RG --attach-acr $ACR_NAME

#Create SQL Server and DB
az sql server create -l $REGION -g $RG -n $SQLSERVER -u sqladmin -p P2ssw0rd1234

az sql db create -g $RG -s $SQLSERVER -n $DB --service-objective S0

```

## Change the Firewall settings of the SQL server

![image](https://github.com/piyushsachdeva/AzureDevOps-Zero-to-Hero/assets/40286378/d421dd8b-1a85-447a-ad2d-f0ddb859953d)


## Setup Azure DevOps Project

### Pre-requisites

Make sure the below Azure DevOps extensions are installed and enabled in your organization
- Replace Token
- Kubernetes extension

Once the infra is ready, go to dev.azure.com --> Project --> repos 
and import the below git repo, which has the source code and pipeline code

https://github.com/piyushsachdeva/MyHealthClinic-AKS

### Build and Release Pipeline

- You can create your pipeline by following along the video or editing the existing pipeline. The below details need to be updated in the pipeline:
   - Azure Service connection
   - Token pattern
   - Pipeline variables
   - The Kubectl version should be the latest in the release pipeline
   - Secrets should be updated in the deployment step
   - ACR details in the pipeline should be updated
 
#### Steps in the pipeline

<img width="805" alt="image" src="https://github.com/piyushsachdeva/AzureDevOps-Zero-to-Hero/assets/40286378/64907bef-acbf-41f1-b3de-63b46681db3d">

 [Image source](https://azuredevopslabs.com/labs/vstsextend/kubernetes/)

## Destroy the resources at the end of the demo

```
#!/bin/bash


# Set environment variables
REGION="westus"
RG="threeTierApp-rg"
CLUSTER_NAME="threeTierApp-cluster"
ACR_NAME="day11demoacr"
SQLSERVER="threeTierApp-sqlserver"
DB="mhcdb"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to check if the resource exists
resource_exists() {
    az resource show --ids $1 &> /dev/null
}

# Delete Azure Kubernetes Service (AKS)
if resource_exists $(az aks show --resource-group $RG --name $CLUSTER_NAME --query id --output tsv); then
    az aks delete --resource-group $RG --name $CLUSTER_NAME || handle_error "Failed to delete AKS."
else
    echo "AKS not found. Skipping deletion."
fi

# Delete Azure Container Registry (ACR)
if resource_exists $(az acr show --name $ACR_NAME --resource-group $RG --query id --output tsv); then
    az acr delete --name $ACR_NAME --resource-group $RG || handle_error "Failed to delete ACR."
else
    echo "ACR not found. Skipping deletion."
fi

# Delete SQL Database
if resource_exists $(az sql db show --resource-group $RG --server $SQLSERVER --name $DB --query id --output tsv); then
    az sql db delete --resource-group $RG --server $SQLSERVER --name $DB || handle_error "Failed to delete SQL Database."
else
    echo "SQL Database not found. Skipping deletion."
fi

# Delete SQL Server
if resource_exists $(az sql server show --resource-group $RG --name $SQLSERVER --query id --output tsv); then
    az sql server delete --resource-group $RG --name $SQLSERVER || handle_error "Failed to delete SQL Server."
else
    echo "SQL Server not found. Skipping deletion."
fi

# Delete Resource Group
if resource_exists $(az group show --name $RG --query id --output tsv); then
    az group delete --name $RG || handle_error "Failed to delete Resource Group."
else
    echo "Resource Group not found. Skipping deletion."
fi

echo "Resources successfully deleted."

```

