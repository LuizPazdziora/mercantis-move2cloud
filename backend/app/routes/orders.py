from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app import crud
from app.database import get_db
from app.schemas import OrderCreate, OrderRead, OrderUpdate

router = APIRouter(prefix="/orders", tags=["orders"])


@router.get("", response_model=list[OrderRead])
def list_orders(db: Session = Depends(get_db)) -> list[OrderRead]:
    # Lista pedidos persistidos no MariaDB.
    return crud.list_orders(db)


@router.get("/{order_id}", response_model=OrderRead)
def get_order(order_id: int, db: Session = Depends(get_db)) -> OrderRead:
    db_order = crud.get_order(db, order_id)
    if db_order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pedido não encontrado.",
        )
    return db_order


@router.post("", response_model=OrderRead, status_code=status.HTTP_201_CREATED)
def create_order(order: OrderCreate, db: Session = Depends(get_db)) -> OrderRead:
    product = crud.get_product(db, order.product_id)
    if product is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Produto informado no pedido não existe.",
        )

    total_value = crud.calculate_order_total(product, order.quantity)
    return crud.create_order(db, order, total_value)


@router.put("/{order_id}", response_model=OrderRead)
def update_order(
    order_id: int,
    order: OrderUpdate,
    db: Session = Depends(get_db),
) -> OrderRead:
    db_order = crud.get_order(db, order_id)
    if db_order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pedido não encontrado.",
        )

    next_product_id = order.product_id if order.product_id is not None else db_order.product_id
    product = crud.get_product(db, next_product_id)
    if product is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Produto informado no pedido não existe.",
        )

    next_quantity = order.quantity if order.quantity is not None else db_order.quantity
    total_value = crud.calculate_order_total(product, next_quantity)
    return crud.update_order(db, db_order, order, total_value)


@router.delete("/{order_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_order(order_id: int, db: Session = Depends(get_db)) -> Response:
    db_order = crud.get_order(db, order_id)
    if db_order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pedido não encontrado.",
        )

    crud.delete_order(db, db_order)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
