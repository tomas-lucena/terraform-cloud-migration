terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.78.0"
    }
  }
  backend "s3" {
    key    = "terraform/tfstate.tfstate"
    bucket = "playground-tms"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "pessoal"

  default_tags {
    tags = {
      Environment = "Dev"
      Owner       = "Tomás"
    }
  }
}

module "vpc" {
  source = "./1.vpc"

  base_cidr_block = var.base_cidr_block

}

module "security" {
  source = "./2.security"

  vpc_id          = module.vpc.vpc_id
  base_cidr_block = var.base_cidr_block

  depends_on = [module.vpc]
}


module "network" {
  source = "./3.network"

  region                 = var.region
  vpc_id                 = module.vpc.vpc_id
  base_cidr_block        = var.base_cidr_block
  number_private_subnets = max(var.number_private_subnets, 2)
  number_public_subnets  = max(var.number_public_subnets, 2)
  sg_application_id      = module.security.sg_application_id

  depends_on = [module.security]
}

module "route53_zone" {
  source = "./4.route53_zone"

  domain = var.domain
}

module "acm" {
  source = "./5.acm"

  domain_zone_id = module.route53_zone.domain_zone_id

  depends_on = [module.route53_zone]
}



module "database" {
  source = "./6.database"

  sg_database_id     = module.security.sg_database_id
  private_subnets_id = module.network.private_subnets_id

  depends_on = [module.security]
}

module "load_balancer" {
  source = "./7.load_balancer"

  public_subnets_id = module.network.public_subnets_id
  sg_loadbalance_id = module.security.sg_loadbalance_id
  vpc_id            = module.vpc.vpc_id
  domain_cert_arn   = module.acm.domain_cert_arn

  depends_on = [module.security, module.acm]
}


module "dns" {
  source = "./8.dns"

  domain_zone_id   = module.route53_zone.domain_zone_id
  database_address = module.database.database_address
  alb_dns_name     = module.load_balancer.alb_dns_name
  alb_zone_id      = module.load_balancer.alb_zone_id
  domain           = var.domain

  depends_on = [module.load_balancer, module.database]

}

module "application" {
  source = "./9.application"

  ami_id              = var.ami_id
  vpc_id              = module.vpc.vpc_id
  private_subnets_id  = module.network.private_subnets_id
  sg_application_id   = module.security.sg_application_id
  lb_target_group_arn = module.load_balancer.lb_target_group_arn

  depends_on = [module.dns]
}

