from rest_framework import serializers

from devices.models import Device


class DeviceSerializer(serializers.ModelSerializer):
    rule_version = serializers.SerializerMethodField()
    rule_acknowledged_version = serializers.SerializerMethodField()

    class Meta:
        model = Device
        fields = [
            "id",
            "name",
            "platform",
            "monitoring_enabled",
            "is_revoked",
            "paired_at",
            "last_seen_at",
            "rule_version",
            "rule_acknowledged_version",
            "created_at",
        ]
        read_only_fields = fields

    def get_rule_version(self, obj):
        rule = getattr(obj, "monitoring_rule", None)
        return rule.version if rule else None

    def get_rule_acknowledged_version(self, obj):
        rule = getattr(obj, "monitoring_rule", None)
        return rule.acknowledged_version if rule else None
