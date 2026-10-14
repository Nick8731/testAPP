from fastapi import APIRouter

from app.api.routes import analysis, auth, progress, users

api_router = APIRouter(prefix="/api")
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(analysis.router, prefix="/analysis", tags=["analysis"])
api_router.include_router(progress.router, prefix="/progress", tags=["progress"])
