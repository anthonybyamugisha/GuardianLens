from django.core.exceptions import ValidationError as DjangoValidationError
from rest_framework import serializers

from monitoring.models import MonitoringRule


class MonitoringRuleSerializer(serializers.ModelSerializer):
    needs_acknowledgement = serializers.BooleanField(read_only=True)

    class Meta:
        model = MonitoringRule
        fields = [
            "id",
            "sensitivity",
            "sample_interval_seconds",
            "monitored_packages",
            "version",
            "acknowledged_version",
            "needs_acknowledgement",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "version",
            "acknowledged_version",
            "needs_acknowledgement",
            "updated_at",
        ]

    def validate(self, attrs):
        rule = self.instance or MonitoringRule(
            device=self.context.get("device")
        )
        for field, value in attrs.items():
            setattr(rule, field, value)
        try:
            rule.clean()
        except DjangoValidationError as error:
            raise serializers.ValidationError(error.message_dict)
        self._cleaned_packages = rule.monitored_packages
        return attrs

    def create(self, validated_data):
        rule = MonitoringRule(
            device=self.context["device"],
            **validated_data,
        )
        rule.monitored_packages = self._cleaned_packages
        rule.save()
        return rule

    def update(self, instance, validated_data):
        for field, value in validated_data.items():
            setattr(instance, field, value)
        instance.monitored_packages = self._cleaned_packages
        instance.full_clean()
        instance.version += 1
        instance.save()
        return instance
