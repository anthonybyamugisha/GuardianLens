from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import User


class RegisterTests(APITestCase):
    def test_register_creates_user(self):
        response = self.client.post(
            "/api/auth/register/",
            {
                "name": "Menhya Joshua",
                "email": "joshua@example.com",
                "password": "passw0rd123",
                "password2": "passw0rd123",
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        user = User.objects.get(email="joshua@example.com")
        self.assertEqual(user.first_name, "Menhya Joshua")
        self.assertEqual(user.username, "joshua@example.com")

    def test_register_email_is_normalized(self):
        self.client.post(
            "/api/auth/register/",
            {
                "name": "Joshua",
                "email": "  JOSHUA@Example.COM ",
                "password": "passw0rd123",
                "password2": "passw0rd123",
            },
            format="json",
        )
        self.assertTrue(User.objects.filter(email="joshua@example.com").exists())

    def test_register_rejects_duplicate_email(self):
        payload = {
            "name": "Joshua",
            "email": "joshua@example.com",
            "password": "passw0rd123",
            "password2": "passw0rd123",
        }
        self.client.post("/api/auth/register/", payload, format="json")
        response = self.client.post("/api/auth/register/", payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_register_rejects_mismatched_passwords(self):
        response = self.client.post(
            "/api/auth/register/",
            {
                "name": "Joshua",
                "email": "joshua@example.com",
                "password": "passw0rd123",
                "password2": "different123",
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_register_rejects_short_password(self):
        response = self.client.post(
            "/api/auth/register/",
            {
                "name": "Joshua",
                "email": "joshua@example.com",
                "password": "short",
                "password2": "short",
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class LoginTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="joshua@example.com",
            email="joshua@example.com",
            password="passw0rd123",
        )

    def test_login_returns_tokens_and_user(self):
        response = self.client.post(
            "/api/auth/login/",
            {"username": "joshua@example.com", "password": "passw0rd123"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)
        self.assertEqual(response.data["user"]["email"], "joshua@example.com")

    def test_login_rejects_wrong_password(self):
        response = self.client.post(
            "/api/auth/login/",
            {"username": "joshua@example.com", "password": "wrongpassword"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_refresh_token_round_trip(self):
        token_response = self.client.post(
            "/api/auth/login/",
            {"username": "joshua@example.com", "password": "passw0rd123"},
            format="json",
        )
        refresh = token_response.data["refresh"]
        response = self.client.post(
            "/api/auth/token/refresh/", {"refresh": refresh}, format="json"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)


class MeTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="joshua@example.com",
            email="joshua@example.com",
            password="passw0rd123",
            first_name="Joshua",
        )

    def test_me_requires_authentication(self):
        response = self.client.get("/api/auth/me/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_me_returns_profile(self):
        self.client.force_authenticate(self.user)
        response = self.client.get("/api/auth/me/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["email"], "joshua@example.com")
        self.assertEqual(response.data["name"], "Joshua")

    def test_me_updates_profile(self):
        self.client.force_authenticate(self.user)
        response = self.client.patch(
            "/api/auth/me/",
            {"name": "Joshua Updated", "phone_number": "+256700000000"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.first_name, "Joshua Updated")
        self.assertEqual(self.user.phone_number, "+256700000000")


class ChangePasswordTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="joshua@example.com",
            email="joshua@example.com",
            password="passw0rd123",
        )
        self.client.force_authenticate(self.user)

    def test_change_password(self):
        response = self.client.post(
            "/api/auth/change-password/",
            {"old_password": "passw0rd123", "new_password": "newpassw0rd456"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("newpassw0rd456"))

    def test_change_password_rejects_wrong_old_password(self):
        response = self.client.post(
            "/api/auth/change-password/",
            {"old_password": "wrong", "new_password": "newpassw0rd456"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_change_password_requires_auth(self):
        self.client.logout()
        response = self.client.post(
            "/api/auth/change-password/",
            {"old_password": "passw0rd123", "new_password": "newpassw0rd456"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)