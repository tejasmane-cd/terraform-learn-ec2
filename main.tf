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

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  allowed_ssh_cidr    = var.allowed_ssh_cidr
}

module "alb" {
  source = "./modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.vpc.alb_security_group_id]
}

module "ec2" {
  source = "./modules/ec2"

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  name                   = "${local.name_prefix}-server"
  subnet_ids             = module.vpc.public_subnet_ids
  vpc_security_group_ids = [module.vpc.ec2_security_group_id]
  target_group_arns      = [module.alb.target_group_arn]
  desired_capacity       = 2
  min_size               = 2
  max_size               = 3
}
