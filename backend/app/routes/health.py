from fastapi import APIRouter, Response, status
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from app.database import engine
from app.schemas import DatabaseHealthResponse, HealthResponse

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthResponse)
def health_check() -> HealthResponse:
    # Endpoint leve para validar se a aplicação FastAPI está respondendo.
    return HealthResponse(
        status="ok",
        service="mercantis-backend",
    )


@router.get("/db-health", response_model=DatabaseHealthResponse)
def database_health_check(response: Response) -> DatabaseHealthResponse:
    # Executa uma consulta real e simples para validar a conectividade com o MariaDB.
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
    except SQLAlchemyError:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return DatabaseHealthResponse(
            status="error",
            service="mariadb",
            detail="Banco de dados indisponível ou conexão recusada.",
        )

    return DatabaseHealthResponse(
        status="ok",
        service="mariadb",
        detail="Conexão com o banco validada.",
    )
