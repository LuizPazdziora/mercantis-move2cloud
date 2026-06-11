from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class HealthResponse(BaseModel):
    status: str
    service: str


class DatabaseHealthResponse(BaseModel):
    status: str
    service: str
    detail: str | None = None


class ProductBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=120)
    category: str = Field(..., min_length=1, max_length=80)
    price: Decimal = Field(..., gt=Decimal("0"))
    stock_quantity: int = Field(..., ge=0)
    is_active: bool = True


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    category: str | None = Field(default=None, min_length=1, max_length=80)
    price: Decimal | None = Field(default=None, gt=Decimal("0"))
    stock_quantity: int | None = Field(default=None, ge=0)
    is_active: bool | None = None


class ProductRead(ProductBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime


class OrderBase(BaseModel):
    customer_name: str = Field(..., min_length=1, max_length=120)
    product_id: int = Field(..., gt=0)
    quantity: int = Field(..., gt=0)
    status: str = Field(default="created", min_length=1, max_length=40)


class OrderCreate(OrderBase):
    pass


class OrderUpdate(BaseModel):
    customer_name: str | None = Field(default=None, min_length=1, max_length=120)
    product_id: int | None = Field(default=None, gt=0)
    quantity: int | None = Field(default=None, gt=0)
    status: str | None = Field(default=None, min_length=1, max_length=40)


class OrderRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    customer_name: str
    product_id: int
    quantity: int
    total_value: Decimal
    status: str
    created_at: datetime
