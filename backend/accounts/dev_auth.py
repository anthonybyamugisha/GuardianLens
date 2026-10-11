"""Development-only authentication bypass.

Enabled via the ``DISABLE_AUTH=1`` environment variable (see
``config.settings``). When active, every API request is authenticated as a
single shared demo user so the team can build the core features without
managing credentials or tokens.

This module is inert unless ``DISABLE_AUTH`` is set, so importing it in a
production configuration is harmless. Re-enable real authentication by
unsetting ``DISABLE_AUTH`` (no code changes required).
"""
from __future__ import annotations

from django.contrib.auth import get_user_model
from rest_framework.authentication import BaseAuthentication

DEMO_USERNAME = "dev"
DEMO_EMAIL = "dev@guardianlens.local"


class DevUserAuthentication(BaseAuthentication):
    """Authenticate every request as a shared, auto-created demo user."""

    def authenticate(self, request):
        user_model = get_user_model()
        user, _ = user_model.objects.get_or_create(
            username=DEMO_USERNAME,
            defaults={
                "email": DEMO_EMAIL,
                "first_name": "Dev",
                "is_staff": True,
            },
        )
        return (user, None)
