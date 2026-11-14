import uuid

from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models
from django.utils import timezone

from devices.models import Device


class ModerationEvent(models.Model):
    """Minimal metadata for one moderation decision on a device."""

    class Category(models.TextChoices):
        SEXUAL = "sexual", "Sexual"
        VIOLENCE = "violence", "Violence"
        TEXT = "text", "Embedded text"
        OTHER = "other", "Other"

    class RiskLevel(models.TextChoices):
        LOW = "low", "Low"
        MEDIUM = "medium", "Medium"
        HIGH = "high", "High"

    class DecisionReason(models.TextChoices):
        VISUAL = "visual", "Visual threshold"
        TEXT = "text", "Text filter"
        COMBINED = "combined", "Visual and text"
        MANUAL = "manual", "Manual"

    event_id = models.UUIDField(default=uuid.uuid4, unique=True)
    device = models.ForeignKey(
        Device,
        on_delete=models.CASCADE,
        related_name="events",
    )
    occurred_at = models.DateTimeField(default=timezone.now)
    category = models.CharField(max_length=20, choices=Category.choices)
    risk_level = models.CharField(max_length=20, choices=RiskLevel.choices)
    probability = models.FloatField(
        null=True,
        blank=True,
        validators=[MinValueValidator(0.0), MaxValueValidator(1.0)],
    )
    threshold = models.FloatField(
        null=True,
        blank=True,
        validators=[MinValueValidator(0.0), MaxValueValidator(1.0)],
    )
    decision_reason = models.CharField(
        max_length=20,
        choices=DecisionReason.choices,
    )
    warning_shown = models.BooleanField(default=True)
    details = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-occurred_at", "-id"]
        indexes = [
            models.Index(fields=["device", "occurred_at"]),
        ]

    def __str__(self):
        return f"{self.category} event for {self.device_id}"
