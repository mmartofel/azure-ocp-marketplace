#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Prevent interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Update and upgrade system packages with non-interactive options
log "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef"

# Install needrestart to handle daemon restarts
sudo apt-get install -y needrestart

# Automatically restart services that need restarting
log "Restarting outdated services..."
sudo needrestart -r a

# Install core prerequisites
log "Installing core prerequisites..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    apt-transport-https \
    lsb-release \
    gnupg \
    wget \
    unzip \
    software-properties-common \
    jq \
    build-essential

# Install Git
log "Installing/Updating Git..."
sudo apt-get install -y git

# Install Azure CLI
log "Installing Azure CLI..."
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo needrestart -r a
sudo apt-get install -y azure-cli

# Install Terraform
log "Installing Terraform..."
# Fetch the latest version
TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
log "Latest Terraform version: $TERRAFORM_VERSION"

# Download and install Terraform
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install OpenShift CLI (oc)
log "Installing OpenShift CLI..."
wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
mkdir -p oc_install
tar xzf openshift-client-linux.tar.gz -C oc_install
sudo mv oc_install/oc /usr/local/bin/
sudo mv oc_install/kubectl /usr/local/bin/
rm openshift-client-linux.tar.gz
rm -rf oc_install

# Install OpenShift Installer
log "Installing OpenShift Installer..."
wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz
mkdir -p openshift_install
tar xzf openshift-install-linux.tar.gz -C openshift_install
sudo mv openshift_install/openshift-install .
rm openshift-install-linux.tar.gz
rm -rf openshift_install

# Verify installations
log "Verifying installed tools..."
echo "Git version:"
git --version

echo "JQ version:"
jq --version

echo "Azure CLI version:"
az --version | grep azure-cli

echo "Terraform version:"
terraform version

echo "OpenShift CLI version:"
oc version

echo "OpenShift Installer version:"
./openshift-install version

log "Installation of tools complete!"

# Optional: Add helpful message about next steps
echo "
Next steps:
1. Use helper script 01_azure_env.sh to login to Azure
2. Install OpenShift cluster with 04_ocp_install.sh
"