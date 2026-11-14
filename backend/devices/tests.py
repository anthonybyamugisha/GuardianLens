from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import Family, User
from devices.models import Device


class DeviceModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="parent@example.com",
            email="parent@example.com",
            password="passw0rd123",
        )
        self.family = Family.for_user(self.user)
        self.device = Device.objects.create(family=self.family, name="Child phone")

    def test_device_defaults(self):
        self.assertEqual(self.device.platform, Device.Platform.ANDROID)
        self.assertFalse(self.device.monitoring_enabled)
        self.assertFalse(self.device.is_revoked)
        self.assertIsNone(self.device.paired_at)
        self.assertIsNone(self.device.last_seen_at)
        self.assertIsNotNone(self.device.installation_id)

    def test_installation_id_is_unique(self):
        other = Device.objects.create(family=self.family, name="Second phone")

        self.assertNotEqual(self.device.installation_id, other.installation_id)

    def test_querysets_scope_by_family_and_state(self):
        other_family = Family.for_user(
            User.objects.create_user(
                username="other@example.com",
                email="other@example.com",
                password="passw0rd123",
            )
        )
        other_device = Device.objects.create(
            family=other_family,
            name="Other phone",
            monitoring_enabled=True,
        )

        self.assertEqual(
            list(Device.objects.for_family(self.family)),
            [self.device],
        )
        self.assertEqual(list(Device.objects.monitoring()), [other_device])
        self.assertEqual(
            Device.objects.active().count(),
            Device.objects.count(),
        )

    def test_mark_paired_and_seen_set_timestamps(self):
        when = timezone.now()
        self.device.mark_paired(when)
        self.device.mark_seen(when)

        self.device.refresh_from_db()
        self.assertEqual(self.device.paired_at, when)
        self.assertEqual(self.device.last_seen_at, when)

    def test_revoke_clears_credentials_and_monitoring(self):
        self.device.credential_hash = "hashed-credential"
        self.device.monitoring_enabled = True
        self.device.save()

        self.device.revoke()
        self.device.refresh_from_db()

        self.assertTrue(self.device.is_revoked)
        self.assertFalse(self.device.monitoring_enabled)
        self.assertEqual(self.device.credential_hash, "")
        self.assertNotIn(self.device, Device.objects.active())


class DeviceAPITests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="parent@example.com",
            email="parent@example.com",
            password="passw0rd123",
        )
        self.family = Family.for_user(self.user)
        self.device = Device.objects.create(family=self.family, name="Child phone")
        self.client.force_authenticate(self.user)

    def test_list_returns_family_devices(self):
        response = self.client.get("/api/devices/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["name"], "Child phone")

    def test_list_excludes_other_families(self):
        other = User.objects.create_user(
            username="other@example.com",
            email="other@example.com",
            password="passw0rd123",
        )
        Device.objects.create(family=Family.for_user(other), name="Other phone")

        response = self.client.get("/api/devices/")

        self.assertEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["id"], self.device.id)

    def test_detail_returns_the_device(self):
        response = self.client.get(f"/api/devices/{self.device.id}/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["id"], self.device.id)

    def test_detail_hides_other_families(self):
        other = User.objects.create_user(
            username="other@example.com",
            email="other@example.com",
            password="passw0rd123",
        )
        other_device = Device.objects.create(
            family=Family.for_user(other),
            name="Other phone",
        )

        response = self.client.get(f"/api/devices/{other_device.id}/")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_revoke_disables_the_device(self):
        self.device.credential_hash = "stored"
        self.device.monitoring_enabled = True
        self.device.save()

        response = self.client.post(f"/api/devices/{self.device.id}/revoke/")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.device.refresh_from_db()
        self.assertTrue(self.device.is_revoked)
        self.assertFalse(self.device.monitoring_enabled)
        self.assertEqual(self.device.credential_hash, "")

    def test_revoke_hides_other_families(self):
        other = User.objects.create_user(
            username="other@example.com",
            email="other@example.com",
            password="passw0rd123",
        )
        other_device = Device.objects.create(
            family=Family.for_user(other),
            name="Other phone",
        )

        response = self.client.post(f"/api/devices/{other_device.id}/revoke/")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        other_device.refresh_from_db()
        self.assertFalse(other_device.is_revoked)
