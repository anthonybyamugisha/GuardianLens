from django.db import models
from django.utils import timezone

from accounts.models import Family
from devices.models import Device
from pairing.codes import CODE_TTL, generate_code, hash_code


class PairingCodeQuerySet(models.QuerySet):
    def usable(self, now=None):
        now = now or timezone.now()
        return self.filter(
            used_at__isnull=True,
            revoked_at__isnull=True,
            expires_at__gt=now,
        )

    def expired(self, now=None):
        now = now or timezone.now()
        return self.filter(expires_at__lte=now)


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

    objects = PairingCodeQuerySet.as_manager()

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

    @property
    def is_expired(self):
        return self.expires_at <= timezone.now()

    @property
    def is_used(self):
        return self.used_at is not None

    @property
    def is_revoked(self):
        return self.revoked_at is not None

    @property
    def is_usable(self):
        return not (self.is_expired or self.is_used or self.is_revoked)

    def redeem(self, device):
        """Mark the code as used by a device. Codes are single-use."""
        if not self.is_usable:
            raise ValueError("Pairing code is not usable.")

        self.used_at = timezone.now()
        self.redeemed_by = device
        self.save(update_fields=["used_at", "redeemed_by"])
        return self

    def revoke(self):
        self.revoked_at = timezone.now()
        self.save(update_fields=["revoked_at"])
