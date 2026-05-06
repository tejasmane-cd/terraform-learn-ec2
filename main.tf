terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "my-terraform-state-0001232324"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  allowed_ssh_cidr   = var.allowed_ssh_cidr
}

module "ec2" {
  source = "./modules/ec2"

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  name                   = "${local.name_prefix}-server"
  subnet_id              = module.vpc.public_subnet_id
  vpc_security_group_ids = [module.vpc.ec2_security_group_id]
}
