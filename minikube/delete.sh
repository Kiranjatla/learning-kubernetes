#!/usr/bin/env bash
# delete.sh – Silent destroy (no prompts)
set -euo pipefail

echo "Destroying Minikube cluster..."

# Auto-fill variables
export TF_VAR_HOSTED_ZONE="vitingousa.live"
export TF_VAR_ssh_public_key="${HOME}/.ssh/minikube_key.pub"

terraform init -upgrade
terraform destroy -auto-approve

rm -f ~/.kube/config
echo "Cluster destroyed."