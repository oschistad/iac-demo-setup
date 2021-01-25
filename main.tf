/*
https://github.com/terraform-providers/terraform-provider-azurerm
https://github.com/hashicorp/terraform-azurerm-nomad/tree/master/modules/install-nomad
https://registry.terraform.io/modules/hashicorp/nomad/azurerm/latest/submodules/nomad-cluster
https://www.packer.io/docs/builders/azure/arm
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/image-builder
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image

*/
# Configure the Microsoft Azure Provider
provider "azurerm" {
  # We recommend pinning to the specific version of the Azure Provider you're using
  # since new versions are released frequently
  version = "=2.40.0"

  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

  # subscription_id = "..."
  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."
}
resource "azurerm_user_assigned_identity" "" {
  location = ""
  name = ""
  resource_group_name = ""
}
resource "azurerm_resource_group" "builder"{

  location = "Norway East"
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