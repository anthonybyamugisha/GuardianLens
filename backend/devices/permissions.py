from rest_framework import permissions

from devices.models import Device


class IsPairedDevice(permissions.BasePermission):
    """Allow only an authenticated, paired and active device."""

    message = "A valid paired device credential is required."

    def has_permission(self, request, view):
        device = request.auth
        return (
            isinstance(device, Device)
            and device.pk is not None
            and device.is_paired
        )
