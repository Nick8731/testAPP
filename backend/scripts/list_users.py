"""List locally registered accounts without revealing password hashes."""

from __future__ import annotations

import argparse
import sqlite3
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parents[1]
DEFAULT_DATABASE = BACKEND_DIR / "data" / "smashcoach.db"


def main() -> None:
    parser = argparse.ArgumentParser(description="列出 SmashCoach SQLite 帳號")
    parser.add_argument("--database", type=Path, default=DEFAULT_DATABASE)
    args = parser.parse_args()
    database = args.database.resolve()

    if not database.exists():
        raise SystemExit(f"找不到資料庫：{database}\n請先啟動 FastAPI 後台。")

    with sqlite3.connect(database) as connection:
        table_exists = connection.execute(
            "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'Users'"
        ).fetchone()
        if table_exists is None:
            raise SystemExit("資料庫尚未建立 Users 資料表。")

        rows = connection.execute(
            'SELECT "UserId", "Name", "Email", "CreatedAt" '
            'FROM "Users" ORDER BY "UserId"'
        ).fetchall()

    if not rows:
        print("目前尚無註冊帳號。")
        return

    print(f"共 {len(rows)} 個帳號（不顯示密碼雜湊）：")
    for user_id, name, email, created_at in rows:
        print(f"- #{user_id} {name} <{email}>，建立時間：{created_at}")


if __name__ == "__main__":
    main()
