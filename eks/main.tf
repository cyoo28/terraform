resource "aws_eks_cluster" "test_cluster" {
  name = "web-platform-cluster"
  # Don't include version parameter so that version=latest
  role_arn = "arn:aws:iam::026090555438:role/eks-cluster-role"
  bootstrap_self_managed_addons = false
  upgrade_policy {
    support_type = "STANDARD"
  }
  access_config {
    bootstrap_cluster_creator_admin_permissions = true
    authentication_mode = "API"
  }
  zonal_shift_config {
    enabled = false
  }
  vpc_config {
    endpoint_private_access   = true
    endpoint_public_access    = false
    public_access_cidrs       = []
    security_group_ids        = []
    subnet_ids                = [
        "subnet-00b5b033db01ab4cb",
        "subnet-0143a61d78c69fdaf",
        "subnet-03d93b0775588b7c1",
        "subnet-07e44b3cb81f451e0",
    ]
  }
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
  tags = {
    "CreateBy"    = "console"
    "Environment" = "prod"
    "ManagedBy"   = "EKS"
    "Owner"       = "charles.yoo"
    "Project"     = "webapp"
  }
  tags_all = {
    "CreateBy"    = "console"
    "Environment" = "prod"
    "ManagedBy"   = "EKS"
    "Owner"       = "charles.yoo"
    "Project"     = "webapp"
  }
}