#!/bin/bash

# Create .ssh directory if it doesn't exist
mkdir -p .ssh

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f .ssh/bastion_key -N "" -C "bastion@azure"

# Set proper permissions
chmod 600 .ssh/bastion_key
chmod 644 .ssh/bastion_key.pub

echo "SSH key pair generated:"
echo "Private key: .ssh/bastion_key"
echo "Public key:  .ssh/bastion_key.pub"

# Create terraform.tfvars with the SSH public key path
echo "ssh_public_key_path = \".ssh/bastion_key.pub\"" > terraform.tfvars

echo "terraform.tfvars file created with SSH public key path"

echo "SSH into the bastion host: ssh -i .ssh/bastion_key azureuser@[YOUR_IP]"
echo ""