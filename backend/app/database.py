import os
from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.orm import Session, declarative_base, sessionmaker


def build_database_url() -> str | URL:
    # A conexão usa variáveis de ambiente para evitar credenciais no código-fonte.
    database_url = os.getenv("DATABASE_URL")
    if database_url:
        return database_url

    return URL.create(
        drivername="mysql+pymysql",
        username=os.getenv("DB_USER", "mercantis_app"),
        password=os.getenv("DB_PASSWORD", ""),
        host=os.getenv("DB_HOST", "database"),
        port=int(os.getenv("DB_PORT", "3306")),
        database=os.getenv("DB_NAME", "mercantis"),
        query={"charset": "utf8mb4"},
    )


DATABASE_URL = build_database_url()
IS_MYSQL = str(DATABASE_URL).startswith("mysql")

# pool_pre_ping evita reutilizar conexões encerradas pelo MariaDB.
# Os connect_args do PyMySQL só se aplicam ao MariaDB (os testes usam SQLite).
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=300,
    connect_args={"connect_timeout": 5, "charset": "utf8mb4"} if IS_MYSQL else {},
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db() -> Generator[Session, None, None]:
    # Dependência usada pelos endpoints para abrir e fechar sessões por requisição.
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
