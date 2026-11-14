from django.core.exceptions import ValidationError
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import Family, User
from devices.models import Device
from monitoring.models import MonitoringRule


class MonitoringRuleModelTests(TestCase):
    def setUp(self):
        user = User.objects.create_user(
            username="parent@example.com",
            email="parent@example.com",
            password="passw0rd123",
        )
        self.device = Device.objects.create(
            family=Family.for_user(user),
            name="Child phone",
        )
        self.rule = MonitoringRule.objects.create(device=self.device)

    def test_rule_defaults(self):
        self.assertEqual(self.rule.sensitivity, MonitoringRule.Sensitivity.STANDARD)
        self.assertEqual(self.rule.sample_interval_seconds, 7)
        self.assertEqual(self.rule.monitored_packages, [])
        self.assertEqual(self.rule.version, 1)
        self.assertEqual(self.rule.acknowledged_version, 0)
        self.assertTrue(self.rule.needs_acknowledgement)

    def test_each_device_has_one_rule(self):
        with self.assertRaises(Exception):
            MonitoringRule.objects.create(device=self.device)

    def test_clean_rejects_interval_outside_range(self):
        for interval in (4, 11):
            rule = MonitoringRule(
                device=self.device,
                sample_interval_seconds=interval,
            )
            with self.assertRaises(ValidationError):
                rule.full_clean()

    def test_clean_deduplicates_and_trims_packages(self):
        other = Device.objects.create(family=self.device.family, name="Second phone")
        rule = MonitoringRule(
            device=other,
            monitored_packages=[
                " com.google.android.youtube ",
                "com.google.android.youtube",
                "",
                "com.instagram.android",
            ],
        )
        rule.full_clean()

        self.assertEqual(
            rule.monitored_packages,
            ["com.google.android.youtube", "com.instagram.android"],
        )

    def test_bump_version_requires_new_acknowledgement(self):
        self.rule.acknowledge()
        self.assertFalse(self.rule.needs_acknowledgement)

        self.rule.bump_version()
        self.rule.refresh_from_db()

        self.assertEqual(self.rule.version, 2)
        self.assertEqual(self.rule.acknowledged_version, 1)
        self.assertTrue(self.rule.needs_acknowledgement)

    def test_acknowledge_never_exceeds_current_version(self):
        self.rule.acknowledge(version=99)

        self.assertEqual(self.rule.acknowledged_version, self.rule.version)
        self.assertFalse(self.rule.needs_acknowledgement)


class MonitoringRuleAPITests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="parent@example.com",
            email="parent@example.com",
            password="passw0rd123",
        )
        self.family = Family.for_user(self.user)
        self.device = Device.objects.create(family=self.family, name="Child phone")
        self.secret = self.device.issue_credential()
        self.device.mark_paired()
        self.credential = f"Device {self.device.pk}.{self.secret}"

    def as_child(self):
        return self.client.credentials(HTTP_AUTHORIZATION=self.credential)

    def test_child_can_read_its_rule(self):
        self.as_child()
        response = self.client.get("/api/device/rule/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.data["sensitivity"],
            MonitoringRule.Sensitivity.STANDARD,
        )
        self.assertEqual(response.data["version"], 1)

    def test_child_can_acknowledge_a_version(self):
        self.as_child()
        response = self.client.post(
            "/api/device/rule/ack/",
            {"version": 1},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["acknowledged_version"], 1)
        self.assertFalse(response.data["needs_acknowledgement"])

    def test_child_requires_a_credential(self):
        response = self.client.get("/api/device/rule/")

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_revoked_device_cannot_read_its_rule(self):
        self.as_child()
        self.device.revoke()

        response = self.client.get("/api/device/rule/")

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_parent_can_read_and_update_the_rule(self):
        self.client.force_authenticate(self.user)
        url = f"/api/devices/{self.device.pk}/rule/"

        response = self.client.patch(
            url,
            {
                "sensitivity": MonitoringRule.Sensitivity.STRICT,
                "sample_interval_seconds": 5,
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["version"], 2)
        self.assertEqual(response.data["sensitivity"], "strict")

    def test_parent_update_rejects_invalid_interval(self):
        self.client.force_authenticate(self.user)
        response = self.client.patch(
            f"/api/devices/{self.device.pk}/rule/",
            {"sample_interval_seconds": 30},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_rule_is_scoped_to_the_parents_family(self):
        other = User.objects.create_user(
            username="other@example.com",
            email="other@example.com",
            password="passw0rd123",
        )
        other_device = Device.objects.create(
            family=Family.for_user(other),
            name="Other phone",
        )
        self.client.force_authenticate(self.user)

        response = self.client.get(f"/api/devices/{other_device.pk}/rule/")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
