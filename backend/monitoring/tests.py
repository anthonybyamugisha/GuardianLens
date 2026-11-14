from django.core.exceptions import ValidationError
from django.test import TestCase

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
