resource "aws_eks_cluster" "main" {
  name     = "fider-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
    aws_subnet.private_b.id, ]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "fider-eks"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]


  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
  #checkov:skip=CKV_AWS_58:EKS 1.28+ provides default encryption with an AWS-owned KMS key
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "fider-workers"
  node_role_arn   = aws_iam_role.eks_nodegroup.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = {
    Name      = "fider-workers"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_nodegroup, aws_iam_role_policy_attachment.eks_nodegroup_ecr]


}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_pod_identity_association" "vpc_cni" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "aws-node"
  role_arn        = aws_iam_role.vpc_cni.arn

  depends_on = [aws_iam_role_policy_attachment.vpc_cni]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
}