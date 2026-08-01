from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    model_type: str
    version: str


class BenchmarkRequest(BaseModel):
    iterations: int = Field(default=10, ge=1, le=100)
    image_path: str | None = None


class BenchmarkResponse(BaseModel):
    iterations: int
    avg_latency_ms: float
    fps: float
    p95_latency_ms: float
