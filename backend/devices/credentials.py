"""Helpers for issuing and checking child device credentials."""

import hashlib
import hmac
import secrets

CREDENTIAL_SCHEME = "Device"


def generate_secret():
    """Return a new random device secret."""
    return secrets.token_urlsafe(32)


def hash_secret(secret):
    """Return the SHA-256 digest stored for a device secret."""
    return hashlib.sha256(secret.encode("utf-8")).hexdigest()


def compare_secret(secret, stored_hash):
    """Constant-time comparison of a secret against a stored digest."""
    if not secret or not stored_hash:
        return False
    return hmac.compare_digest(hash_secret(secret), stored_hash)


def build_credential(device_id, secret):
    """Return the value a child sends after the Device auth scheme."""
    return f"{device_id}.{secret}"


def parse_credential(value):
    """Split a Device credential into its device id and secret."""
    device_id, secret = value.split(".", 1)
    return int(device_id), secret
