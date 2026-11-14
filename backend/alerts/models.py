from django.db import models

from moderation.models import ModerationEvent


class Alert(models.Model):
    """A parent-facing notification for a moderation event."""

    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        SENT = "sent", "Sent"
        FAILED = "failed", "Failed"

    event = models.OneToOneField(
        ModerationEvent,
        on_delete=models.CASCADE,
        related_name="alert",
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
    )
    channel = models.CharField(max_length=30, default="push")
    sent_at = models.DateTimeField(null=True, blank=True)
    failure_reason = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["status", "created_at"]),
        ]

    def __str__(self):
        return f"Alert for event {self.event_id}"
