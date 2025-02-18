
# Accept TERMS to use Red Hat image
az vm image terms accept --urn RedHat:rh-ocp-worker:rh-ocp-worker:4.17.2024100419 -o table

# Create resource group which will be used to install cluster in
az group delete --resource-group zenek_rg --yes
az group create --name zenek_rg --location eastus --output table
az group list --output table

# Remove existing config directory, create it again and copy install-config.yaml into it as a new cluster template
rm -rf ./config
mkdir ./config
cp install-config.yaml ./config

# Install Red Hat OpenShift cluster
./openshift-install create cluster --dir ./config # --log-level debug

