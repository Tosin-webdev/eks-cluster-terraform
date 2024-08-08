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


# resource "aws_iam_role" "eks_admin_role" {
#   name = "eks-admin-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_admin_policy" {
#   role       = aws_iam_role.eks_admin_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }

# resource "aws_iam_role_policy_attachment" "eks_admin_worker_node_policy" {
#   role       = aws_iam_role.eks_admin_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

