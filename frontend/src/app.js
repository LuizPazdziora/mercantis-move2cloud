const API_BASE_URL = window.MERCANTIS_API_BASE_URL || "/api";

const state = {
  health: null,
  dbHealth: null,
  products: [],
  orders: [],
  loading: {
    status: false,
    products: false,
    orders: false,
    productSubmit: false,
    orderSubmit: false,
  },
};

const elements = {
  apiCard: document.querySelector("#api-card"),
  dbCard: document.querySelector("#db-card"),
  apiStatus: document.querySelector("#api-status"),
  apiDetail: document.querySelector("#api-detail"),
  dbStatus: document.querySelector("#db-status"),
  dbDetail: document.querySelector("#db-detail"),
  productsCount: document.querySelector("#products-count"),
  ordersCount: document.querySelector("#orders-count"),
  ordersTotal: document.querySelector("#orders-total"),
  stockTotal: document.querySelector("#stock-total"),
  productsTable: document.querySelector("#products-table"),
  ordersTable: document.querySelector("#orders-table"),
  productsLoading: document.querySelector("#products-loading"),
  ordersLoading: document.querySelector("#orders-loading"),
  productForm: document.querySelector("#product-form"),
  orderForm: document.querySelector("#order-form"),
  productSearch: document.querySelector("#product-search"),
  productStatusFilter: document.querySelector("#product-status-filter"),
  orderProduct: document.querySelector("#order-product"),
  orderQuantity: document.querySelector("#order-quantity"),
  orderTotalPreview: document.querySelector("#order-total-preview"),
  productSubmitButton: document.querySelector("#product-submit-button"),
  orderSubmitButton: document.querySelector("#order-submit-button"),
  refreshAllButton: document.querySelector("#refresh-all-button"),
  reloadProductsButton: document.querySelector("#reload-products-button"),
  reloadOrdersButton: document.querySelector("#reload-orders-button"),
  toastRegion: document.querySelector("#toast-region"),
};

function normalizeDocumentationLinks() {
  const legacyDocsUrl = `http://${["localhost", "8000"].join(":")}/docs`;

  document.querySelectorAll(`a[href="${legacyDocsUrl}"]`).forEach((link) => {
    link.setAttribute("href", "/docs");
  });
}

