terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name_prefix = "url-shortener-${var.environment}"
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = local.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "alb" {
  source = "../../modules/alb"

  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.vpc.alb_sg_id
}

module "ec2" {
  source = "../../modules/ec2"

  name_prefix        = local.name_prefix
  aws_region         = var.aws_region
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.vpc.app_sg_id
  target_group_arn   = module.alb.target_group_arn
  instance_type      = "t3.micro"
  min_size           = 1
  max_size           = 2
  desired_capacity   = 1
}

module "rds" {
  source = "../../modules/rds"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.vpc.rds_sg_id
  instance_class     = "db.t3.micro"
  db_password        = var.db_password
}