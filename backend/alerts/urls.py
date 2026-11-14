from django.urls import path

from alerts.views import AlertListView

urlpatterns = [
    path("alerts/", AlertListView.as_view(), name="alert-list"),
]
