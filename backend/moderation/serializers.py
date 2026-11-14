from rest_framework import serializers

from alerts.models import Alert
from moderation.models import ModerationEvent


class ModerationEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModerationEvent
        fields = [
            "event_id",
            "occurred_at",
            "category",
            "risk_level",
            "probability",
            "threshold",
            "decision_reason",
            "warning_shown",
            "details",
            "created_at",
        ]
        read_only_fields = ["created_at"]

    def create(self, validated_data):
        device = self.context["device"]
        event_id = validated_data.get("event_id")

        if event_id is not None:
            existing = ModerationEvent.objects.filter(event_id=event_id).first()
            if existing is not None:
                if existing.device_id != device.pk:
                    raise serializers.ValidationError(
                        {"event_id": "This event id belongs to another device."}
                    )
                self.was_created = False
                return existing

        event = ModerationEvent.objects.create(device=device, **validated_data)
        Alert.objects.get_or_create(event=event)
        self.was_created = True
        return event


class AlertSerializer(serializers.ModelSerializer):
    event_uuid = serializers.UUIDField(source="event.event_id", read_only=True)
    device_name = serializers.CharField(source="event.device.name", read_only=True)

    class Meta:
        model = Alert
        fields = [
            "id",
            "event",
            "event_uuid",
            "device_name",
            "status",
            "channel",
            "sent_at",
            "failure_reason",
            "created_at",
        ]
        read_only_fields = fields
