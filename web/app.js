const body = document.body;
const header = document.querySelector("[data-header]");
const navToggle = document.querySelector(".nav-toggle");
const mainNav = document.querySelector("#main-nav");
const toast = document.querySelector("[data-toast]");

const setHeaderState = () => {
  header?.classList.toggle("is-scrolled", window.scrollY > 18);
};

setHeaderState();
window.addEventListener("scroll", setHeaderState, { passive: true });

navToggle?.addEventListener("click", () => {
  const open = navToggle.getAttribute("aria-expanded") === "true";
  navToggle.setAttribute("aria-expanded", String(!open));
  body.classList.toggle("nav-open", !open);
  navToggle.querySelector(".sr-only").textContent = open ? "Abrir menú" : "Cerrar menú";
});

mainNav?.addEventListener("click", (event) => {
  if (event.target.closest("a")) {
    navToggle?.setAttribute("aria-expanded", "false");
    body.classList.remove("nav-open");
  }
});

const scanButton = document.querySelector("[data-scan-button]");
const scanState = document.querySelector("[data-scan-state]");
const statusLabel = document.querySelector("[data-status-label]");
const buttonLabel = document.querySelector("[data-button-label]");

scanButton?.addEventListener("click", () => {
  if (scanState.dataset.scanState === "scanning") return;

  if (scanState.dataset.scanState === "verified") {
    scanState.dataset.scanState = "ready";
    statusLabel.textContent = "Listo para comprobar";
    buttonLabel.textContent = "Simular escaneo";
    return;
  }

  scanState.dataset.scanState = "scanning";
  statusLabel.textContent = "Consultando registro";
  buttonLabel.textContent = "Comprobando…";

  window.setTimeout(() => {
    scanState.dataset.scanState = "verified";
    statusLabel.textContent = "Producto verificado";
    buttonLabel.textContent = "Reiniciar demostración";
  }, 950);
});

document.querySelectorAll("[data-tabs]").forEach((tabs) => {
  const buttons = [...tabs.querySelectorAll('[role="tab"]')];
  const panels = [...tabs.querySelectorAll('[role="tabpanel"]')];

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      buttons.forEach((item) => item.setAttribute("aria-selected", String(item === button)));
      panels.forEach((panel) => {
        panel.hidden = panel.id !== button.getAttribute("aria-controls");
      });
    });
  });
});

let toastTimer;
const showToast = (message) => {
  if (!toast) return;
  window.clearTimeout(toastTimer);
  toast.textContent = message;
  toast.classList.add("is-visible");
  toastTimer = window.setTimeout(() => toast.classList.remove("is-visible"), 3200);
};

document.querySelectorAll("[data-coming-soon]").forEach((button) => {
  button.addEventListener("click", () => {
    showToast("Este contenido se desarrollará en el siguiente incremento del proyecto.");
  });
});

document.querySelector("[data-demo-button]")?.addEventListener("click", () => {
  showToast("La solicitud y su primera capa de privacidad se añadirán en la fase de contacto.");
});

if ("IntersectionObserver" in window && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12 }
  );

  document.querySelectorAll("[data-reveal]").forEach((element) => observer.observe(element));
} else {
  document.querySelectorAll("[data-reveal]").forEach((element) => element.classList.add("is-visible"));
}

