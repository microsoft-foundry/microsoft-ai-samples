#!/usr/bin/env bash
# Delete everything infra/setup.sh created, after you confirm.
#
#   bash infra/teardown.sh
#
# Deletes the resource group, then purges the soft-deleted Foundry resource so its name can be reused.
set -euo pipefail

INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$(dirname "$INFRA_DIR")/.env"

read_env() { [[ -f "$ENV_FILE" ]] && grep -E "^$1=" "$ENV_FILE" | tail -1 | cut -d= -f2- || true; }

RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-$(read_env AZURE_RESOURCE_GROUP)}"
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-mai-multimodal-product-launch}"
LOCATION="${AZURE_LOCATION:-$(read_env AZURE_LOCATION)}"
ACCOUNT_NAME="$(read_env FOUNDRY_ACCOUNT_NAME)"

if ! az account show >/dev/null 2>&1; then
  echo "⚠️  Not signed in. Run: az login --use-device-code   then run this script again."
  exit 1
fi

if [[ "$(az group exists --name "$RESOURCE_GROUP")" != "true" ]]; then
  echo "Nothing to delete: resource group $RESOURCE_GROUP doesn't exist."
  exit 0
fi

TAG="$(az group show --name "$RESOURCE_GROUP" --query "tags.workshop" -o tsv)"
if [[ "$TAG" != "mai-multimodal-product-launch" ]]; then
  echo "⚠️  $RESOURCE_GROUP isn't tagged workshop=mai-multimodal-product-launch, so this script won't delete it."
  exit 1
fi

echo "This permanently deletes resource group $RESOURCE_GROUP and everything in it:"
az resource list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, type:type}" -o table
echo
read -r -p "Type the resource group name to confirm: " CONFIRM
if [[ "$CONFIRM" != "$RESOURCE_GROUP" ]]; then
  echo "Names don't match. Nothing was deleted."
  exit 1
fi

echo "==> Deleting $RESOURCE_GROUP (a few minutes)"
az group delete --name "$RESOURCE_GROUP" --yes

if [[ -n "$ACCOUNT_NAME" && -n "$LOCATION" ]]; then
  echo "==> Purging the soft-deleted Foundry resource $ACCOUNT_NAME"
  az cognitiveservices account purge --name "$ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" \
    || echo "    Nothing to purge, or already purged."
fi

echo "✅ Done. Your .env still has the old settings; run infra/setup.sh to deploy again."
