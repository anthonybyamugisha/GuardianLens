from django.contrib import admin

from .models import PairingCode


@admin.register(PairingCode)
class PairingCodeAdmin(admin.ModelAdmin):
    list_display = (
        "family",
        "created_at",
        "expires_at",
        "is_used",
        "is_revoked",
        "redeemed_by",
    )
    list_filter = ("used_at", "revoked_at", "expires_at")
    search_fields = ("family__name", "family__owner__email")
    readonly_fields = (
        "code_hash",
        "used_at",
        "revoked_at",
        "redeemed_by",
        "created_at",
    )

    @admin.display(boolean=True, description="Used")
    def is_used(self, obj):
        return obj.is_used

    @admin.display(boolean=True, description="Revoked")
    def is_revoked(self, obj):
        return obj.is_revoked
