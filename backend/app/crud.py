from decimal import Decimal

from sqlalchemy.orm import Session

from app import models
from app.schemas import OrderCreate, OrderUpdate, ProductCreate, ProductUpdate


def list_products(db: Session) -> list[models.Product]:
    return db.query(models.Product).order_by(models.Product.id).all()


def get_product(db: Session, product_id: int) -> models.Product | None:
    return db.query(models.Product).filter(models.Product.id == product_id).first()


def create_product(db: Session, product: ProductCreate) -> models.Product:
    db_product = models.Product(**product.model_dump())
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product


def update_product(
    db: Session,
    db_product: models.Product,
    product: ProductUpdate,
) -> models.Product:
    update_data = product.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_product, field, value)

    db.commit()
    db.refresh(db_product)
    return db_product


def delete_product(db: Session, db_product: models.Product) -> None:
    db.delete(db_product)
    db.commit()


def list_orders(db: Session) -> list[models.Order]:
    return db.query(models.Order).order_by(models.Order.id).all()


def get_order(db: Session, order_id: int) -> models.Order | None:
    return db.query(models.Order).filter(models.Order.id == order_id).first()


def calculate_order_total(product: models.Product, quantity: int) -> Decimal:
    return Decimal(product.price) * quantity


def create_order(
    db: Session,
    order: OrderCreate,
    total_value: Decimal,
) -> models.Order:
    db_order = models.Order(
        customer_name=order.customer_name,
        product_id=order.product_id,
        quantity=order.quantity,
        total_value=total_value,
        status=order.status,
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return db_order


def update_order(
    db: Session,
    db_order: models.Order,
    order: OrderUpdate,
    total_value: Decimal,
) -> models.Order:
    update_data = order.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_order, field, value)

    db_order.total_value = total_value
    db.commit()
    db.refresh(db_order)
    return db_order


def delete_order(db: Session, db_order: models.Order) -> None:
    db.delete(db_order)
    db.commit()
