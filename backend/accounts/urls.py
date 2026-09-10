from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView

from accounts.views import (
    ChangePasswordView,
    GuardianLensTokenObtainPairView,
    MeView,
    RegisterView,
)

urlpatterns = [
    path("auth/register/", RegisterView.as_view(), name="auth-register"),
    path("auth/login/", GuardianLensTokenObtainPairView.as_view(), name="auth-login"),
    path("auth/token/refresh/", TokenRefreshView.as_view(), name="auth-token-refresh"),
    path("auth/token/verify/", TokenVerifyView.as_view(), name="auth-token-verify"),
    path("auth/me/", MeView.as_view(), name="auth-me"),
    path("auth/change-password/", ChangePasswordView.as_view(), name="auth-change-password"),
]