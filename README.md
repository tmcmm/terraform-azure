# Terraform-Azure
Repo for playing with Azure AKS using Terraform

## What is Terraform?
Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.

The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.

The key features of Terraform are:
__Infrastructure as Code__
Infrastructure is described using a high-level configuration syntax. This allows a blueprint of your datacenter to be versioned and treated as you would any other code. Additionally, infrastructure can be shared and re-used.

__Execution Plans__
Terraform has a "planning" step where it generates an execution plan. The execution plan shows what Terraform will do when you call apply. This lets you avoid any surprises when Terraform manipulates infrastructure.

__Resource Graph__
Terraform builds a graph of all your resources, and parallelizes the creation and modification of any non-dependent resources. Because of this, Terraform builds infrastructure as efficiently as possible, and operators get insight into dependencies in their infrastructure.

__Change Automation__
Complex changesets can be applied to your infrastructure with minimal human interaction. With the previously mentioned execution plan and resource graph, you know exactly what Terraform will change and in what order, avoiding many possible human errors.

__Files:__<br>
main.tf -> Create the Terraform configuration file that declares the Azure provider. <br>
variables.tf -> File for declaring variables <br>
output-tf -> Terraform outputs allow you to define values that will be highlighted to the user when Terraform applies a plan, and can be queried using the terraform output command. In this section, you create an output file that allows access to the cluster with kubectl.<br>
k8s.tf -> Create the Terraform configuration file that declares the resources for the Kubernetes cluster.<br>

**Install Terraform env to manage different Terraform [versions](https://github.com/tfutils/tfenv)**
[
__List your account Subscription ID:__
```
az account list -o table | grep 'subs_name' | awk '{print $ 3}'
```
__Create SP for deploying terraform objects:__
```
az ad sp create-for-rbac --name terraform --role="Contributor" --scopes="/subscriptions/$SUBS_ID" --skip-assignment >> sp-credentials-terraform.yaml 2>&1
```
__Export your service principal credentials. Replace the placeholders with appropriate values from your service principal created above__:<br>
```
export TF_VAR_client_id=<service-principal-appid> 
export TF_VAR_client_secret=<service-principal-password>
```

### Set up Azure storage to store Terraform state: <br>

Terraform tracks state locally via the terraform.tfstate file. This pattern works well in a single-person environment. In a multi-person environment, Azure storage is used to track state. You can also track the state locally. <br>

In this section, you see how to do the following tasks:<br>

1. Retrieve storage account information (account name and account key)<br>
2. Create a storage container into which Terraform state information will be stored.<br>
3. In the Azure portal, select All services in the left menu.<br>

4. Select Storage accounts.<br>

5. On the Storage accounts tab, select the name of the storage account into which Terraform is to store state. For example, you can use the storage account created when you opened Cloud Shell the first time. The storage account name created by Cloud Shell typically starts with cs followed by a random string of numbers and letters. Take note of the storage account you select. This value is needed later.<br>

6. On the storage account tab, select Access keys.<br>

```
az group create \
  --name storage-resource-group \
  --location westus
  
az storage account create \
  --name <account-name> \
  --resource-group storage-resource-group \
  --location westus \
  --sku Standard_RAGRS \
  --kind StorageV2
  
key=$(az storage account keys list -g <resource_group> -n <storage_account_name> --query [0].value -o tsv)
az storage container create -n <storage_container_name> --account-name "storage_account_name" --account-key $key
```
### Create the Kubernetes cluster
In this section, you see how to use the terraform init command to create the resources defined in the configuration files you created in the previous sections.
You can initialize terraform on the command line passing the backend configuration as folows:
```
terraform init -backend-config="storage_account_name=<YourAzureStorageAccountName>" -backend-config="container_name=tfstate" -backend-config="access_key=<YourStorageAccountAccessKey>" -backend-config="key=codelab.microsoft.tfstate" 
```

You can also put these under the file provider.tf:<br>
```
terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
    backend "azurerm" {
      resource_group_name  = ""
      storage_account_name = ""
      container_name       = "tfstate"
      access_key = "FCJh9BztuY4/xxxxxxx"
      key = "codelab.microsoft.tfstate" 
    }

}

provider "azurerm" {
  subscription_id = "xxxxx-4dxx0-xxxx-xxxxxxxx"
  # Tenant Id for the terraform SP 'terraform-tmcmm'
  tenant_id       = "xxx-2d7cxxxx7"
  features {}
}
```
Then run:
```
terraform plan -out out.plan
terraform apply out.plan
```

### Access the Cluster
```
az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)
```
### Destroy the environment
Remember to destroy any resources you create once you are done with this tutorial. Run the destroy command and confirm with yes in your terminal.
```
terraform destroy
```

