from django.conf import settings
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework_simplejwt.authentication import JWTAuthentication

from accounts.access import family_for
from accounts.dev_auth import DevUserAuthentication
from devices.authentication import DeviceCredentialAuthentication
from moderation.models import ModerationEvent
from moderation.permissions import CanReadOrIngestEvents
from moderation.serializers import ModerationEventSerializer


def event_authentication_classes():
    """Accept device credentials or a parent login (or the dev user)."""
    classes = [DeviceCredentialAuthentication, JWTAuthentication]
    if settings.DISABLE_AUTH:
        classes.append(DevUserAuthentication)
    return classes


class EventListCreateView(generics.ListCreateAPIView):
    """List a family's events, or ingest one from a paired device."""

    serializer_class = ModerationEventSerializer
    permission_classes = [CanReadOrIngestEvents]

    def get_authenticators(self):
        return [auth() for auth in event_authentication_classes()]

    def get_queryset(self):
        queryset = ModerationEvent.objects.for_family(
            family_for(self.request.user)
        )

        device = self.request.query_params.get("device")
        if device:
            queryset = queryset.filter(device_id=device)

        category = self.request.query_params.get("category")
        if category:
            queryset = queryset.filter(category=category)

        risk_level = self.request.query_params.get("risk_level")
        if risk_level:
            queryset = queryset.filter(risk_level=risk_level)

        return queryset

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context["device"] = self.request.auth
        return context

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        event = serializer.save()
        request.auth.mark_seen()

        status_code = (
            status.HTTP_201_CREATED
            if getattr(serializer, "was_created", True)
            else status.HTTP_200_OK
        )
        return Response(serializer.data, status=status_code)
