from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.dialects import mssql
from sqlalchemy.orm import Session
from sqlalchemy.schema import CreateTable

from app.models.analysis import AnalysisDetail, AnalysisFeedback, AnalysisRecord, AnalysisScore
from app.models.user import User


def test_chinese_fields_compile_as_nvarchar():
    tables = [User, AnalysisRecord, AnalysisScore, AnalysisFeedback, AnalysisDetail]
    ddl = "\n".join(
        str(CreateTable(model.__table__).compile(dialect=mssql.dialect()))
        for model in tables
    )
    assert "NVARCHAR(100)" in ddl
    assert "NVARCHAR(255)" in ddl
    assert "NVARCHAR(1000)" in ddl


def test_register_login_and_me(client: TestClient, test_engine):
    register = client.post(
        "/api/auth/register",
        json={"name": "Alice", "email": "Alice@Example.com", "password": "correct-horse"},
    )
    assert register.status_code == 201
    assert register.json()["email"] == "alice@example.com"
    assert "password" not in register.text.lower()

    with Session(test_engine) as session:
        saved_user = session.scalar(select(User).where(User.email == "alice@example.com"))
        assert saved_user is not None
        assert saved_user.password_hash != "correct-horse"
        assert saved_user.password_hash.startswith("$argon2")

    duplicate = client.post(
        "/api/auth/register",
        json={"name": "Alice", "email": "alice@example.com", "password": "correct-horse"},
    )
    assert duplicate.status_code == 409

    login = client.post(
        "/api/auth/login",
        json={"email": "alice@example.com", "password": "correct-horse"},
    )
    assert login.status_code == 200
    token = login.json()["accessToken"]
    me = client.get("/api/users/me", headers={"Authorization": f"Bearer {token}"})
    assert me.status_code == 200
    assert me.json()["name"] == "Alice"


def test_analysis_crud_and_progress(client: TestClient, auth_headers: dict[str, str]):
    first = client.post(
        "/api/analysis",
        headers=auth_headers,
        json={
            "skillName": "殺球",
            "totalScore": 72,
            "scores": [{"name": "架拍", "score": 75}],
            "goodPoints": ["手臂伸展良好"],
            "problems": ["下肢準備不足"],
            "suggestions": ["保持膝蓋彈性"],
            "details": {"手肘角度": "108.5°"},
            "analyzedAt": "2026-09-01T10:00:00",
        },
    )
    assert first.status_code == 201
    first_id = first.json()["analysisId"]

    second = client.post(
        "/api/analysis",
        headers=auth_headers,
        json={
            "skillName": "殺球",
            "totalScore": 85,
            "analyzedAt": "2026-09-11T10:00:00",
        },
    )
    assert second.status_code == 201

    listing = client.get("/api/analysis?skill=殺球&page=1&pageSize=20", headers=auth_headers)
    assert listing.status_code == 200
    assert listing.json()["total"] == 2
    assert listing.json()["items"][0]["totalScore"] == 85

    detail = client.get(f"/api/analysis/{first_id}", headers=auth_headers)
    assert detail.status_code == 200
    assert detail.json()["details"]["手肘角度"] == "108.5°"

    progress = client.get("/api/progress/殺球", headers=auth_headers)
    assert progress.status_code == 200
    assert progress.json()["latestScore"] == 85
    assert progress.json()["previousScore"] == 72
    assert progress.json()["change"] == 13
    assert progress.json()["bestScore"] == 85

    deleted = client.delete(f"/api/analysis/{first_id}", headers=auth_headers)
    assert deleted.status_code == 204
    assert client.get(f"/api/analysis/{first_id}", headers=auth_headers).status_code == 404


def test_user_cannot_access_another_users_record(client: TestClient, auth_headers: dict[str, str]):
    created = client.post(
        "/api/analysis",
        headers=auth_headers,
        json={"skillName": "高遠球", "totalScore": 80},
    )
    analysis_id = created.json()["analysisId"]

    client.post(
        "/api/auth/register",
        json={"name": "Other", "email": "other@example.com", "password": "other-pass-123"},
    )
    login = client.post(
        "/api/auth/login",
        json={"email": "other@example.com", "password": "other-pass-123"},
    )
    other_headers = {"Authorization": f"Bearer {login.json()['accessToken']}"}

    assert client.get(f"/api/analysis/{analysis_id}", headers=other_headers).status_code == 404
    assert client.delete(f"/api/analysis/{analysis_id}", headers=other_headers).status_code == 404
