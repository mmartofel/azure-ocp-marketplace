
az login --service-principal -u $CLIENT_ID -p $PASSWORD --tenant $TENANT
az account set --subscription $SUBSCRIPTION
