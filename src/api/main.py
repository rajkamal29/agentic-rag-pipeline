from fastapi import FastAPI

from src.api.routes import health_router

app = FastAPI(
    title="Agentic RAG API",
    version="0.1.0",
    description="Production-ready baseline API for Agentic RAG on Azure",
)

app.include_router(health_router, prefix="/api/v1")