function normalizeEnvironmentCopy() {
  const environmentTitle = document.querySelector(".environment-card strong");
  const environmentDetail = document.querySelector(".environment-card small");
  const overviewEyebrow = document.querySelector("#visao-geral .eyebrow");
  const overviewBadge = document.querySelector("#visao-geral .status-badge");
  const flow = document.querySelector(".architecture-flow");
  const flowDetails = document.querySelectorAll(".architecture-flow .flow-node small");
  const productFormDetail = document.querySelector("#product-form .form-title span");

  if (environmentTitle) {
    environmentTitle.textContent = "Ambiente AWS de Desenvolvimento";
  }

  if (environmentDetail) {
    environmentDetail.textContent = "ALB + EC2 privada + RDS";
  }

  if (overviewEyebrow) {
    overviewEyebrow.textContent = "Arquitetura AWS do MVP";
  }

  if (overviewBadge) {
    overviewBadge.textContent = "Infraestrutura provisionada com Terraform";
  }

  if (flow) {
    flow.setAttribute("aria-label", "Fluxo técnico AWS");
  }

  ["Nginx na EC2", "proxy /api", "RDS privado"].forEach((label, index) => {
    if (flowDetails[index]) {
      flowDetails[index].textContent = label;
    }
  });

  if (productFormDetail) {
    productFormDetail.textContent = "Dados fictícios para validação do MVP";
  }
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function formatCurrency(value) {
  const numberValue = Number(value || 0);
  return numberValue.toLocaleString("pt-BR", {
    style: "currency",
    currency: "BRL",
  });
}

function formatDate(value) {
  if (!value) {
    return "-";
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return "-";
  }

  return date.toLocaleString("pt-BR", {
    dateStyle: "short",
    timeStyle: "short",
  });
}

function showToast(message, type = "info") {
  const toast = document.createElement("div");
  toast.className = `toast toast-${type}`;
  toast.textContent = message;
  elements.toastRegion.appendChild(toast);

  window.setTimeout(() => {
    toast.remove();
  }, 4200);
}

function setLoading(key, isLoading) {
  state.loading[key] = isLoading;

  elements.productsLoading.hidden = !state.loading.products;
  elements.ordersLoading.hidden = !state.loading.orders;
  elements.productSubmitButton.disabled = state.loading.productSubmit;
  elements.orderSubmitButton.disabled = state.loading.orderSubmit;
  elements.reloadProductsButton.disabled = state.loading.products;
  elements.reloadOrdersButton.disabled = state.loading.orders;
  elements.refreshAllButton.disabled =
    state.loading.status || state.loading.products || state.loading.orders;

  elements.productSubmitButton.textContent = state.loading.productSubmit
    ? "Cadastrando..."
    : "Cadastrar produto";
  elements.orderSubmitButton.textContent = state.loading.orderSubmit
    ? "Cadastrando..."
    : "Cadastrar pedido";
}

async function requestJson(path, options = {}) {
  try {
    const response = await fetch(`${API_BASE_URL}${path}`, {
      headers: {
        "Content-Type": "application/json",
        ...(options.headers || {}),
      },
      ...options,
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    if (response.status === 204) {
      return null;
    }

    return response.json();
  } catch (error) {
    throw new Error("Não foi possível concluir a requisição.");
  }
}

function setCardState(card, status) {
  card.dataset.status = status;
}

function renderStatusCards() {
  const apiOnline = state.health?.status === "ok";
  const dbOnline = state.dbHealth?.status === "ok";
  const ordersTotal = state.orders.reduce((sum, order) => sum + Number(order.total_value || 0), 0);
  const stockTotal = state.products.reduce(
    (sum, product) => sum + Number(product.stock_quantity || 0),
    0,
  );

  elements.apiStatus.textContent = apiOnline ? "Online" : "Offline";
  elements.apiDetail.textContent = apiOnline ? "Backend FastAPI disponível" : "API fora do ar";
  elements.dbStatus.textContent = dbOnline ? "Conectado" : "Indisponível";
  elements.dbDetail.textContent = dbOnline ? "MariaDB respondeu ao teste" : "Banco indisponível";
  elements.productsCount.textContent = state.products.length.toString();
  elements.ordersCount.textContent = state.orders.length.toString();
  elements.ordersTotal.textContent = formatCurrency(ordersTotal);
  elements.stockTotal.textContent = stockTotal.toString();

  setCardState(elements.apiCard, apiOnline ? "success" : "error");
  setCardState(elements.dbCard, dbOnline ? "success" : "warning");
}

async function fetchHealth() {
  setLoading("status", true);
  try {
    state.health = await requestJson("/health");
  } catch (error) {
    state.health = { status: "error" };
    showToast("API indisponível. Confirme se o backend está em execução.", "error");
  } finally {
    setLoading("status", false);
    renderStatusCards();
  }
}

async function fetchDbHealth() {
  setLoading("status", true);
  try {
    state.dbHealth = await requestJson("/db-health");
  } catch (error) {
    state.dbHealth = { status: "error" };
    showToast("Banco indisponível. Verifique o MariaDB configurado.", "warning");
  } finally {
    setLoading("status", false);
    renderStatusCards();
  }
}

async function fetchProducts(showSuccess = false) {
  setLoading("products", true);
  try {
    state.products = await requestJson("/products");
    renderProducts();
    renderProductOptions();
    renderOrderTotalPreview();
    renderStatusCards();
    if (showSuccess) {
      showToast("Produtos atualizados.", "success");
    }
  } catch (error) {
    elements.productsTable.innerHTML =
      '<tr><td colspan="6">Falha ao carregar produtos. Tente novamente.</td></tr>';
    showToast("Falha ao carregar produtos.", "error");
  } finally {
    setLoading("products", false);
  }
}

async function fetchOrders(showSuccess = false) {
  setLoading("orders", true);
  try {
    state.orders = await requestJson("/orders");
    renderOrders();
    renderStatusCards();
    if (showSuccess) {
      showToast("Pedidos atualizados.", "success");
    }
  } catch (error) {
    elements.ordersTable.innerHTML =
      '<tr><td colspan="6">Falha ao carregar pedidos. Tente novamente.</td></tr>';
    showToast("Falha ao carregar pedidos.", "error");
  } finally {
    setLoading("orders", false);
  }
}

function getFilteredProducts() {
  const search = elements.productSearch.value.trim().toLowerCase();
  const statusFilter = elements.productStatusFilter.value;

  return state.products.filter((product) => {
    const matchesSearch =
      !search ||
      product.name.toLowerCase().includes(search) ||
      product.category.toLowerCase().includes(search);
    const matchesStatus =
      statusFilter === "all" ||
      (statusFilter === "active" && product.is_active) ||
      (statusFilter === "inactive" && !product.is_active);

    return matchesSearch && matchesStatus;
  });
}

function renderProducts() {
  const filteredProducts = getFilteredProducts();

  if (filteredProducts.length === 0) {
    elements.productsTable.innerHTML =
      '<tr><td colspan="6">Nenhum produto encontrado para os filtros atuais.</td></tr>';
    return;
  }

  elements.productsTable.innerHTML = filteredProducts
    .map(
      (product) => `
        <tr>
          <td>
            <strong>${escapeHtml(product.name)}</strong>
            <small>ID ${product.id}</small>
          </td>
          <td>${escapeHtml(product.category)}</td>
          <td>${formatCurrency(product.price)}</td>
          <td>${Number(product.stock_quantity || 0)}</td>
          <td>
            <span class="status-badge ${product.is_active ? "status-badge-success" : "status-badge-neutral"}">
              ${product.is_active ? "Ativo" : "Inativo"}
            </span>
          </td>
          <td>${formatDate(product.created_at)}</td>
        </tr>
      `,
    )
    .join("");
}

function renderProductOptions() {
  const activeProducts = state.products.filter((product) => product.is_active);

  if (activeProducts.length === 0) {
    elements.orderProduct.innerHTML = '<option value="">Nenhum produto ativo disponível</option>';
    return;
  }

  elements.orderProduct.innerHTML = [
    '<option value="">Selecione um produto</option>',
    ...activeProducts.map(
      (product) =>
        `<option value="${product.id}" data-price="${Number(product.price)}">${escapeHtml(
          product.name,
        )} - ${formatCurrency(product.price)}</option>`,
    ),
  ].join("");
}

function renderOrders() {
  if (state.orders.length === 0) {
    elements.ordersTable.innerHTML = '<tr><td colspan="6">Nenhum pedido cadastrado.</td></tr>';
    return;
  }

  elements.ordersTable.innerHTML = state.orders
    .map(
      (order) => `
        <tr>
          <td>
            <strong>${escapeHtml(order.customer_name)}</strong>
            <small>Pedido ${order.id}</small>
          </td>
          <td>${order.product_id}</td>
          <td>${Number(order.quantity || 0)}</td>
          <td>${formatCurrency(order.total_value)}</td>
          <td><span class="status-badge status-badge-success">${escapeHtml(order.status)}</span></td>
          <td>${formatDate(order.created_at)}</td>
        </tr>
      `,
    )
    .join("");
}

function renderOrderTotalPreview() {
  const selectedOption = elements.orderProduct.selectedOptions[0];
  const price = Number(selectedOption?.dataset.price || 0);
  const quantity = Number(elements.orderQuantity.value || 0);
  elements.orderTotalPreview.textContent = formatCurrency(price * quantity);
}

function validateProductPayload(payload) {
  if (!payload.name || !payload.category) {
    return "Nome e categoria são obrigatórios.";
  }

  if (Number.isNaN(payload.price) || payload.price <= 0) {
    return "O preço deve ser maior que zero.";
  }

  if (Number.isNaN(payload.stock_quantity) || payload.stock_quantity < 0) {
    return "O estoque não pode ser negativo.";
  }

  return null;
}

function validateOrderPayload(payload) {
  if (!payload.customer_name || !payload.product_id || !payload.status) {
    return "Cliente, produto e status são obrigatórios.";
  }

  if (Number.isNaN(payload.quantity) || payload.quantity <= 0) {
    return "A quantidade deve ser maior que zero.";
  }

  return null;
}

async function handleProductSubmit(event) {
  event.preventDefault();

  const formData = new FormData(elements.productForm);
  const payload = {
    name: formData.get("name").trim(),
    category: formData.get("category").trim(),
    price: Number(formData.get("price")),
    stock_quantity: Number(formData.get("stock_quantity")),
    is_active: formData.get("is_active") === "on",
  };

  const validationError = validateProductPayload(payload);
  if (validationError) {
    showToast(validationError, "warning");
    return;
  }

  setLoading("productSubmit", true);
  try {
    await requestJson("/products", {
      method: "POST",
      body: JSON.stringify(payload),
    });
    elements.productForm.reset();
    document.querySelector("#product-active").checked = true;
    await fetchProducts();
    showToast("Produto cadastrado com sucesso.", "success");
  } catch (error) {
    showToast("Falha ao cadastrar produto. Revise os dados e tente novamente.", "error");
  } finally {
    setLoading("productSubmit", false);
  }
}

async function handleOrderSubmit(event) {
  event.preventDefault();

  const formData = new FormData(elements.orderForm);
  const payload = {
    customer_name: formData.get("customer_name").trim(),
    product_id: Number(formData.get("product_id")),
    quantity: Number(formData.get("quantity")),
    status: formData.get("status").trim(),
  };

  const validationError = validateOrderPayload(payload);
  if (validationError) {
    showToast(validationError, "warning");
    return;
  }

  setLoading("orderSubmit", true);
  try {
    await requestJson("/orders", {
      method: "POST",
      body: JSON.stringify(payload),
    });
    elements.orderForm.reset();
    document.querySelector("#order-quantity").value = "1";
    document.querySelector("#order-status").value = "created";
    renderOrderTotalPreview();
    await fetchOrders();
    showToast("Pedido cadastrado com sucesso.", "success");
  } catch (error) {
    showToast("Falha ao cadastrar pedido. Confirme o produto e tente novamente.", "error");
  } finally {
    setLoading("orderSubmit", false);
  }
}

async function refreshDashboard(showSuccess = false) {
  await Promise.all([fetchHealth(), fetchDbHealth(), fetchProducts(), fetchOrders()]);
  if (showSuccess) {
    showToast("Dashboard atualizado.", "success");
  }
}

elements.productForm.addEventListener("submit", handleProductSubmit);
elements.orderForm.addEventListener("submit", handleOrderSubmit);
elements.productSearch.addEventListener("input", renderProducts);
elements.productStatusFilter.addEventListener("change", renderProducts);
elements.orderProduct.addEventListener("change", renderOrderTotalPreview);
elements.orderQuantity.addEventListener("input", renderOrderTotalPreview);
elements.reloadProductsButton.addEventListener("click", () => fetchProducts(true));
elements.reloadOrdersButton.addEventListener("click", () => fetchOrders(true));
elements.refreshAllButton.addEventListener("click", () => refreshDashboard(true));

normalizeDocumentationLinks();
normalizeEnvironmentCopy();
refreshDashboard();
