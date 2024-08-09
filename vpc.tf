provider "aws" {
    region = "eu-west-1"
}

variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}
# hen we create a variable for vpc_cidr_block to set the range of IP address that a resource will use. 
data "aws_availability_zones" "azs" {}

module "myapp-vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version  =  "5.7.0"
  # attributes to create VPC for Eks cluster

  name = "myapp-vpc"
  cidr = var.vpc_cidr_block    
  private_subnets = var.private_subnet_cidr_blocks 
  public_subnets = var.public_subnet_cidr_blocks 
  azs = data.aws_availability_zones.azs.names

  enable_nat_gateway = true 
  single_nat_gateway = true 
  enable_dns_hostnames = true 

  tags = {
    "kubernetes.io/cluster/my-app-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-app-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                  = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-app-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"         = 1
  }
}

