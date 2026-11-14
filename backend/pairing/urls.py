from django.urls import path

from pairing.views import PairingCodeCreateView, PairingRedeemView

urlpatterns = [
    path("pairing/codes/", PairingCodeCreateView.as_view(), name="pairing-code-create"),
    path("pairing/redeem/", PairingRedeemView.as_view(), name="pairing-redeem"),
]
