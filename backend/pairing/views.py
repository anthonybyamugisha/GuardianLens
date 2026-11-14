from rest_framework import generics, permissions, status
from rest_framework.response import Response

from accounts.access import family_for
from devices.serializers import DeviceSerializer
from pairing.models import PairingCode
from pairing.serializers import PairingCodeSerializer, PairingRedeemSerializer


class PairingCodeCreateView(generics.GenericAPIView):
    """Issue a short-lived pairing code for the parent's family."""

    serializer_class = PairingCodeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        family = family_for(request.user)
        record, code = PairingCode.issue(family)
        data = PairingCodeSerializer(record).data
        data["code"] = code
        return Response(data, status=status.HTTP_201_CREATED)


class PairingRedeemView(generics.GenericAPIView):
    """Redeem a pairing code on a child device."""

    serializer_class = PairingRedeemSerializer
    authentication_classes = []
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        device = serializer.save()
        return Response(
            {
                "device": DeviceSerializer(device).data,
                "credential": device.plain_credential,
            },
            status=status.HTTP_201_CREATED,
        )
