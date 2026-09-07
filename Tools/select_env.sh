#!/bin/bash
# Select the backend environment (dev/test) for local Debug/QA builds.
# Records the choice in amplify_configs/backend_env.txt; the backendEnv build
# phase bundles amplify_configs/<env>/amplifyconfiguration.json accordingly.
# Release builds ignore this file and always use test.
#
# Usage: ./Tools/select_env.sh dev|test
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$ROOT/amplify_configs"
ENV_NAME="${1:-}"

if [[ "$ENV_NAME" != "dev" && "$ENV_NAME" != "test" ]]; then
  echo "Usage: $0 dev|test" >&2
  exit 1
fi

if [[ ! -f "$CONFIG_DIR/$ENV_NAME/amplifyconfiguration.json" ]]; then
  echo "❌ Missing $CONFIG_DIR/$ENV_NAME/amplifyconfiguration.json" >&2
  echo "   Run 'update_amplify.sh -e $ENV_NAME ...' or copy the config from a teammate (see README)." >&2
  exit 1
fi

printf '%s\n' "$ENV_NAME" > "$CONFIG_DIR/backend_env.txt"
echo "✅ Backend environment set to '$ENV_NAME'. Rebuild the app to apply."
