provider "aws" {
  region = var.region
}
resource "aws_iam_role" "cluster" {
  name = "rajasurya-final-eks-cluster"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "eks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_eks_cluster" "main" {
  name     = "rajasurya-final-devops"
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version
  vpc_config {
    subnet_ids              = module.cloud.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = [var.web_cidr]
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator"]
  depends_on                = [aws_iam_role_policy_attachment.cluster, aws_cloudwatch_log_group.cluster]
}
resource "aws_iam_role" "node" {
  name = "rajasurya-final-eks-node"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
resource "aws_iam_role_policy_attachment" "node" {
  for_each   = toset(["AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly"])
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "homework-workers-free"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = module.cloud.subnet_ids
  instance_types  = [var.node_instance_type]
  ami_type        = "AL2023_x86_64_STANDARD"
  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_iam_role_policy_attachment.node]
}
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"
  depends_on   = [aws_eks_node_group.main]
}
resource "aws_iam_role" "ebs" {
  name = "rajasurya-final-ebs-csi"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "pods.eks.amazonaws.com" }, Action = ["sts:AssumeRole", "sts:TagSession"] }]
  })
}
resource "aws_iam_role_policy_attachment" "ebs" {
  role       = aws_iam_role.ebs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
resource "aws_eks_addon" "ebs" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"
  depends_on   = [aws_eks_addon.pod_identity, aws_eks_pod_identity_association.ebs]
}
resource "aws_eks_pod_identity_association" "ebs" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs.arn
  depends_on      = [aws_iam_role_policy_attachment.ebs, aws_eks_addon.pod_identity]
}

# A Free-plan-eligible lab worker with encrypted storage.
resource "aws_launch_template" "node" {
  name_prefix = "rajasurya-final-worker-"
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }
}

resource "aws_eks_addon" "metrics" {
  cluster_name  = aws_eks_cluster.main.name
  addon_name    = "metrics-server"
  addon_version = "v0.9.0-eksbuild.11"
  depends_on    = [aws_eks_node_group.main]
}
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/rajasurya-final-devops/cluster"
  retention_in_days = 1
}
