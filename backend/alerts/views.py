from rest_framework import generics, permissions

from accounts.access import FamilyScopedQuerysetMixin
from alerts.models import Alert
from moderation.serializers import AlertSerializer


class AlertListView(FamilyScopedQuerysetMixin, generics.ListAPIView):
    """List the alerts raised for the requesting parent's family."""

    queryset = Alert.objects.select_related("event", "event__device")
    serializer_class = AlertSerializer
    permission_classes = [permissions.IsAuthenticated]
    family_lookup = "event__device__family"

    def get_queryset(self):
        queryset = super().get_queryset()

        status_filter = self.request.query_params.get("status")
        if status_filter:
            queryset = queryset.filter(status=status_filter)

        device = self.request.query_params.get("device")
        if device:
            queryset = queryset.filter(event__device_id=device)

        return queryset
