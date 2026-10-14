from pathlib import Path

import pytest
from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session

from app.db.base import Base
from app.models.user import User
from app.models.analysis import AnalysisRecord
from app.services.database_backup import backup_database, restore_database, check_database


def test_trim_validation(client):
    base = {'name': 'Player', 'email': 'trim@example.com', 'password': 'secure-password'}
    assert client.post('/api/auth/register', json={**base, 'name': '   '}).status_code == 422
    assert client.post('/api/auth/register', json={**base, 'name': '  教練  '}).json()['name'] == '教練'


def test_blank_analysis_fields(client, auth_headers):
    for payload in [
        {'skillName': '   ', 'totalScore': 80},
        {'skillName': '高遠球', 'totalScore': 80, 'scores': [{'name': '   ', 'score': 80}]},
    ]:
        assert client.post('/api/analysis', headers=auth_headers, json=payload).status_code == 422


def test_versions_are_separate(client, auth_headers):
    for version, score in [('pose-still-v2', 60), ('pose-phase-v3', 84), ('pose-phase-v3', 85)]:
        assert client.post('/api/analysis', headers=auth_headers, json={
            'skillName': '高遠球', 'totalScore': score,
            'details': {'評分版本': version},
        }).status_code == 201
    latest = client.get('/api/progress/高遠球', headers=auth_headers).json()
    assert latest['selectedVersion'] == 'pose-phase-v3'
    assert latest['change'] == 1
    assert latest['bestScore'] == 85
    assert len(latest['records']) == 2
    older = client.get('/api/progress/高遠球?version=pose-still-v2', headers=auth_headers).json()
    assert older['latestScore'] == 60 and older['change'] is None
    unknown = client.get('/api/progress/高遠球?version=no-such-version', headers=auth_headers).json()
    assert unknown['records'] == []
    assert client.get('/api/analysis', headers=auth_headers).json()['total'] == 3


def test_legacy_record_is_preserved(client, auth_headers):
    client.post('/api/analysis', headers=auth_headers, json={'skillName': '挑球', 'totalScore': 70})
    data = client.get('/api/progress/挑球', headers=auth_headers).json()
    assert data['selectedVersion'] == 'legacy-unknown'
    assert data['latestScore'] == 70


def test_history_over_100(client, auth_headers, test_engine):
    with Session(test_engine) as db:
        user_id = db.scalar(select(User.id))
        db.add_all([AnalysisRecord(user_id=user_id, skill_name='平球', total_score=80) for _ in range(101)])
        db.commit()
    first = client.get('/api/analysis?page=1&pageSize=100', headers=auth_headers).json()
    second = client.get('/api/analysis?page=2&pageSize=100', headers=auth_headers).json()
    assert first['total'] == 101 and len(first['items']) == 100
    assert len(second['items']) == 1
    assert not {r['analysisId'] for r in first['items']} & {r['analysisId'] for r in second['items']}


def test_verified_backup_and_restore(tmp_path):
    source = tmp_path / 'original.db'
    engine = create_engine('sqlite:///' + str(source))
    Base.metadata.create_all(engine)
    with Session(engine) as db:
        db.add(User(name='測試', email='backup@example.com', password_hash='test-only-hash'))
        db.commit()
    engine.dispose()
    before = check_database(source)
    backup = backup_database(source, tmp_path / 'backups')
    restored = restore_database(backup, tmp_path / 'restored.db')
    assert check_database(restored) == before == check_database(source)
    with pytest.raises(ValueError):
        restore_database(backup, source)
    with pytest.raises(ValueError):
        restore_database(source, source)
    assert check_database(source) == before


def test_invalid_backup_cannot_restore(tmp_path):
    invalid = tmp_path / 'invalid.db'
    invalid.write_bytes(b'not-a-database')
    target = tmp_path / 'new.db'
    with pytest.raises(Exception):
        restore_database(invalid, target)
    assert not target.exists()
