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

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
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