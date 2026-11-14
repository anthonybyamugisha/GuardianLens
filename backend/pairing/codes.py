"""Helpers for issuing and protecting pairing codes."""

import hashlib
import secrets
from datetime import timedelta

CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
CODE_LENGTH = 8
CODE_TTL = timedelta(minutes=10)


def normalize_code(code):
    """Strip formatting and upper-case a code before hashing."""
    return "".join(character for character in code.upper() if character.isalnum())


def generate_code():
    """Return a random, human-readable pairing code."""
    body = "".join(secrets.choice(CODE_ALPHABET) for _ in range(CODE_LENGTH))
    return f"GL-{body[:4]}-{body[4:]}"


def hash_code(code):
    """Return the SHA-256 digest stored for a pairing code."""
    return hashlib.sha256(normalize_code(code).encode("utf-8")).hexdigest()
