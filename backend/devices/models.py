import uuid

from django.db import models

from accounts.models import Family


class DeviceQuerySet(models.QuerySet):
    """Querysets scoped to a family and pairing state."""

    def active(self):
        return self.filter(is_revoked=False)

    def for_family(self, family):
        return self.filter(family=family)

    def monitoring(self):
        return self.active().filter(monitoring_enabled=True)


class Device(models.Model):
    """A child device paired to a family."""

    class Platform(models.TextChoices):
        ANDROID = "android", "Android"

    family = models.ForeignKey(
        Family,
        on_delete=models.CASCADE,
        related_name="devices",
    )
    name = models.CharField(max_length=100)
    platform = models.CharField(
        max_length=20,
        choices=Platform.choices,
        default=Platform.ANDROID,
    )
    installation_id = models.UUIDField(
        default=uuid.uuid4,
        unique=True,
        editable=False,
    )
    credential_hash = models.CharField(max_length=128, blank=True)
    paired_at = models.DateTimeField(null=True, blank=True)
    last_seen_at = models.DateTimeField(null=True, blank=True)
    monitoring_enabled = models.BooleanField(default=False)
    is_revoked = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = DeviceQuerySet.as_manager()

    class Meta:
        ordering = ["name", "id"]
        indexes = [
            models.Index(fields=["family", "is_revoked"]),
        ]

    def __str__(self):
        return self.name
