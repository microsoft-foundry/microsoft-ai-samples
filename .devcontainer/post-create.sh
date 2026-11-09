#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing the latest Azure CLI"
# The base image's Yarn apt source has an expired key and breaks apt-get update; Node already bundles Yarn.
sudo rm -f /etc/apt/sources.list.d/yarn.list
# Adds Microsoft's apt repo, so distro-packaged versions are replaced.
curl -fsSL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "==> Installing the latest Azure Developer CLI"
curl -fsSL https://aka.ms/install-azd.sh | bash

echo "==> Creating the shared Python environment"
python3 -m venv "$REPO_ROOT/.venv"
"$REPO_ROOT/.venv/bin/python" -m pip install --upgrade pip
"$REPO_ROOT/.venv/bin/python" -m pip install ipykernel

shopt -s nullglob
for req in "$REPO_ROOT"/workshops/*/requirements.txt; do
  echo "==> Installing ${req#"$REPO_ROOT"/}"
  "$REPO_ROOT/.venv/bin/python" -m pip install -r "$req"
done

echo "==> Versions"
az version --query '"azure-cli"' -o tsv
azd version
"$REPO_ROOT/.venv/bin/python" --version
node --version
