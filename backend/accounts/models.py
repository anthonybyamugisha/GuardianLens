from django.conf import settings
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    email = models.EmailField(unique=True)
    phone_number = models.CharField(max_length=20, blank=True)

    def __str__(self):
        return self.username


class Family(models.Model):
    """Ownership boundary for a parent's devices, rules and events."""

    owner = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="family",
    )
    name = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name_plural = "families"

    def __str__(self):
        return self.name or f"{self.owner} family"

    @property
    def display_name(self):
        return self.name or f"{self.owner} family"

    @classmethod
    def for_user(cls, user):
        """Return the user's family, creating it on first use."""
        family, _ = cls.objects.get_or_create(owner=user)
        return family