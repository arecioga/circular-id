const planButtons = [...document.querySelectorAll("[data-select-plan]")];
const cart = document.querySelector("[data-cart]");
const cartEmpty = document.querySelector("[data-cart-empty]");
const cartContent = document.querySelector("[data-cart-content]");
const cartCount = document.querySelector("[data-cart-count]");
const cartPlan = document.querySelector("[data-cart-plan]");
const cartUnits = document.querySelector("[data-cart-units]");
const cartSubtotal = document.querySelector("[data-cart-subtotal]");
const cartShipping = document.querySelector("[data-cart-shipping]");
const cartTotal = document.querySelector("[data-cart-total]");

const euro = new Intl.NumberFormat("es-ES", {
  style: "currency",
  currency: "EUR",
  minimumFractionDigits: 0,
});

let selectedPlan = null;

const renderCart = () => {
  const hasPlan = Boolean(selectedPlan);
  if (cartEmpty) cartEmpty.hidden = hasPlan;
  if (cartContent) cartContent.hidden = !hasPlan;
  if (cartCount) cartCount.textContent = hasPlan ? "1 servicio" : "0 servicios";
  if (!selectedPlan) return;

  cartPlan.textContent = `Plan ${selectedPlan.name}`;
  cartUnits.textContent = `${selectedPlan.units} etiquetas de demostración`;
  cartSubtotal.textContent = euro.format(selectedPlan.price);
  cartShipping.textContent = selectedPlan.shipping === 0 ? "Incluido" : euro.format(selectedPlan.shipping);
  cartTotal.textContent = euro.format(selectedPlan.price + selectedPlan.shipping);
};

planButtons.forEach((button) => {
  button.addEventListener("click", () => {
    selectedPlan = {
      name: button.dataset.plan,
      price: Number(button.dataset.price),
      shipping: Number(button.dataset.shipping),
      units: Number(button.dataset.units),
    };
    renderCart();
    window.circularIDShowToast?.(`Plan ${selectedPlan.name} añadido al simulador.`);
    cart?.scrollIntoView({ behavior: "smooth", block: "center" });
  });
});

document.querySelector("[data-cart-remove]")?.addEventListener("click", () => {
  selectedPlan = null;
  renderCart();
  window.circularIDShowToast?.("Plan eliminado del simulador.");
});

document.querySelector("[data-cart-checkout]")?.addEventListener("click", () => {
  if (!selectedPlan) return;
  window.circularIDShowToast?.("Solicitud simulada preparada. No se ha realizado ningún cargo.");
});

renderCart();
