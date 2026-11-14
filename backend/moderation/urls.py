from django.urls import path

from moderation.views import EventListCreateView

urlpatterns = [
    path("events/", EventListCreateView.as_view(), name="event-list-create"),
]
