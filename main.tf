/*
https://github.com/terraform-providers/terraform-provider-azurerm
https://github.com/hashicorp/terraform-azurerm-nomad/tree/master/modules/install-nomad
https://registry.terraform.io/modules/hashicorp/nomad/azurerm/latest/submodules/nomad-cluster
https://www.packer.io/docs/builders/azure/arm
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
*/
locals {
  packer_base_template = "./packer/centos-azure.pkr.hcl"
  packer_base_file = "./packer-template.pkr.hcl"
  packer_nomad_template = "./packer/centos-azure-nomad.pkr.hcl"
  packer_nomad_file = "./packer-template-nomad.pkr.hcl"

}

terraform {
  required_providers {
    azurerm = {
      version = "=2.40.0"
    }
    tfe = {
      version = "~> 0.24.0"
    }
  }
}
# Configure the Microsoft Azure Provider

provider "azurerm" {
  # We recommend pinning to the specific version of the Azure Provider you're using
  # since new versions are released frequently

  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

  # subscription_id = "..."
  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
}


resource "azurerm_resource_group" "builder"{

  location = var.location
  name = "builder"
}

//module "nomad_cluster" {
//  # TODO: update this to the final URL
//  # Use version v0.0.1 of the nomad-cluster module
//  source = "github.com/hashicorp/terraform-azurerm-nomad//modules/nomad-cluster?ref=v0.0.1"
//
//  # Specify the ID of the Nomad Azure Image. You should build this using the scripts in the install-nomad module.
//  ami_id = "ami-abcd1234"
//
//  # Configure and start Nomad during boot. It will automatically connect to the Consul cluster specified in its
//  # configuration and form a cluster with other Nomad nodes connected to that Consul cluster.
//  user_data = <<-EOF
//              #!/bin/bash
//              /opt/nomad/bin/run-nomad --server --num-servers 3
//              EOF
//
//  # ... See vars.tf for the other parameters you must define for the nomad-cluster module
//}
resource "azurerm_storage_account" "builder_storage" {
  account_replication_type = "LRS"
  account_tier = "Standard"
  location = azurerm_resource_group.builder.location
  name = "buildersg"
  resource_group_name = azurerm_resource_group.builder.name
}

resource "local_file" "packer_base_template" {
  filename = local.packer_base_file
  content = templatefile(local.packer_base_template, {
    subscription_id = var.subscription_id,
    client_id = var.client_id,
    client_secret = var.client_secret,
    tenant_id = var.tenant_id,
    managed_image_resource_group_name = azurerm_resource_group.builder.name
    managed_image_name = "base-image",
    location = var.location
    storage_account = azurerm_storage_account.builder_storage.name
  } )
}

resource "local_file" "packer_nomad_template" {
  filename = local.packer_nomad_file
  content = templatefile(local.packer_nomad_template, {
    subscription_id = var.subscription_id,
    client_id = var.client_id,
    client_secret = var.client_secret,
    tenant_id = var.tenant_id,
    managed_image_resource_group_name = azurerm_resource_group.builder.name
    managed_image_name = "nomad-image",
    custom_managed_image_name = "base-image"
    location = var.location
    storage_account = azurerm_storage_account.builder_storage.name
  } )
}

resource "null_resource" "run_packer" {
  depends_on = [
    azurerm_storage_account.builder_storage,
    azurerm_resource_group.builder,
    local_file.packer_base_template
  ]
  provisioner "local-exec" {
    command = "packer build ${local_file.packer_base_template.filename}"

  }
  triggers = {
    packerfile = sha256(local_file.packer_base_template.content)
  }
}