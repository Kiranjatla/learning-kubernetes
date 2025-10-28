#!/usr/bin/env bash
# ------------------------------------------------------------
# setup.sh – Fully automated Minikube on AWS setup
# Works with: terraform.tf, Makefile, delete.sh
# ------------------------------------------------------------

set -euo pipefail

echo "Minikube on AWS – Setup Script"
echo "================================="

# ---------- 1. Prompt for Hosted Zone ----------
read -rp "Enter DNS Hosted Zone Name (e.g. mylab.example.com): " hname
if [[ -z "$hname" ]]; then
  echo "Error: Hosted zone cannot be empty."
  exit 1
fi
export TF_VAR_HOSTED_ZONE="${hname}"
echo "Using Hosted Zone: $hname"

# ---------- 2. Generate Dedicated SSH Key ----------
KEY_PATH="${HOME}/.ssh/minikube_key"
PUB_KEY_PATH="${KEY_PATH}.pub"

if [[ ! -f "${KEY_PATH}" ]]; then
  echo "Generating new SSH key pair: ${KEY_PATH}"
  ssh-keygen -t ed25519 -C "minikube-$(date +%s)" -f "${KEY_PATH}" -N "" >/dev/null
  echo "SSH key created: ${KEY_PATH}"
else
  echo "Using existing SSH key: ${KEY_PATH}"
fi

# Export for Terraform
export TF_VAR_ssh_public_key="${PUB_KEY_PATH}"

# ---------- 3. Install Tools ----------
echo "Installing Terraform and kubectl..."

# Terraform
curl -fsSL https://raw.githubusercontent.com/linuxautomations/labautomation/master/tools/terraform/install.sh | sudo bash

# kubectl + other k8s tools
curl -fsSL https://raw.githubusercontent.com/linuxautomations/labautomation/master/tools/k8-client-stack/install.sh | sudo bash

# Create kube dir
mkdir -p ~/.kube

# ---------- 4. Terraform Apply ----------
echo "Initializing and applying Terraform..."

rm -rf .terraform* .terraform.lock.hcl
terraform init -upgrade

echo "Creating Minikube cluster... (this takes 5–8 minutes)"
terraform apply -auto-approve

# ---------- 5. Final Output ----------
MINIKUBE_IP=$(terraform output -raw MINIKUBE_IP 2>/dev/null || echo "UNKNOWN")

echo ""
echo "SUCCESS! Cluster is ready."
echo "========================================"
echo "SSH to node:"
echo "  ssh -i ${KEY_PATH} centos@${MINIKUBE_IP}"
echo ""
echo "To use kubectl:"
echo "  make kubeconfig"
echo "  kubectl get nodes"
echo ""
echo "To destroy:"
echo "  make delete"
echo "========================================"