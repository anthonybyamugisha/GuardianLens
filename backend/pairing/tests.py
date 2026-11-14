from datetime import timedelta

from django.test import TestCase
from django.utils import timezone

from accounts.models import Family, User
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
