from django.urls import path

from devices.views import DeviceDetailView, DeviceListView, DeviceRevokeView

urlpatterns = [
    path("devices/", DeviceListView.as_view(), name="device-list"),
    path("devices/<int:pk>/", DeviceDetailView.as_view(), name="device-detail"),
    path(
        "devices/<int:pk>/revoke/",
        DeviceRevokeView.as_view(),
        name="device-revoke",
    ),
]
