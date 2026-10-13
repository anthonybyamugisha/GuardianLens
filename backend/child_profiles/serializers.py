from rest_framework import serializers

from .models import ChildProfile


class ChildProfileSerializer(serializers.ModelSerializer):
    parent = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = ChildProfile
        fields = [
            "id",
            "parent",
            "full_name",
            "date_of_birth",
            "gender",
            "notes",
            "is_active",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "parent", "created_at", "updated_at"]