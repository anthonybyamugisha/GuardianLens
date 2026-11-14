from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from devices.models import Device

from .models import Family, User


@admin.register(User)
class GuardianLensUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        (
            "GuardianLens information",
            {
                "fields": (
                    "phone_number",
                )
            },
        ),
    )

    add_fieldsets = UserAdmin.add_fieldsets + (
        (
            "GuardianLens information",
            {
                "fields": (
                    "email",
                    "phone_number",
                )
            },
        ),
    )


class DeviceInline(admin.TabularInline):
    model = Device
    extra = 0
    fields = (
        "name",
        "platform",
        "monitoring_enabled",
        "is_revoked",
        "last_seen_at",
    )
    readonly_fields = ("last_seen_at",)


@admin.register(Family)
class FamilyAdmin(admin.ModelAdmin):
    list_display = ("display_name", "owner", "created_at")
    search_fields = ("name", "owner__username", "owner__email")
    readonly_fields = ("created_at", "updated_at")
    inlines = [DeviceInline]