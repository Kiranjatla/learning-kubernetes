#!/usr/bin/env bash
# ------------------------------------------------------------
# delete.sh – Destroy cluster without prompts
# ------------------------------------------------------------

set -euo pipefail

echo "Destroying Minikube cluster..."

# Auto-set required variables
export TF_VAR_HOSTED_ZONE="vitingousa.live"
export TF_VAR_ssh_public_key="${HOME}/.ssh/minikube_key.pub"

# Destroy everything
terraform init -upgrade
terraform destroy -auto-approve

# Clean local state
rm -f ~/.kube/config

echo "Cluster destroyed and local kubeconfig removed."