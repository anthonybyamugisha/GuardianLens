from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from accounts.models import User


class UserSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source="first_name", max_length=150, required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ["id", "username", "name", "email", "phone_number", "date_joined"]
        read_only_fields = ["id", "username", "date_joined"]

    def validate_email(self, value):
        return value.strip().lower()


class RegisterSerializer(serializers.ModelSerializer):
    name = serializers.CharField(write_only=True, max_length=150)
    password = serializers.CharField(write_only=True, style={"input_type": "password"})
    password2 = serializers.CharField(write_only=True, style={"input_type": "password"})
    phone_number = serializers.CharField(write_only=True, max_length=20, required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ["name", "email", "password", "password2", "phone_number"]

    def validate_email(self, value):
        return value.strip().lower()

    def validate(self, attrs):
        password = attrs.get("password")
        if len(password) < 8:
            raise serializers.ValidationError({"password": "Password must be at least 8 characters."})
        if password != attrs.get("password2"):
            raise serializers.ValidationError({"password2": "Passwords do not match."})
        validate_password(password)
        return attrs

    def create(self, validated_data):
        validated_data.pop("password2")
        password = validated_data.pop("password")
        name = validated_data.pop("name")
        email = validated_data["email"]
        user = User(
            username=email,
            email=email,
            first_name=name,
            phone_number=validated_data.get("phone_number", ""),
        )
        user.set_password(password)
        user.save()
        return user


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True)

    def validate_old_password(self, value):
        if not self.context["request"].user.check_password(value):
            raise serializers.ValidationError("Your old password is incorrect.")
        return value

    def validate_new_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError("Password must be at least 8 characters.")
        validate_password(value)
        return value

    def save(self, **kwargs):
        user = self.context["request"].user
        user.set_password(self.validated_data["new_password"])
        user.save(update_fields=["password"])
        return user