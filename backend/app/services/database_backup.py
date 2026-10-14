"""Verified SQLite snapshots; restore always creates a NEW file."""
from datetime import datetime, timezone
from pathlib import Path
import sqlite3
from uuid import uuid4

REQUIRED_TABLES = {'Users', 'AnalysisRecords', 'AnalysisScores', 'AnalysisFeedback', 'AnalysisDetails'}


def check_database(path: Path) -> dict[str, int]:
    with sqlite3.connect(path.resolve().as_uri() + '?mode=ro', uri=True) as db:
        if db.execute('PRAGMA integrity_check').fetchone()[0] != 'ok':
            raise ValueError('Database integrity check failed')
        if db.execute('PRAGMA foreign_key_check').fetchall():
            raise ValueError('Database foreign key check failed')
        tables = {row[0] for row in db.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        if not REQUIRED_TABLES <= tables:
            raise ValueError('Not a SmashCoach database')
        return {table: db.execute('SELECT COUNT(*) FROM ' + table).fetchone()[0]
                for table in sorted(REQUIRED_TABLES)}


def copy_snapshot(source: Path, target: Path) -> Path:
    source, target = source.resolve(), target.resolve()
    if source == target or target.exists():
        raise ValueError('Restore/backup target must be a new file; existing data is never overwritten')
    if target.suffix.lower() != '.db':
        raise ValueError('Target must be a .db file')
    check_database(source)
    target.parent.mkdir(parents=True, exist_ok=True)
    # Exclusive creation avoids accidentally replacing a concurrent backup.
    with target.open('xb'):
        pass
    try:
        with sqlite3.connect(source.as_uri() + '?mode=ro', uri=True) as src:
            with sqlite3.connect(target) as dst:
                src.backup(dst)
        check_database(target)
        return target
    except Exception:
        # Only our newly created incomplete file is removed.
        target.unlink(missing_ok=True)
        raise


def backup_database(source: Path, directory: Path) -> Path:
    name = 'smashcoach-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '-' + uuid4().hex[:8] + '.db'
    return copy_snapshot(source, directory / name)


def restore_database(source: Path, target: Path) -> Path:
    return copy_snapshot(source, target)


def configured_backup(settings) -> Path | None:
    if settings.db_backend != 'sqlite' or settings.sqlite_database_path == ':memory:':
        return None
    directory = Path(settings.sqlite_backup_dir)
    if not directory.is_absolute():
        directory = Path(__file__).resolve().parents[2] / directory
    return backup_database(settings.sqlite_database_path, directory)
