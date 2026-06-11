from fastapi import APIRouter

router = APIRouter(prefix="/products", tags=["products"])


@router.get("/")
def list_products() -> dict[str, object]:
    return {
        "items": [],
        "message": "Endpoint reservado para o catálogo simplificado do MVP.",
    }
