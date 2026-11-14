from django.db import models
from django.utils import timezone

from moderation.models import ModerationEvent


class AlertQuerySet(models.QuerySet):
    """Alerts scoped to a family and delivery status."""

    def pending(self):
        return self.filter(status=Alert.Status.PENDING)

    def for_family(self, family):
        return self.filter(event__device__family=family)


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

    objects = AlertQuerySet.as_manager()

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["status", "created_at"]),
        ]

    def __str__(self):
        return f"Alert for event {self.event_id}"

    def mark_sent(self, when=None):
        self.status = self.Status.SENT
        self.sent_at = when or timezone.now()
        self.failure_reason = ""
        self.save(update_fields=["status", "sent_at", "failure_reason", "updated_at"])

    def mark_failed(self, reason=""):
        self.status = self.Status.FAILED
        self.failure_reason = reason[:255]
        self.save(update_fields=["status", "failure_reason", "updated_at"])
