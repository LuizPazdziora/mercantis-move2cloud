import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import health, orders, products

app = FastAPI(
    title="Mercantis Move2Cloud API",
    version="0.2.0",
    description="API funcional mínima do MVP Mercantis Move2Cloud.",
)

allowed_origins = [
    origin.strip()
    for origin in os.getenv("ALLOWED_ORIGINS", "http://localhost:8080").split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type"],
)

app.include_router(health.router)
app.include_router(products.router)
app.include_router(orders.router)


@app.get("/", tags=["root"])
def root() -> dict[str, str]:
    return {
        "service": "mercantis-backend",
        "status": "ok",
    }
