//terraform {
//  required_providers {
//    tfe = {
//      version = "~> 0.24.0"
//    }
//  }
//}
variable "tfe_token" {
  default = ""
}
variable "github_oauth_token" {
  default = ""
}
provider "tfe" {
  token    = var.tfe_token
}
variable "tfe_orgname" {
  default = "aztekdemo"
}
locals {
  tfe_vars = {
    "subscription_id" = { "value" = var.subscription_id, "sensitive" = true }
    "client_id" = { "value" = var.client_id, "sensitive" = true  }
    "client_secret" = { "value" = var.client_secret, "sensitive" = true  }
    "tenant_id" = { "value" = var.tenant_id, "sensitive" = true  }
    "tfe_token" = { "value" = var.tfe_token, "sensitive" = true  }
    "github_oauth_token" = { "value" = var.github_oauth_token, "sensitive" = true  }
    "github_oauth_token_id" = { "value" = tfe_oauth_client.github_vcs.oauth_token_id, "sensitive" = false  }
    "tfe_orgname" = { "value" = var.tfe_orgname, "sensitive" = false  }
  }
}
variable "masterws_repo" {
  default = "oschistad/iac-demo-masterws"
}
resource "tfe_workspace" "tfe_main" {
  name = "iac-demo-masterws"
  organization = "aztekdemo"
  vcs_repo {
    identifier = var.masterws_repo
    oauth_token_id = tfe_oauth_client.github_vcs.oauth_token_id
  }
}

resource "tfe_variable" "infra_vars" {
  for_each = local.tfe_vars
  category = "terraform"
  key = each.key
  value = lookup(each.value,"value","")
  sensitive = lookup(each.value,"sensitive",false)
  workspace_id = tfe_workspace.tfe_main.id
}


resource "tfe_oauth_client" "github_vcs" {
  organization     = var.tfe_orgname
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_oauth_token
  service_provider = "github"
}