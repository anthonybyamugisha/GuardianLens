from django.db import models
from django.utils import timezone

from accounts.models import Family
from devices.models import Device
from pairing.codes import CODE_TTL, generate_code, hash_code


class PairingCode(models.Model):
    """A short-lived, single-use code that pairs a child device."""

    family = models.ForeignKey(
        Family,
        on_delete=models.CASCADE,
        related_name="pairing_codes",
    )
    code_hash = models.CharField(max_length=64, unique=True)
    expires_at = models.DateTimeField()
    used_at = models.DateTimeField(null=True, blank=True)
    revoked_at = models.DateTimeField(null=True, blank=True)
    redeemed_by = models.ForeignKey(
        Device,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="redeemed_codes",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Pairing code for family {self.family_id}"

    @classmethod
    def issue(cls, family, ttl=CODE_TTL):
        """Create a pairing code and return it with its plaintext value."""
        code = generate_code()
        record = cls.objects.create(
            family=family,
            code_hash=hash_code(code),
            expires_at=timezone.now() + ttl,
        )
        return record, code
