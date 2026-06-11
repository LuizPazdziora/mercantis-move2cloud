from sqlalchemy.orm import Session

from app import models


def list_active_products(db: Session) -> list[models.Product]:
    return db.query(models.Product).filter(models.Product.active.is_(True)).all()


def list_orders(db: Session) -> list[models.Order]:
    return db.query(models.Order).all()
