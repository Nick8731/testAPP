import os

os.environ.setdefault("JWT_SECRET", "test-only-secret-at-least-32-characters")
os.environ.setdefault("DB_BACKEND", "sqlite")
os.environ.setdefault("SQLITE_PATH", ":memory:")

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from sqlalchemy.pool import StaticPool

from app import models  # noqa: F401
from app.db.base import Base
from app.db.session import get_db
from app.main import app

_test_engine = create_engine(
    "sqlite://",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)


@pytest.fixture(autouse=True)
def database():
    Base.metadata.create_all(_test_engine)
    yield
    Base.metadata.drop_all(_test_engine)


@pytest.fixture
def test_engine():
    return _test_engine


@pytest.fixture
def client():
    def override_get_db():
        with Session(_test_engine, expire_on_commit=False) as session:
            yield session

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def auth_headers(client: TestClient) -> dict[str, str]:
    client.post(
        "/api/auth/register",
        json={"name": "Player", "email": "player@example.com", "password": "secure-pass-123"},
    )
    response = client.post(
        "/api/auth/login",
        json={"email": "player@example.com", "password": "secure-pass-123"},
    )
    return {"Authorization": f"Bearer {response.json()['accessToken']}"}
