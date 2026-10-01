from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import User


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