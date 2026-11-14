"""Authentication for paired child devices."""

from django.utils.translation import gettext_lazy as _
from rest_framework import authentication, exceptions

from devices.credentials import CREDENTIAL_SCHEME, parse_credential
from devices.models import Device


class DeviceCredentialAuthentication(authentication.BaseAuthentication):
    """Authenticate a child using ``Authorization: Device <id>.<secret>``."""

    keyword = CREDENTIAL_SCHEME

    def authenticate(self, request):
        header = authentication.get_authorization_header(request).split()
        if not header or header[0].lower() != self.keyword.lower().encode():
            return None

        if len(header) != 2:
            raise exceptions.AuthenticationFailed(
                _("Malformed device credential header.")
            )

        try:
            device_id, secret = parse_credential(header[1].decode())
        except (ValueError, UnicodeDecodeError):
            raise exceptions.AuthenticationFailed(
                _("Malformed device credential header.")
            )

        try:
            device = Device.objects.get(pk=device_id)
        except Device.DoesNotExist:
            raise exceptions.AuthenticationFailed(_("Unknown device."))

        if device.is_revoked or not device.check_credential(secret):
            raise exceptions.AuthenticationFailed(_("Invalid device credential."))

        return (None, device)

    def authenticate_header(self, request):
        return self.keyword
