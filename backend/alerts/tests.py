from django.test import TestCase
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import Family, User
from devices.models import Device
from moderation.models import ModerationEvent
from alerts.models import Alert


class AlertAPITests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="parent@example.com",
            email="parent@example.com",
            password="passw0rd123",
        )
        self.family = Family.for_user(self.user)
        self.device = Device.objects.create(family=self.family, name="Child phone")
        event = ModerationEvent.objects.create(
            device=self.device,
            category=ModerationEvent.Category.TEXT,
            risk_level=ModerationEvent.RiskLevel.MEDIUM,
            decision_reason=ModerationEvent.DecisionReason.TEXT,
        )
        Alert.objects.get_or_create(event=event)

    def test_alert_list_for_parent(self):
        response = self.client.get("/api/alerts/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)

    def test_alert_list_other_families(self):
        other = User.objects.create_user(
            username="other@example.com",
            email="other@example.com",
            password="passw0rd123",
        )
        other_device = Device.objects.create(family=Family.for_user(other), name="Other phone")
        event = ModerationEvent.objects.create(
            device=other_device,
            category=ModerationEvent.Category.VIOLENCE,
            risk_level=ModerationEvent.RiskLevel.HIGH,
            decision_reason=ModerationEvent.DecisionReason.TEXT,
        )
        Alert.objects.get_or_create(event=event)

        response = self.client.get("/api/alerts/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 2)

    def test_alert_list_pending_only(self):
        response = self.client.get("/api/alerts/?status=pending")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data["results"]), 1)