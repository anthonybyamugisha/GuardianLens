from datetime import timedelta

from django.test import TestCase
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import Family, User
from devices.credentials import parse_credential
from devices.models import Device
from pairing.codes import generate_code, hash_code, normalize_code
from pairing.models import PairingCode


class PairingCodeModelTests(TestCase):
    def setUp(self):
        user = User.objects.create_user(
            username="parent@example.com",
            email="parent@example.com",
            password="passw0rd123",
        )
        self.family = Family.for_user(user)
        self.device = Device.objects.create(family=self.family, name="Child phone")

    def test_generate_code_is_readable(self):
        code = generate_code()

        self.assertTrue(code.startswith("GL-"))
        self.assertEqual(len(normalize_code(code)), 10)

    def test_hash_ignores_formatting_and_case(self):
        self.assertEqual(hash_code("gl-abcd-2345"), hash_code("GLABCD2345"))

    def test_issue_stores_only_the_hash(self):
        record, code = PairingCode.issue(self.family)

        self.assertNotEqual(record.code_hash, code)
        self.assertEqual(record.code_hash, hash_code(code))
        self.assertEqual(record.family, self.family)
        self.assertGreater(record.expires_at, timezone.now())
        self.assertTrue(record.is_usable)

    def test_expired_code_is_not_usable(self):
        record, _ = PairingCode.issue(self.family)
        record.expires_at = timezone.now() - timedelta(seconds=1)
        record.save(update_fields=["expires_at"])

        self.assertTrue(record.is_expired)
        self.assertFalse(record.is_usable)
        self.assertIn(record, PairingCode.objects.expired())
        self.assertNotIn(record, PairingCode.objects.usable())

    def test_used_and_revoked_codes_are_not_usable(self):
        used, _ = PairingCode.issue(self.family)
        used.used_at = timezone.now()
        used.save(update_fields=["used_at"])

        revoked, _ = PairingCode.issue(self.family)
        revoked.revoked_at = timezone.now()
        revoked.save(update_fields=["revoked_at"])

        self.assertFalse(used.is_usable)
        self.assertFalse(revoked.is_usable)
        self.assertEqual(list(PairingCode.objects.usable()), [])

    def test_redeem_marks_the_code_used(self):
        record, _ = PairingCode.issue(self.family)

        record.redeem(self.device)
        record.refresh_from_db()

        self.assertTrue(record.is_used)
        self.assertEqual(record.redeemed_by, self.device)
        self.assertFalse(record.is_usable)
        self.assertNotIn(record, PairingCode.objects.usable())

    def test_a_code_can_only_be_redeemed_once(self):
        record, _ = PairingCode.issue(self.family)
        other = Device.objects.create(family=self.family, name="Other phone")
        record.redeem(self.device)

        with self.assertRaises(ValueError):
            record.redeem(other)

        record.refresh_from_db()
        self.assertEqual(record.redeemed_by, self.device)

    def test_revoked_code_cannot_be_redeemed(self):
        record, _ = PairingCode.issue(self.family)
        record.revoke()

        self.assertTrue(record.is_revoked)
        with self.assertRaises(ValueError):
            record.redeem(self.device)

    def test_delete_expired_removes_only_expired_codes(self):
        expired, _ = PairingCode.issue(self.family)
        expired.expires_at = timezone.now() - timedelta(seconds=1)
        expired.save(update_fields=["expires_at"])
        usable, _ = PairingCode.issue(self.family)

        deleted, _ = PairingCode.delete_expired()

        self.assertEqual(deleted, 1)
        self.assertFalse(PairingCode.objects.filter(pk=expired.pk).exists())
        self.assertTrue(PairingCode.objects.filter(pk=usable.pk).exists())


class PairingAPITests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="parent@example.com",
            email="parent@example.com",
            password="passw0rd123",
        )
        self.family = Family.for_user(self.user)
        self.client.force_authenticate(self.user)

    def issue_code(self):
        response = self.client.post("/api/pairing/codes/", {}, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        return response.data

    def test_parent_can_issue_a_code(self):
        data = self.issue_code()

        self.assertTrue(data["code"].startswith("GL-"))
        self.assertEqual(PairingCode.objects.count(), 1)
        record = PairingCode.objects.get()
        self.assertNotEqual(record.code_hash, data["code"])
        self.assertEqual(record.family, self.family)

    def test_redeeming_a_code_pairs_a_device(self):
        code = self.issue_code()["code"]

        response = self.client.post(
            "/api/pairing/redeem/",
            {"code": code, "name": "Child phone"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        device = Device.objects.get()
        self.assertEqual(device.family, self.family)
        self.assertTrue(device.is_paired)
        device_id, secret = parse_credential(response.data["credential"])
        self.assertEqual(device_id, device.pk)
        self.assertTrue(device.check_credential(secret))
        self.assertTrue(PairingCode.objects.get().is_used)

    def test_a_code_cannot_be_redeemed_twice(self):
        code = self.issue_code()["code"]
        payload = {"code": code, "name": "Child phone"}

        first = self.client.post("/api/pairing/redeem/", payload, format="json")
        second = self.client.post("/api/pairing/redeem/", payload, format="json")

        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        self.assertEqual(second.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Device.objects.count(), 1)

    def test_expired_code_is_rejected(self):
        code = self.issue_code()["code"]
        record = PairingCode.objects.get()
        record.expires_at = timezone.now() - timedelta(seconds=1)
        record.save(update_fields=["expires_at"])

        response = self.client.post(
            "/api/pairing/redeem/",
            {"code": code, "name": "Child phone"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(Device.objects.exists())

    def test_unknown_code_is_rejected(self):
        response = self.client.post(
            "/api/pairing/redeem/",
            {"code": "GL-AAAA-AAAA", "name": "Child phone"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertFalse(Device.objects.exists())

    def test_redeemed_device_belongs_to_the_codes_family_only(self):
        other = User.objects.create_user(
            username="other@example.com",
            email="other@example.com",
            password="passw0rd123",
        )
        other_family = Family.for_user(other)
        code = self.issue_code()["code"]

        self.client.force_authenticate(other)
        self.client.post(
            "/api/pairing/redeem/",
            {"code": code, "name": "Child phone"},
            format="json",
        )

        self.assertFalse(Device.objects.filter(family=other_family).exists())
        self.assertTrue(Device.objects.filter(family=self.family).exists())
