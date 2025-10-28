# ------------------------------------------------------------
# Makefile – Minikube on AWS (terraform-aws-minikube)
# Works with: setup.sh, delete.sh, terraform.tf
# ------------------------------------------------------------

.PHONY: help setup kubeconfig delete destroy

# --- Paths & Variables ---
SSH_KEY     := ${HOME}/.ssh/minikube_key
SSH_USER    := centos
MINIKUBE_IP != terraform output -raw MINIKUBE_IP 2>/dev/null || echo ""

# --- Help ---
help: ## Show this help menu
	@echo "Minikube on AWS – Available Commands\n"
	@echo "Usage: make <command>\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

# --- Full Setup ---
setup: ## Run setup.sh → creates key, installs tools, applies Terraform
	@echo "Starting full cluster setup..."
	@./setup.sh

# --- Fetch kubeconfig ---
kubeconfig: ## Copy kubeconfig from Minikube node (waits up to 5 min)
	@if [ -z "$(MINIKUBE_IP)" ] || [ "$(MINIKUBE_IP)" = "UNKNOWN" ]; then \
	  echo "Error: Cluster not found. Run 'make setup' first."; \
	  exit 1; \
	fi
	@echo "Waiting for kubeconfig on $(MINIKUBE_IP) (max 5 min)..."
	@timeout 300 bash -c 'until ssh -q -o StrictHostKeyChecking=no -i $(SSH_KEY) $(SSH_USER)@$(MINIKUBE_IP) test -f /home/$(SSH_USER)/kubeconfig; do \
	  printf "."; sleep 5; \
	done' || (echo "\nError: kubeconfig not ready in time." && exit 1)
	@echo "\nCopying kubeconfig..."
	@mkdir -p ~/.kube
	@scp -q -o StrictHostKeyChecking=no -i $(SSH_KEY) $(SSH_USER)@$(MINIKUBE_IP):/home/$(SSH_USER)/kubeconfig ~/.kube/config
	@echo "kubeconfig ready! Test with: kubectl get nodes"

# --- Destroy Cluster ---
delete destroy: ## Destroy cluster and clean up
	@echo "Destroying cluster..."
	@./delete.sh

# --- Optional: Test Connection ---
ssh: ## SSH into the Minikube node
	@if [ -z "$(MINIKUBE_IP)" ] || [ "$(MINIKUBE_IP)" = "UNKNOWN" ]; then \
	  echo "Error: No IP. Run 'make setup' first."; \
	  exit 1; \
	fi
	@ssh -i $(SSH_KEY) $(SSH_USER)@$(MINIKUBE_IP)

# --- Optional: Show Outputs ---
outputs: ## Show Terraform outputs
	@terraform output