from rest_framework import serializers

from alerts.models import Alert


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