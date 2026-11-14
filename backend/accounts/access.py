"""Helpers for resolving the family that scopes a request."""

from accounts.models import Family


def family_for(user):
    """Return the authenticated user's family, or ``None``."""
    if user is None or not user.is_authenticated:
        return None
    return Family.for_user(user)


class FamilyScopedQuerysetMixin:
    """Restrict a view's queryset to the requesting parent's family."""

    family_lookup = "family"

    def get_family(self):
        return family_for(self.request.user)

    def get_queryset(self):
        return super().get_queryset().filter(
            **{self.family_lookup: self.get_family()}
        )
