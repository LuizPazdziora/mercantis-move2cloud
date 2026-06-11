INSERT INTO products (id, name, category, price, stock_quantity, is_active)
VALUES
  (1, 'Notebook Mercantis Pro', 'Informática', 5199.90, 8, TRUE),
  (2, 'Monitor Mercantis 27', 'Informática', 1499.90, 15, TRUE),
  (3, 'Cadeira Operacional', 'Escritório', 899.90, 20, TRUE)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  category = VALUES(category),
  price = VALUES(price),
  stock_quantity = VALUES(stock_quantity),
  is_active = VALUES(is_active);

INSERT INTO orders (id, customer_name, product_id, quantity, total_value, status)
VALUES
  (1, 'Cliente Demonstrativo', 2, 1, 1499.90, 'created')
ON DUPLICATE KEY UPDATE
  customer_name = VALUES(customer_name),
  product_id = VALUES(product_id),
  quantity = VALUES(quantity),
  total_value = VALUES(total_value),
  status = VALUES(status);
