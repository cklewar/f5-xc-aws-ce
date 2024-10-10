terraform {
  required_version = ">= 1.7.0"
  cloud {
    organization = "cklewar"
    hostname     = "app.terraform.io"

    workspaces {
      name = "f5-xc-aws-ce-module"
    }
  }

  required_providers {
    restful = {
      source  = "magodo/restful"
      version = ">= 0.16.1"
    }

    volterra = {
      source  = "volterraedge/volterra"
      version = "= 0.11.37"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.51.0"
    }

    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}