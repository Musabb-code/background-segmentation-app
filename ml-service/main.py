from contextlib import asynccontextmanager

from fastapi import FastAPI

from api.routes import router
from inference.engine import load_model


@asynccontextmanager
async def lifespan(_app: FastAPI):
    load_model()
    yield


app = FastAPI(
    title="MACKHAN ML Service",
    version="1.0.0",
    description="HQ capture API for mobile/ app",
    lifespan=lifespan,
)
app.include_router(router)
