#!/usr/bin/env bash
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing the latest Azure CLI"
# The base image's Yarn apt source has an expired key and breaks apt-get update; Node already bundles Yarn.
sudo rm -f /etc/apt/sources.list.d/yarn.list
# Adds Microsoft's apt repo, so distro-packaged versions are replaced.
curl -fsSL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "==> Installing FFmpeg (audio conversion for the speech samples)"
sudo apt-get update
sudo apt-get install -y --no-install-recommends ffmpeg

echo "==> Installing the latest Azure Developer CLI"
curl -fsSL https://aka.ms/install-azd.sh | bash

echo "==> Creating the shared Python environment"
python3 -m venv "$REPO_ROOT/.venv"
"$REPO_ROOT/.venv/bin/python" -m pip install --upgrade pip
"$REPO_ROOT/.venv/bin/python" -m pip install ipykernel

shopt -s nullglob
for req in "$REPO_ROOT"/workshops/*/requirements.txt "$REPO_ROOT"/samples/*/requirements.txt; do
  echo "==> Installing ${req#"$REPO_ROOT"/}"
  "$REPO_ROOT/.venv/bin/python" -m pip install -r "$req"
done

# Git-ignored folders where the speech samples expect your own recordings.
for sample in "$REPO_ROOT"/samples/*/; do
  [[ -f "$sample/.env.example" ]] && mkdir -p "$sample/samples"
done

echo "==> Versions"
az version --query '"azure-cli"' -o tsv
azd version
"$REPO_ROOT/.venv/bin/python" --version
node --version
ffmpeg -version | head -n 1
