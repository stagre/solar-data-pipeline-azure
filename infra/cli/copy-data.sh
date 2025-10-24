
#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "./infra/cli/azure-credentials.env" ]; then
  echo "❌ azure-credentials.env not found. Please copy azure-credentials.example.env and fill it in." >&2
  exit 1
fi

source ./infra/cli/azure-credentials.env

# 1) Get account key 
ACCOUNT_KEY=$(az storage account keys list \
  --account-name $SA --resource-group "$RG" \
  --query "[0].value" -o tsv)

echo "ACCOUNT_KEY=$ACCOUNT_KEY"

# 2) Create a short-lived SAS for the raw container (1 hour)
SAS=$(az storage container generate-sas \
  --account-name "$SA" --account-key "$ACCOUNT_KEY" \
  --name raw --permissions acdlrw \
  --expiry "$(date -u -v+1H '+%Y-%m-%dT%H:%MZ')" -o tsv)

# 3) Upload everything under data-ingestion/data/raw recursively,
#    preserving the hive structure: year=2025/ month=01, month=02, ...
azcopy copy \
  "data-ingestion/data/raw/*" \
  "https://$SA.dfs.core.windows.net/raw/solar?$SAS" \
  --recursive=true