from django.urls import path

from monitoring.views import ChildRuleAckView, ChildRuleView, DeviceRuleView

urlpatterns = [
    path(
        "devices/<int:pk>/rule/",
        DeviceRuleView.as_view(),
        name="device-rule",
    ),
    path("device/rule/", ChildRuleView.as_view(), name="child-rule"),
    path(
        "device/rule/ack/",
        ChildRuleAckView.as_view(),
        name="child-rule-ack",
    ),
]
