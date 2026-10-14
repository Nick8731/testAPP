"""Run from backend: python scripts/manage_database.py backup|check|restore."""
import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from app.core.config import get_settings
from app.services.database_backup import configured_backup, check_database, restore_database


def main():
    parser = argparse.ArgumentParser(description='Verified SQLite backup and non-overwriting restore')
    parser.add_argument('action', choices=['backup', 'check', 'restore'])
    parser.add_argument('--source', type=Path)
    parser.add_argument('--target', type=Path)
    args = parser.parse_args()
    settings = get_settings()
    if settings.db_backend != 'sqlite' or settings.sqlite_database_path == ':memory:':
        parser.error('This utility requires file-backed SQLite')
    if args.action == 'backup':
        print(configured_backup(settings))
    elif args.action == 'check':
        print(json.dumps(check_database(args.source or settings.sqlite_database_path)))
    else:
        if args.source is None or args.target is None:
            parser.error('restore requires --source and --target (a NEW .db file)')
        print(restore_database(args.source, args.target))


if __name__ == '__main__':
    main()
