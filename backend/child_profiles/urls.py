from rest_framework.routers import DefaultRouter

from .views import ChildProfileViewSet

router = DefaultRouter()
router.register(r"children", ChildProfileViewSet, basename="child-profile")

urlpatterns = router.urls