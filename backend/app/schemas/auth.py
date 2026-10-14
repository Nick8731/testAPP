from datetime import datetime

from pydantic import EmailStr, Field, field_validator

from app.schemas.common import ApiModel


class RegisterRequest(ApiModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

    @field_validator('name', mode='before')
    @classmethod
    def normalize_name(cls, value):
        return value.strip() if isinstance(value, str) else value


class LoginRequest(ApiModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class TokenResponse(ApiModel):
    access_token: str = Field(serialization_alias="accessToken")
    token_type: str = Field(default="bearer", serialization_alias="tokenType")


class UserResponse(ApiModel):
    id: int = Field(serialization_alias="userId")
    name: str
    email: EmailStr
    created_at: datetime = Field(serialization_alias="createdAt")
