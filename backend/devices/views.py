from django.shortcuts import get_object_or_404
from rest_framework import generics, permissions, status
from rest_framework.response import Response

from accounts.access import FamilyScopedQuerysetMixin
from devices.models import Device
from devices.serializers import DeviceSerializer


class DeviceListView(FamilyScopedQuerysetMixin, generics.ListAPIView):
    """List the devices that belong to the requesting parent's family."""

    queryset = Device.objects.all()
    serializer_class = DeviceSerializer
    permission_classes = [permissions.IsAuthenticated]


class DeviceDetailView(FamilyScopedQuerysetMixin, generics.RetrieveAPIView):
    """Show one device in the requesting parent's family."""

    queryset = Device.objects.all()
    serializer_class = DeviceSerializer
    permission_classes = [permissions.IsAuthenticated]


class DeviceRevokeView(FamilyScopedQuerysetMixin, generics.GenericAPIView):
    """Revoke a paired device and clear its credential."""

    queryset = Device.objects.all()
    serializer_class = DeviceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        device = get_object_or_404(self.get_queryset(), pk=kwargs["pk"])
        device.revoke()
        return Response(
            self.get_serializer(device).data,
            status=status.HTTP_200_OK,
        )
