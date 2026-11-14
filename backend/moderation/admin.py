from django.contrib import admin

from .models import ModerationEvent


@admin.register(ModerationEvent)
class ModerationEventAdmin(admin.ModelAdmin):
    list_display = (
        "event_id",
        "device",
        "category",
        "risk_level",
        "decision_reason",
        "occurred_at",
    )
    list_filter = ("category", "risk_level", "decision_reason", "warning_shown")
    search_fields = ("event_id", "device__name", "device__family__owner__email")
    date_hierarchy = "occurred_at"
    readonly_fields = ("event_id", "created_at")
