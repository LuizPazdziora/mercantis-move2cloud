from fastapi import APIRouter

router = APIRouter(prefix="/orders", tags=["orders"])


@router.get("/")
def list_orders() -> dict[str, object]:
    return {
        "items": [],
        "message": "Endpoint reservado para pedidos simulados do MVP.",
    }
