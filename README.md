# AWS CLOUD CE

Terraform to create F5XC AWS cloud CE

## Usage

- Clone this repo with: `git clone --recurse-submodules https://github.com/cklewar/f5-xc-aws-ce`
- Enter repository directory with: `cd aws cloud ce`
- Obtain F5XC API certificate file from Console and save it to `cert` directory
- Pick and choose from below examples and add mandatory input data and copy data into file `main.py.example`.
- Rename file __main.tf.example__ to __main.tf__ with: `rename main.py.example main.py`
- Initialize with: `terraform init`
- Apply with: `terraform apply -auto-approve` or destroy with: `terraform destroy -auto-approve`

## AWS Cloud CE common module usage example data

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
  default     = "f5xc"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
  default     = "01"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_token" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type    = string
  default = "system"
}

variable "f5xc_aws_cred" {
  type    = string
  default = "ck-aws-01"
}

variable "f5xc_aws_region" {
  type    = string
  default = "us-west-2"
}

variable "f5xc_aws_availability_zone" {
  type    = string
  default = "a"
}

variable "owner" {
  type    = string
  default = "c.klewar@f5.com"
}

variable "ssh_public_key_file" {
  type = string
}

locals {
  aws_availability_zone = format("%s%s", var.f5xc_aws_region, var.f5xc_aws_availability_zone)
  custom_tags           = {
    Owner        = var.owner
    f5xc-tenant  = var.f5xc_tenant
    f5xc-feature = "${var.project_prefix}-aws-vpc-site"
  }
}

provider "volterra" {
  api_p12_file = var.f5xc_api_p12_file
  url          = var.f5xc_api_url
  alias        = "default"
}

provider "aws" {
  region = var.f5xc_aws_region
  alias  = "default"
}
```

## AWS Cloud CE Single Node Single NIC module usage example

```hcl
module "aws_ce" {
  source                = "./modules/f5xc/ce/aws"
  is_sensitive          = false
  has_public_ip         = true
  aws_vpc_subnet_prefix = "192.168.0.0/20"
  f5xc_api_token        = var.f5xc_api_token
  f5xc_api_url          = var.f5xc_api_url
  f5xc_aws_vpc_az_nodes = {
    node0 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.0/26",
      f5xc_aws_vpc_az_name    = local.aws_availability_zone
    }
  }
  f5xc_ce_gateway_type   = "ingress_gateway"
  f5xc_namespace         = var.f5xc_namespace
  f5xc_tenant            = var.f5xc_tenant
  f5xc_token_name        = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_aws_region        = var.f5xc_aws_region
  f5xc_cluster_latitude  = -73.935242
  f5xc_cluster_longitude = 40.730610
  f5xc_cluster_name      = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_cluster_labels    = { "ves.io/fleet" : format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix) }
  owner_tag              = var.owner
  public_name            = "vip"
  ssh_public_key         = file(var.ssh_public_key_file)
  providers              = {
    aws      = aws.default
    volterra = volterra.default
  }
}

output "aws_ce" {
  value = module.aws_ce
}
````

## AWS Cloud CE Single Node Multi NIC module usage example

```hcl
module "aws_ce" {
  source                = "./modules/f5xc/ce/aws"
  is_sensitive          = false
  has_public_ip         = true
  aws_vpc_subnet_prefix = "192.168.0.0/20"
  f5xc_api_token        = var.f5xc_api_token
  f5xc_api_url          = var.f5xc_api_url
  f5xc_aws_vpc_az_nodes = {
    node0 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.0/26",
      f5xc_aws_vpc_sli_subnet = "192.168.0.64/26",
      f5xc_aws_vpc_az_name    = local.aws_availability_zone
    }
  }
  f5xc_ce_gateway_type   = "ingress_egress_gateway"
  f5xc_namespace         = var.f5xc_namespace
  f5xc_tenant            = var.f5xc_tenant
  f5xc_token_name        = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_aws_region        = var.f5xc_aws_region
  f5xc_cluster_latitude  = -73.935242
  f5xc_cluster_longitude = 40.730610
  f5xc_cluster_name      = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_cluster_labels    = { "ves.io/fleet" : format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix) }
  owner_tag              = var.owner
  public_name            = "vip"
  ssh_public_key         = file(var.ssh_public_key_file)
  providers              = {
    aws      = aws.default
    volterra = volterra.default
  }
}

output "aws_ce" {
  value = module.aws_ce
}
```

