from django.contrib import admin

from .models import Alert


@admin.register(Alert)
class AlertAdmin(admin.ModelAdmin):
    list_display = (
        "event_id",
        "status",
        "channel",
        "sent_at",
        "created_at",
    )
    list_filter = ("status", "channel")
    search_fields = ("event__event_id", "event__device__name")
    readonly_fields = ("created_at", "updated_at", "sent_at")
