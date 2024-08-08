## Provision en EKS cluster using terraform

In this porject we will create an vpc in eks cluster

Pre-requisites

- aws cli configured
- Ensure terraform is installed
- Create IAM role on AWS
- install aws-iam-authenticator (authenticate with EKS cluster)

  Step 1 - Create a file `vpc.tf` and isnert the following code

  ```
  provider "aws" {
    region = "eu-west-1"
}

```
variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

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
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                  = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"         = 1
  }
}
```
Here I configured the provider aws to the eu-west-1 region. I also created variables `vpc_cidr_block` private `private_subnet_cidr_blocks` `public_subnet_cidr_blocks`. 
Then the `data` block is used to fetch information about the availability zone in a specified AWS region. Next is the module `myapp-vpc` which will create a VPC for th EKS cluster it contains both the private and public subnets. which we are referencing from the `terraform.tfvars`. Also enabled NAT gateway which provides outbond internet access for resources in a private subnet while keeping them protected from internet and also enabled DNS hostnames.Next we have a tag which contains the VPC and subnets for EKS integration and load balancers   




  
