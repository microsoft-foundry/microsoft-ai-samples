#!/usr/bin/env bash
# Deploy the Azure resources for this workshop and write ../.env.
#
#   bash infra/setup.sh                    # defaults: eastus, rg-mai-multimodal-product-launch
#   AZURE_LOCATION=swedencentral AZURE_RESOURCE_GROUP=rg-my-launch bash infra/setup.sh
#
# Creates: a Microsoft Foundry resource + project, MAI-Image-2.6 and MAI-Image-2.6-Flash
# deployments, and the Foundry User role for you. Voice and transcription need no deployment.
set -euo pipefail

INFRA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSHOP_DIR="$(dirname "$INFRA_DIR")"
ENV_FILE="$WORKSHOP_DIR/.env"

# eastus offers every MAI model used here. Other regions may lack voices or image models.
LOCATION="${AZURE_LOCATION:-eastus}"
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-rg-mai-multimodal-product-launch}"
IMAGE_MODELS=("MAI-Image-2.6" "MAI-Image-2.6-Flash")

set_env() {
  local key="$1" value="$2"
  touch "$ENV_FILE"
  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

echo "==> Checking Azure sign-in"
if ! az account show >/dev/null 2>&1; then
  echo "⚠️  Not signed in. Run: az login --use-device-code   then run this script again."
  exit 1
fi
SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
echo "    Subscription: $(az account show --query name -o tsv)"

USER_TYPE="$(az account show --query user.type -o tsv)"
if [[ "$USER_TYPE" == "servicePrincipal" ]]; then
  PRINCIPAL_ID="$(az ad sp show --id "$(az account show --query user.name -o tsv)" --query id -o tsv)"
  PRINCIPAL_TYPE="ServicePrincipal"
else
  PRINCIPAL_ID="$(az ad signed-in-user show --query id -o tsv)"
  PRINCIPAL_TYPE="User"
fi

echo "==> Checking which MAI image models $LOCATION offers"
AVAILABLE="$(az rest --method get \
  --uri "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/providers/Microsoft.CognitiveServices/locations/${LOCATION}/models?api-version=2025-06-01" \
  --query "value[?model.format=='Microsoft'].model.name" -o tsv 2>/dev/null || true)"
DEPLOY_IMAGES=true
for model in "${IMAGE_MODELS[@]}"; do
  if ! grep -qx "$model" <<<"$AVAILABLE"; then
    DEPLOY_IMAGES=false
    echo "⚠️  $model isn't offered in $LOCATION. Skipping image models; notebook 01 will only replay."
    echo "    To run 01 live, use a region that offers it, e.g. AZURE_LOCATION=eastus."
    break
  fi
done
[[ "$DEPLOY_IMAGES" == true ]] && echo "    ✅ ${IMAGE_MODELS[*]}"

echo "==> Creating resource group $RESOURCE_GROUP in $LOCATION"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" \
  --tags workshop=mai-multimodal-product-launch --output none

echo "==> Deploying the Foundry resource and project (a few minutes)"
OUTPUTS="$(az deployment group create \
  --name mai-multimodal-product-launch \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$INFRA_DIR/main.bicep" \
  --parameters location="$LOCATION" principalId="$PRINCIPAL_ID" principalType="$PRINCIPAL_TYPE" deployImageModels="$DEPLOY_IMAGES" \
  --query properties.outputs -o json)"

output() { python3 -c "import json,sys; print(json.load(sys.stdin)['$1']['value'])" <<<"$OUTPUTS"; }

echo "==> Writing $ENV_FILE"
[[ -f "$ENV_FILE" ]] || cp "$WORKSHOP_DIR/.env.example" "$ENV_FILE"
set_env AZURE_LOCATION "$LOCATION"
set_env AZURE_RESOURCE_GROUP "$RESOURCE_GROUP"
set_env FOUNDRY_ACCOUNT_NAME "$(output accountName)"
set_env FOUNDRY_PROJECT_ENDPOINT "$(output projectEndpoint)"
if [[ "$DEPLOY_IMAGES" == true ]]; then
  set_env MODEL_IMAGE_HERO "${IMAGE_MODELS[0]}"
  set_env MODEL_IMAGE_BULK "${IMAGE_MODELS[1]}"
  set_env RATE_LIMIT_RPM 5
fi

echo
echo "✅ Done. Resources are in $RESOURCE_GROUP ($LOCATION)."
echo "   New role assignments can take a few minutes to apply. If the first live call returns 401 or 403, wait and retry."
echo "   Switch a notebook to live with DEMO_MODE=\"live\" in its mode cell, or DEMO_MODE=live in .env."
echo "   When you're finished: bash infra/teardown.sh"
