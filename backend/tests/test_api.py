PRODUTO = {"name": "Camiseta", "category": "Vestuário", "price": "49.90", "stock_quantity": 10}


def test_health(client):
    assert client.get("/health").json() == {"status": "ok", "service": "mercantis-backend"}


def test_db_health(client):
    resp = client.get("/db-health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


def test_crud_de_produto(client):
    criado = client.post("/products", json=PRODUTO)
    assert criado.status_code == 201
    produto_id = criado.json()["id"]

    assert client.get(f"/products/{produto_id}").json()["name"] == "Camiseta"

    atualizado = client.put(f"/products/{produto_id}", json={"price": "59.90"})
    assert atualizado.status_code == 200
    assert atualizado.json()["price"] == "59.90"

    assert client.delete(f"/products/{produto_id}").status_code == 204
    assert client.get(f"/products/{produto_id}").status_code == 404


def test_validacao_de_produto(client):
    resp = client.post("/products", json={**PRODUTO, "price": "0"})
    assert resp.status_code == 422


def test_pedido_calcula_total(client):
    produto_id = client.post("/products", json=PRODUTO).json()["id"]
    pedido = client.post("/orders", json={"customer_name": "Cliente Teste", "product_id": produto_id, "quantity": 3})
    assert pedido.status_code == 201
    assert pedido.json()["total_value"] == "149.70"

    alterado = client.put(f"/orders/{pedido.json()['id']}", json={"quantity": 1})
    assert alterado.json()["total_value"] == "49.90"


def test_pedido_com_produto_inexistente(client):
    resp = client.post("/orders", json={"customer_name": "X", "product_id": 999, "quantity": 1})
    assert resp.status_code == 400


def test_produto_com_pedido_nao_pode_ser_removido(client):
    produto_id = client.post("/products", json=PRODUTO).json()["id"]
    client.post("/orders", json={"customer_name": "X", "product_id": produto_id, "quantity": 1})
    assert client.delete(f"/products/{produto_id}").status_code == 409
