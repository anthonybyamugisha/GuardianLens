from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from devices.models import Device


class MonitoringRule(models.Model):
    """Parent-managed monitoring configuration for one device."""

    class Sensitivity(models.TextChoices):
        LOW = "low", "Low"
        STANDARD = "standard", "Standard"
        STRICT = "strict", "Strict"

    device = models.OneToOneField(
        Device,
        on_delete=models.CASCADE,
        related_name="monitoring_rule",
    )
    sensitivity = models.CharField(
        max_length=20,
        choices=Sensitivity.choices,
        default=Sensitivity.STANDARD,
    )
    sample_interval_seconds = models.PositiveSmallIntegerField(
        default=7,
        validators=[MinValueValidator(5), MaxValueValidator(10)],
    )
    monitored_packages = models.JSONField(default=list, blank=True)
    version = models.PositiveIntegerField(default=1)
    acknowledged_version = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["device__name", "device_id"]

    def __str__(self):
        return f"Rule for {self.device}"
