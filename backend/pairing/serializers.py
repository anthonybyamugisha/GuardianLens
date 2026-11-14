from django.db import transaction
from rest_framework import serializers

from devices.credentials import build_credential
from devices.models import Device
from pairing.codes import hash_code
from pairing.models import PairingCode


class PairingCodeSerializer(serializers.ModelSerializer):
    code = serializers.CharField(read_only=True)

    class Meta:
        model = PairingCode
        fields = ["id", "code", "expires_at", "created_at"]
        read_only_fields = fields


class PairingRedeemSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=32)
    name = serializers.CharField(max_length=100)
    platform = serializers.ChoiceField(
        choices=Device.Platform.choices,
        required=False,
        default=Device.Platform.ANDROID,
    )

    def validate_code(self, value):
        record = (
            PairingCode.objects.usable()
            .filter(code_hash=hash_code(value))
            .first()
        )
        if record is None:
            raise serializers.ValidationError(
                "This pairing code is invalid, expired or already used."
            )
        self.pairing_code = record
        return value

    def create(self, validated_data):
        with transaction.atomic():
            device = Device.objects.create(
                family=self.pairing_code.family,
                name=validated_data["name"],
                platform=validated_data["platform"],
            )
            secret = device.issue_credential()
            device.mark_paired()
            self.pairing_code.redeem(device)

        device.plain_credential = build_credential(device.pk, secret)
        return device
