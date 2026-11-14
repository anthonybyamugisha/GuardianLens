from django.core.exceptions import ValidationError
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models

from devices.models import Device

MIN_SAMPLE_INTERVAL = 5
MAX_SAMPLE_INTERVAL = 10


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
        validators=[
            MinValueValidator(MIN_SAMPLE_INTERVAL),
            MaxValueValidator(MAX_SAMPLE_INTERVAL),
        ],
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

    def clean(self):
        super().clean()
        if not (
            MIN_SAMPLE_INTERVAL
            <= self.sample_interval_seconds
            <= MAX_SAMPLE_INTERVAL
        ):
            raise ValidationError(
                {
                    "sample_interval_seconds": (
                        "Sampling interval must be between "
                        f"{MIN_SAMPLE_INTERVAL} and {MAX_SAMPLE_INTERVAL} seconds."
                    )
                }
            )

        if not isinstance(self.monitored_packages, list):
            raise ValidationError(
                {"monitored_packages": "Monitored packages must be a list."}
            )

        cleaned = []
        for package in self.monitored_packages:
            if not isinstance(package, str):
                raise ValidationError(
                    {"monitored_packages": "Each package must be a string."}
                )
            package = package.strip()
            if package and package not in cleaned:
                cleaned.append(package)
        self.monitored_packages = cleaned
