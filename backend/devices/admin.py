from django.contrib import admin

from .models import Device


@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = (
        "name",
        "family",
        "platform",
        "monitoring_enabled",
        "is_revoked",
        "last_seen_at",
    )
    list_filter = ("platform", "monitoring_enabled", "is_revoked")
    search_fields = ("name", "family__name", "family__owner__email")
    readonly_fields = (
        "installation_id",
        "paired_at",
        "last_seen_at",
        "created_at",
        "updated_at",
    )
