from rest_framework import generics, permissions

from alerts.models import Alert
from moderation.serializers import AlertSerializer


class AlertListView(generics.ListAPIView):
    """List all alerts."""

    queryset = Alert.objects.select_related("event", "event__device")
    serializer_class = AlertSerializer
    permission_classes = [permissions.IsAuthenticated]