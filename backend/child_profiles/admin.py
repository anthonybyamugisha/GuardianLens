from django.contrib import admin

from .models import ChildProfile


@admin.register(ChildProfile)
class ChildProfileAdmin(admin.ModelAdmin):
    list_display = ("full_name", "parent", "gender", "is_active", "created_at")
    list_filter = ("gender", "is_active")
    search_fields = ("full_name", "parent__username", "parent__email")