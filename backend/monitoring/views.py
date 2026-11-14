from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from accounts.access import FamilyScopedQuerysetMixin
from devices.authentication import DeviceCredentialAuthentication
from devices.models import Device
from devices.permissions import IsPairedDevice
from monitoring.models import MonitoringRule
from monitoring.serializers import MonitoringRuleSerializer


class DeviceRuleView(FamilyScopedQuerysetMixin, generics.RetrieveUpdateAPIView):
    """Read or update the monitoring rule for a family device."""

    queryset = Device.objects.all()
    serializer_class = MonitoringRuleSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        device = get_object_or_404(self.get_queryset(), pk=self.kwargs["pk"])
        rule, _ = MonitoringRule.objects.get_or_create(device=device)
        return rule


class ChildRuleView(APIView):
    """Return the rule that applies to the authenticated child device."""

    authentication_classes = [DeviceCredentialAuthentication]
    permission_classes = [IsPairedDevice]
    serializer_class = MonitoringRuleSerializer

    def get(self, request, *args, **kwargs):
        rule, _ = MonitoringRule.objects.get_or_create(device=request.auth)
        return Response(MonitoringRuleSerializer(rule).data)


class ChildRuleAckView(APIView):
    """Record the rule version a child device has applied."""

    authentication_classes = [DeviceCredentialAuthentication]
    permission_classes = [IsPairedDevice]
    serializer_class = MonitoringRuleSerializer

    def post(self, request, *args, **kwargs):
        rule, _ = MonitoringRule.objects.get_or_create(device=request.auth)

        version = request.data.get("version")
        if version is not None:
            try:
                version = int(version)
            except (TypeError, ValueError):
                return Response(
                    {"version": ["A whole number is required."]},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        rule.acknowledge(version)
        return Response(MonitoringRuleSerializer(rule).data)
