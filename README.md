## Provision an EKS cluster using terraform

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

step 2 - Configure the variables

create a file called `terraform.tfvars` and add the following code:

```
vpc_cidr_block = "10.0.0.0/16"
private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

````

Step 3 - Eks cluster
create a file called `eks-cluster` to configure the EKS

```
module "eks"{
    source          = "terraform-aws-modules/eks/aws"
    version         = "20.8.4"
    # Instert the 7 required variables

    cluster_name    = "my-app-eks-cluster"
    cluster_version = "1.30"

    cluster_endpoint_public_access  = true

    subnet_ids      = module.myapp-vpc.private_subnets
    vpc_id          = module.myapp-vpc.vpc_id

    tags = {
        environment = "development"
        application = "myapp"
    }
    
    eks_managed_node_group_defaults = {
        ami_type               = "AL2_x86_64"
        instance_types         = ["t3.medium"]
    }

  eks_managed_node_groups = {

    node_group = {
      min_size     = 3
      max_size     = 6
      desired_size = 3
    }
  }
}
```
Here the terrafomr configuration defines Amazon EKS cluster using a module from the terraform AWS module library. I has the name `my-app-eks-cluster.`. The `cluster_endpoint_public_access  = true
` allows the API server endpoint to be accessible from the internet. Then the subnet_ids with the vpc id are being referenced from the VPC module we created earlier. the `eks_managed_node_group_defaults` specifies the default configuration for EKS-managed node groups. I also set the ami_type to amazon linux 2. and the instance type to t3.medium
Lastly the node group consist of:
- `min_size`: The minimum number of instances in the node group. Here it's set to 3.
- `max_size`: The maximum number of instances in the node group. Here it's set to 6.
- `desired_size`: The desired number of instances in the node group. Here it's set to 3.


 
Step 4 provision your infrastructure
To provision your infrastructure Run the command below
```
 terraform init
```
```
terraform plan
```
```
terraform apply --auto-approve
```

result:

![Screenshot from 2024-08-08 06-42-56](https://github.com/user-attachments/assets/955ceefe-bada-4b70-a97b-94b4d6cfeaf7)


The cluster

![Screenshot from 2024-08-08 06-44-05](https://github.com/user-attachments/assets/31d7f8a7-f5c0-4aef-8d94-3d437ddc1133)



### Step 5 configure IAM access entry


Go to EKS > CLusters > my-app-eks-cluster > Select create access entry



![Untitled Diagram drawio](https://github.com/user-attachments/assets/1da1e200-3fda-4504-b43f-44bf504909e4)

Configure IAM access entry
![Screenshot from 2024-08-08 21-23-09](https://github.com/user-attachments/assets/758afc25-1f8a-4c6a-aa06-b9b54120e828)

Review and create

![Screenshot from 2024-08-08 21-23-25](https://github.com/user-attachments/assets/bfeee368-cbaa-49a5-a447-b42eeb24ee45)


### Step 6 - Configure kubectl to interact with AMAZON EKS Cluster:

To configure `kubectl` with EKS cluster run the ocmmand below:
```
aws eks update-kubeconfig --name my-app-eks-cluster --region eu-west-1
```

check the running nodes
```
kubectl get nodes
```
![AWSone](https://github.com/user-attachments/assets/5202363f-4ed3-4428-95ff-79637158f0ad)

### Step 7 - Deploy nginx





