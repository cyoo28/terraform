resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.test_cluster.name
  addon_name   = "vpc-cni"
  pod_identity_association {
    role_arn        = "arn:aws:iam::026090555438:role/AmazonEKSPodIdentityAmazonVPCCNIRole"
    service_account = "aws-node"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.test_cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.test_cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "flow_monitor" {
  cluster_name = aws_eks_cluster.test_cluster.name
  addon_name   = "aws-network-flow-monitoring-agent"
  pod_identity_association {
    role_arn        = "arn:aws:iam::026090555438:role/AmazonEKSPodIdentityAWSNetworkFlowMonitorAgentRole"
    service_account = "aws-network-flow-monitor-agent-service-account"
  }
}

# put in guardduty when i get back
#resource "aws_eks_addon" "guardduty" {
#  cluster_name = aws_eks_cluster.test_cluster.name
#  addon_name   = "aws-guardduty-runtime-monitoring"
#}

resource "aws_eks_addon" "cloudwatch" {
  cluster_name = aws_eks_cluster.test_cluster.name
  addon_name   = "amazon-cloudwatch-observability"
  pod_identity_association {
    role_arn        = "arn:aws:iam::026090555438:role/AmazonEKSPodIdentityAmazonCloudWatchObservabilityRole"
    service_account = "cloudwatch-agent"
  }
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.test_cluster.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_addon" "external_dns" {
  cluster_name = aws_eks_cluster.test_cluster.name
  addon_name   = "external-dns"
  pod_identity_association {
    role_arn        = "arn:aws:iam::026090555438:role/AmazonEKSPodIdentityExternalDNSRole"
    service_account = "external-dns"
    }
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name = aws_eks_cluster.test_cluster.name
  addon_name   = "metrics-server"
}