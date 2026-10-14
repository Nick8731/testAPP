from contextlib import asynccontextmanager
import asyncio
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.core.config import get_settings
from app.db.session import init_database
from app.services.database_backup import configured_backup

settings = get_settings()


@asynccontextmanager
async def lifespan(_app: FastAPI):
    init_database()
    async def backup_loop():
        while True:
            try:
                await asyncio.to_thread(configured_backup, settings)
            except Exception:
                logging.getLogger(__name__).exception('SQLite backup failed; original database is unchanged')
            await asyncio.sleep(settings.sqlite_backup_interval_minutes * 60)

    task = asyncio.create_task(backup_loop()) if (
        settings.sqlite_backup_enabled and settings.db_backend == 'sqlite'
        and settings.sqlite_database_path != ':memory:'
    ) else None
    try:
        yield
    finally:
        if task is not None:
            task.cancel()
            try:
                await task
            except asyncio.CancelledError:
                pass


app = FastAPI(title="SmashCoach API", version="1.0.0", lifespan=lifespan)

if settings.cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )


@app.get("/health", tags=["health"])
def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(api_router)
