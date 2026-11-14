from django.contrib import admin

from .models import MonitoringRule


@admin.register(MonitoringRule)
class MonitoringRuleAdmin(admin.ModelAdmin):
    list_display = (
        "device",
        "sensitivity",
        "sample_interval_seconds",
        "version",
        "acknowledged_version",
        "updated_at",
    )
    list_filter = ("sensitivity",)
    search_fields = ("device__name", "device__family__owner__email")
    readonly_fields = ("version", "acknowledged_version", "created_at", "updated_at")
