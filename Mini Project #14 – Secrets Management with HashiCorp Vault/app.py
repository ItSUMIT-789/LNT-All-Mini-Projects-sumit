import os
import sys
import time
import logging
import hvac
from flask import Flask, jsonify

# ---------------------------------------------------------------------------
# Logging configuration — all output goes to stdout for Docker log collection
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    stream=sys.stdout,
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# ---------------------------------------------------------------------------
# Vault integration — secrets are NEVER hardcoded
# ---------------------------------------------------------------------------
VAULT_ADDR  = os.environ.get("VAULT_ADDR", "http://127.0.0.1:8200")
VAULT_TOKEN = os.environ.get("VAULT_TOKEN")          # provided via env / GitHub Secret
VAULT_SECRET_PATH = "devops"                          # path under secret/ engine

# In-memory cache populated once at startup
_secrets_cache = {}


def wait_for_vault(addr: str, retries: int = 30, delay: int = 2) -> None:
    """Block until Vault's /v1/sys/health endpoint returns 200."""
    import urllib.request, urllib.error
    url = f"{addr}/v1/sys/health"
    for attempt in range(1, retries + 1):
        try:
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req, timeout=3) as resp:
                if resp.status == 200:
                    logger.info("Vault is healthy (attempt %d/%d)", attempt, retries)
                    return
        except Exception:
            pass
        logger.info("Waiting for Vault to become ready (%d/%d)…", attempt, retries)
        time.sleep(delay)
    logger.error("Vault did not become healthy after %d attempts", retries)
    sys.exit(1)


def fetch_secrets() -> dict:
    """Authenticate to Vault and read secret/devops."""
    if not VAULT_TOKEN:
        logger.warning("VAULT_TOKEN not set — skipping Vault integration")
        return {}

    # Wait until Vault is actually reachable
    wait_for_vault(VAULT_ADDR)

    client = hvac.Client(url=VAULT_ADDR, token=VAULT_TOKEN)

    if not client.is_authenticated():
        logger.error("Vault authentication failed!")
        return {}

    logger.info("Successfully connected to Vault at %s", VAULT_ADDR)

    response = client.secrets.kv.v2.read_secret_version(path=VAULT_SECRET_PATH)
    data = response["data"]["data"]

    logger.info("Successfully retrieved secrets from path: secret/%s", VAULT_SECRET_PATH)
    return data


def mask(value: str) -> str:
    """Return a fully masked representation — never leak real values."""
    return "********"


# ---------------------------------------------------------------------------
# Startup: fetch secrets once and cache them
# ---------------------------------------------------------------------------
try:
    _secrets_cache = fetch_secrets()
    if _secrets_cache:
        logger.info("DB Password: %s", mask(_secrets_cache.get("db_password", "")))
        logger.info("API Key:     %s", mask(_secrets_cache.get("api_key", "")))
except Exception as exc:
    logger.error("Failed to fetch secrets at startup: %s", exc)


# ---------------------------------------------------------------------------
# Flask routes
# ---------------------------------------------------------------------------
@app.route("/")
def home():
    """Landing page confirming secret retrieval status."""
    if _secrets_cache:
        return jsonify({
            "message": "Secret retrieval successful",
            "db_password": mask(_secrets_cache.get("db_password", "")),
            "api_key":     mask(_secrets_cache.get("api_key", "")),
        })
    return jsonify({"message": "Secrets not loaded — check Vault connectivity"}), 503


@app.route("/health")
def health():
    """Health-check endpoint used by Docker HEALTHCHECK."""
    vault_ok = bool(_secrets_cache)
    status_code = 200 if vault_ok else 503
    return jsonify({"status": "UP" if vault_ok else "DOWN", "vault_connected": vault_ok}), status_code


@app.route("/secrets")
def secrets_endpoint():
    """Return masked secrets to prove runtime retrieval from Vault."""
    if not _secrets_cache:
        return jsonify({"error": "Secrets not loaded from Vault"}), 503

    return jsonify({
        "db_password": mask(_secrets_cache.get("db_password", "")),
        "api_key":     mask(_secrets_cache.get("api_key", "")),
        "status":      "Securely retrieved from Vault",
    })


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)