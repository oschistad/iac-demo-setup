/*
https://registry.terraform.io/modules/hashicorp/nomad/azurerm/latest/submodules/nomad-cluster
https://www.packer.io/docs/builders/azure/arm
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
*/

resource "azurerm_resource_group" "builder"{

  location = "Norway East"
  name = "builder"
}

module "nomad_cluster" {
  # TODO: update this to the final URL
  # Use version v0.0.1 of the nomad-cluster module
  source = "github.com/hashicorp/terraform-azurerm-nomad//modules/nomad-cluster?ref=v0.0.1"

  # Specify the ID of the Nomad Azure Image. You should build this using the scripts in the install-nomad module.
  ami_id = "ami-abcd1234"

  # Configure and start Nomad during boot. It will automatically connect to the Consul cluster specified in its
  # configuration and form a cluster with other Nomad nodes connected to that Consul cluster.
  user_data = <<-EOF
              #!/bin/bash
              /opt/nomad/bin/run-nomad --server --num-servers 3
              EOF

  # ... See vars.tf for the other parameters you must define for the nomad-cluster module
}