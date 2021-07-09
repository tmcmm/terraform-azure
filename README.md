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


az account list -o table | grep 'subs_name' | awk '{print $ 3}'
az ad sp create-for-rbac --name terraform --role="Contributor" --scopes="/subscriptions/$SUBS_ID" --skip-assignment >> sp-credentials-terraform.yaml 2>&1

### Provider
The details can be paste into the provider ID in your Terraform file and run.<br>

provider "azurerm" {
subscription_id = "value"
client_id = ""
client_secret = ""
tenant_id = ""
features {}
}
