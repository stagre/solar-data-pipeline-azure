
#!/usr/bin/env bash
set -euo pipefail

# ---------- CONFIG ----------
# add account info in .env (see azure-credentials.env.example)
if [ ! -f "./infra/cli/azure-credentials.env" ]; then
  echo "❌ azure-credentials.env not found. Please copy azure-credentials.example.env and fill it in." >&2
  exit 1
fi

source ./infra/cli/azure-credentials.env

SUBSCRIPTION="${SUBSCRIPTION:-}"            
RG="${RG:-rg-solar-pipeline-dev}"
LOC="${LOC:-westeurope}"
SA="${SA:-stsolarlakedev$RANDOM}"           
ADF="${ADF:-adf-solar-dev}"
# ----------------------------

az account set --subscription "$SUBSCRIPTION"

az config set extension.use_dynamic_install=yes_without_prompt
az config set extension.dynamic_install_allow_preview=true

# rg
echo "Creating resource group (if not existing)..."
az group create -n "$RG" -l "$LOC" >/dev/null

# storage
echo "Creating ADLS Gen2 storage..."
az storage account create -n "$SA" -g "$RG" -l "$LOC" \
  --sku Standard_LRS --kind StorageV2 --hns true >/dev/null

ACCOUNT_KEY=$(az storage account keys list \
  --account-name "$SA" \
  --resource-group "$RG" \
  --query "[0].value" -o tsv)

echo "Creating lake containers..."
az storage container create --account-name "$SA"  --account-key "$ACCOUNT_KEY" --name raw   >/dev/null
az storage container create --account-name "$SA"  --account-key "$ACCOUNT_KEY" --name silver >/dev/null
az storage container create --account-name "$SA"  --account-key "$ACCOUNT_KEY" --name gold   >/dev/null

# adf
echo "Creating Data Factory..."
az datafactory create -g "$RG" -n "$ADF" -l "$LOC" >/dev/null

echo "Granting ADF managed identity access to storage..."
ADF_MI_PRINCIPAL_ID=$(az datafactory show -g "$RG" -n "$ADF" --query identity.principalId -o tsv)
ST_ID=$(az storage account show -n "$SA" -g "$RG" --query id -o tsv)
az role assignment create \
  --assignee-object-id "$ADF_MI_PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Storage Blob Data Contributor" \
  --scope "$ST_ID" >/dev/null

echo "Done!"
echo "Resource Group: $RG"
echo "Storage:        $SA"
echo "Data Factory:   $ADF"