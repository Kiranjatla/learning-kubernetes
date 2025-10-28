terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------------------------
# VPC Module
# ------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "k8s-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Name      = "k8s-vpc"
  }
}

# ------------------------------------------------------------
# AlmaLinux 8 AMI (official CentOS 7 replacement)
# ------------------------------------------------------------
data "aws_ami" "almalinux8" {
  most_recent = true
  owners      = ["amazon"]  # Official AWS

  filter {
    name   = "name"
    values = ["AlmaLinux OS 8.* x86_64*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------
# Minikube Module (creates EC2 + Minikube + kubeconfig)
# ------------------------------------------------------------
module "minikube" {
  source = "github.com/scholzj/terraform-aws-minikube"

  aws_region        = "us-east-1"
  cluster_name      = "minikube"
  aws_instance_type = "t3.medium"
  ssh_public_key    = var.ssh_public_key
  aws_subnet_id     = module.vpc.public_subnets[0]
  ami_image_id = data.aws_ami.almalinux8.id
  hosted_zone       = var.HOSTED_ZONE
  hosted_zone_private = false

  tags = {
    Application = "Minikube"
    Environment = "lab"
  }

  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/heapster.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns.yaml"
  ]
}

# ------------------------------------------------------------
# Variables
# ------------------------------------------------------------
variable "HOSTED_ZONE" {
  description = "Route53 hosted zone name (e.g. mylab.example.com)"
  type        = string
}

variable "ssh_public_key" {
  description = "Path to your public SSH key (e.g. ~/.ssh/minikube_key.pub)"
  type        = string
}

# ------------------------------------------------------------
# Outputs
# ------------------------------------------------------------
output "MINIKUBE_IP" {
  description = "Public IP of the Minikube node"
  value       = module.minikube.public_ip
}

output "SSH_COMMAND" {
  description = "SSH command to connect to the node"
  value       = "ssh -i ${replace(var.ssh_public_key, ".pub", "")} centos@${module.minikube.public_ip}"
}

output "KUBECTL_SETUP" {
  value = <<EOT
mkdir -p ~/.kube
scp -i ~/.ssh/minikube_key centos@${module.minikube.public_ip}:kubeconfig ~/.kube/config
EOT
}

output "KUBECTL_TEST" {
  description = "Test command"
  value       = "kubectl get nodes"
}