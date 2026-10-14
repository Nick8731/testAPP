from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy.engine import URL


class Settings(BaseSettings):
    app_env: str = "development"
    jwt_secret: str = Field(min_length=16)
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = Field(default=1440, gt=0)
    api_cors_origins: str = ""
    db_backend: Literal["sqlite", "sqlserver"] = "sqlite"
    sqlite_path: str = "data/smashcoach.db"
    sqlite_backup_enabled: bool = True
    sqlite_backup_interval_minutes: int = Field(default=360, ge=1)
    sqlite_backup_dir: str = 'data/backups'
    db_server: str = "localhost"
    db_port: int | None = 1433
    db_name: str = "SmashCoach"
    db_user: str = ""
    db_password: str = ""
    db_driver: str = "ODBC Driver 18 for SQL Server"
    db_encrypt: str = "yes"
    db_trust_server_certificate: str = "yes"
    db_trusted_connection: bool = False

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    @property
    def database_url(self) -> URL:
        if self.db_backend == "sqlite":
            return URL.create(
                "sqlite+pysqlite",
                database=str(self.sqlite_database_path),
            )

        query = {
            "driver": self.db_driver,
            "Encrypt": self.db_encrypt,
            "TrustServerCertificate": self.db_trust_server_certificate,
        }
        if self.db_trusted_connection:
            query["Trusted_Connection"] = "yes"

        return URL.create(
            "mssql+pyodbc",
            username=None if self.db_trusted_connection else self.db_user,
            password=None if self.db_trusted_connection else self.db_password,
            host=self.db_server,
            port=None if "\\" in self.db_server else self.db_port,
            database=self.db_name,
            query=query,
        )

    @property
    def sqlite_database_path(self) -> Path | str:
        if self.sqlite_path == ":memory:":
            return ":memory:"
        path = Path(self.sqlite_path)
        if not path.is_absolute():
            path = Path(__file__).resolve().parents[2] / path
        return path.resolve()

    @property
    def cors_origins(self) -> list[str]:
        return [origin.strip() for origin in self.api_cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
