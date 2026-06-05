#!/bin/sh
set -e

VAULT_ADDR="${VAULT_ADDR:-http://vault:8200}"
export VAULT_ADDR

echo "============================================"
echo " Vault Initialization Script"
echo "============================================"

# ---- Wait for Vault health endpoint ----
echo "Waiting for Vault to become healthy..."
RETRIES=30
COUNT=0
until vault status > /dev/null 2>&1; do
  COUNT=$((COUNT + 1))
  if [ "$COUNT" -ge "$RETRIES" ]; then
    echo "ERROR: Vault did not become healthy after $RETRIES attempts"
    exit 1
  fi
  echo "  Vault not ready yet (attempt $COUNT/$RETRIES)..."
  sleep 2
done
echo "Vault is healthy!"

# ---- Authenticate ----
echo "Authenticating with root token..."
vault login root

# ---- Enable KV v2 secrets engine ----
echo "Enabling KV v2 secrets engine at secret/..."
vault secrets enable -path=secret kv-v2 2>/dev/null || echo "  (already enabled)"

# ---- Create secrets from environment variables (never hardcoded) ----
echo "Creating secrets in vault..."
vault kv put secret/devops \
  db_password="${DB_PASSWORD}" \
  api_key="${API_KEY}"

# ---- Verify secrets exist ----
echo ""
echo "Verifying secrets..."
vault kv get secret/devops

echo ""
echo "============================================"
echo " Vault initialization completed successfully!"
echo "============================================"
