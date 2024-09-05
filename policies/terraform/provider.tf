terraform {
  cloud {
    organization = "great-stone-biz"
    workspaces {
      name = "aws_secret_role_type_check"
    }
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}