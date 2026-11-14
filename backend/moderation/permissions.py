from rest_framework import permissions

from devices.models import Device


class CanReadOrIngestEvents(permissions.BasePermission):
    """Parents may read events; paired devices may submit them."""

    message = "A parent login or paired device credential is required."

    def has_permission(self, request, view):
        if request.method == "POST":
            device = request.auth
            return isinstance(device, Device) and device.is_paired
        return bool(request.user and request.user.is_authenticated)
