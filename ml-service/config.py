from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    port: int = 8000
    model_type: str = "modnet"
    model_path: str = "./models/modnet"
    jwt_secret: str = ""
    max_image_size_mb: int = 10
    inference_timeout_sec: int = 30
    log_level: str = "INFO"


settings = Settings()