## AWS Cloud CE Multi Node Single NIC different AZ module usage example

```hcl
module "aws_ce" {
  source                = "./modules/f5xc/ce/aws"
  owner_tag             = var.owner
  has_public_ip         = true
  is_sensitive          = false
  aws_vpc_cidr_block    = "192.168.0.0/20"
  f5xc_api_token        = var.f5xc_api_token
  f5xc_api_url          = var.f5xc_api_url
  f5xc_aws_vpc_az_nodes = {
    node0 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.0/26",
      f5xc_aws_vpc_az_name    = format("%s%s", var.f5xc_aws_region, "a")
    },
    node1 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.64/26",
      f5xc_aws_vpc_az_name    = format("%s%s", var.f5xc_aws_region, "b")
    },
    node2 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.128/26",
      f5xc_aws_vpc_az_name    = format("%s%s", var.f5xc_aws_region, "c")
    }
  }
  f5xc_ce_gateway_type   = "ingress_gateway"
  f5xc_namespace         = var.f5xc_namespace
  f5xc_tenant            = var.f5xc_tenant
  f5xc_token_name        = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_aws_region        = var.f5xc_aws_region
  f5xc_cluster_latitude  = -73.935242
  f5xc_cluster_longitude = 40.730610
  f5xc_cluster_name      = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_cluster_labels    = { "ves.io/fleet" : format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix) }
  ssh_public_key         = file(var.ssh_public_key_file)
  providers              = {
    aws      = aws.default
    volterra = volterra.default
  }
}

output "aws_ce" {
  value = module.aws_ce
}
```

## AWS Cloud CE Multi Node Multi NIC different AZ module usage example

```hcl
module "aws_ce" {
  source                = "./modules/f5xc/ce/aws"
  owner_tag             = var.owner
  has_public_ip         = true
  is_sensitive          = false
  aws_vpc_cidr_block    = "192.168.0.0/20"
  f5xc_api_token        = var.f5xc_api_token
  f5xc_api_url          = var.f5xc_api_url
  f5xc_aws_vpc_az_nodes = {
    node0 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.0/26",
      f5xc_aws_vpc_sli_subnet = "192.168.1.0/26",
      f5xc_aws_vpc_az_name    = format("%s%s", var.f5xc_aws_region, "a")
    },
    node1 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.64/26",
      f5xc_aws_vpc_sli_subnet = "192.168.1.64/26",
      f5xc_aws_vpc_az_name    = format("%s%s", var.f5xc_aws_region, "b")
    },
    node2 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.128/26",
      f5xc_aws_vpc_sli_subnet = "192.168.1.128/26",
      f5xc_aws_vpc_az_name    = format("%s%s", var.f5xc_aws_region, "c")
    }
  }
  f5xc_ce_gateway_type   = "ingress_egress_gateway"
  f5xc_namespace         = var.f5xc_namespace
  f5xc_tenant            = var.f5xc_tenant
  f5xc_token_name        = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_aws_region        = var.f5xc_aws_region
  f5xc_cluster_latitude  = -73.935242
  f5xc_cluster_longitude = 40.730610
  f5xc_cluster_name      = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_cluster_labels    = { "ves.io/fleet" : format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix) }
  ssh_public_key         = file(var.ssh_public_key_file)
  providers              = {
    aws      = aws.default
    volterra = volterra.default
  }
}

output "aws_ce" {
  value = module.aws_ce
}
```