const statusElement = document.querySelector("#api-status");

async function checkApiHealth() {
  try {
    const response = await fetch("http://localhost:8000/health");
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();
    statusElement.textContent = `API ${data.service}: ${data.status}`;
  } catch (error) {
    statusElement.textContent = "API indisponível no momento";
  }
}

checkApiHealth();
