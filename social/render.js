const artboard = document.querySelector("#artboard");
const asset = new URLSearchParams(window.location.search).get("asset") || "ig-01";

const brand = (light = false) => `
  <div class="asset-brand ${light ? "asset-brand-light" : ""}">
    <img src="../assets/brand/simbolo-circular-id.svg" alt="" />
    <span>CIRCULAR <strong>ID</strong></span>
  </div>`;

const postFooter = (network, number, light = false) => `
  <div class="asset-footer ${light ? "asset-footer-light" : ""}">
    <span>${network} · ${number}</span><span>#dcom2526</span>
  </div>`;

const tagCard = () => `
  <div class="smart-label">
    <i></i>
    <span>CIRCULAR <strong>ID</strong></span>
    <div class="smart-mark">✓</div>
    <b>ID 040-871-ES</b>
    <small>NFC + QR</small>
  </div>`;

const phoneCard = (label = "REGISTRO COINCIDENTE") => `
  <div class="social-phone">
    <div class="phone-speaker"></div>
    <div class="phone-photo"><div class="mini-garment"></div></div>
    <span class="phone-status">● ${label}</span>
    <strong>Chaqueta · Colección 04</strong>
    <small>ID 040-871-ES</small>
  </div>`;

const definitions = {
  avatar: {
    width: 400,
    height: 400,
    className: "avatar-art",
    html: `<div class="avatar-ring"><img src="../assets/brand/simbolo-circular-id.svg" alt="" /></div>`,
  },
  "linkedin-banner": {
    width: 1512,
    height: 256,
    className: "linkedin-banner-art",
    html: `
      <div class="banner-dots"></div>
      ${brand(true)}
      <div class="banner-copy"><strong>Cada prenda, una prueba de confianza.</strong><span>Acerca. Escanea. Comprueba.</span></div>
      <div class="banner-orbit"></div>`,
  },
  "ig-01": {
    width: 1080,
    height: 1350,
    className: "photo-post",
    html: `
      <img class="photo-fill" src="assets/foto-prenda-nfc-v1.png" alt="" />
      <div class="photo-shade"></div>
      ${brand(true)}
      <div class="photo-headline"><span>PREGUNTA 01</span><h1>¿Te fiarías<br />solo de una<br /><em>etiqueta?</em></h1></div>
      <div class="photo-stat"><strong>75 %</strong><p>ha dudado alguna vez<br />de la autenticidad.</p></div>
      <div class="photo-note">Encuesta académica propia · n = 20 · resultado orientativo</div>
      ${postFooter("INSTAGRAM", "01/04", true)}`,
  },
  "ig-02-1": {
    width: 1080,
    height: 1350,
    className: "ig-carousel cover-warm",
    html: `
      ${brand()}
      <div class="giant-number">4</div>
      <div class="carousel-title"><span>GUÍA PARA GUARDAR</span><h1>Comprobaciones<br />antes de comprar<br />moda de marca.</h1><p>Desliza para revisar →</p></div>
      ${postFooter("INSTAGRAM · CARRUSEL", "01/05")}`,
  },
  "ig-02-2": {
    width: 1080,
    height: 1350,
    className: "ig-carousel step-mint",
    html: `
      ${brand()}
      <div class="step-count">01</div>
      <div class="seller-card"><div class="seller-avatar"></div><div><b>Vendedor</b><span>Historial · Condiciones · Respuestas</span></div><strong>✓</strong></div>
      <div class="step-copy"><span>PRIMERA COMPROBACIÓN</span><h1>Mira a quién<br />estás comprando.</h1><p>Revisa el historial, las valoraciones detalladas y las condiciones de devolución.</p></div>
      ${postFooter("INSTAGRAM · CARRUSEL", "02/05")}`,
  },
  "ig-02-3": {
    width: 1080,
    height: 1350,
    className: "ig-carousel step-ink",
    html: `
      ${brand(true)}
      <div class="step-count light">02</div>
      <div class="detail-card"><span>MODELO</span><b>Chaqueta 04</b><span>TALLA</span><b>M</b><span>REFERENCIA</span><b>CID-040</b></div>
      <div class="step-copy light"><span>SEGUNDA COMPROBACIÓN</span><h1>Contrasta<br />los detalles.</h1><p>Modelo, talla, color, referencias y fotografías deben contar la misma historia.</p></div>
      ${postFooter("INSTAGRAM · CARRUSEL", "03/05", true)}`,
  },
  "ig-02-4": {
    width: 1080,
    height: 1350,
    className: "ig-carousel step-blue",
    html: `
      ${brand(true)}
      <div class="step-count light">03</div>
      <div class="shield-card"><div class="shield-shape">✓</div><strong>PAGO PROTEGIDO</strong><span>Conserva el anuncio y la devolución dentro del canal.</span></div>
      <div class="step-copy light"><span>TERCERA COMPROBACIÓN</span><h1>No salgas<br />del proceso seguro.</h1><p>La urgencia del vendedor nunca debe hacerte perder la protección de la plataforma.</p></div>
      ${postFooter("INSTAGRAM · CARRUSEL", "04/05", true)}`,
  },
  "ig-02-5": {
    width: 1080,
    height: 1350,
    className: "ig-carousel step-white",
    html: `
      ${brand()}
      <div class="step-count">04</div>
      <div class="identity-pair">${tagCard()}${phoneCard()}</div>
      <div class="step-copy"><span>CUARTA COMPROBACIÓN</span><h1>Consulta<br />la identidad.</h1><p>Si existe, comprueba qué registro muestra. Es una evidencia más, no una promesa absoluta.</p></div>
      ${postFooter("INSTAGRAM · CARRUSEL", "05/05")}`,
  },
  "ig-03": {
    width: 1080,
    height: 1920,
    className: "reel-cover",
    html: `
      <img class="photo-fill" src="assets/foto-prenda-nfc-v1.png" alt="" />
      <div class="reel-shade"></div>
      ${brand(true)}
      <div class="reel-badge">REEL · 15 S</div>
      <div class="reel-title"><h1>Acerca.<br />Escanea.<br /><em>Comprueba.</em></h1><p>Una identidad digital para cada prenda.</p></div>
      <div class="reel-play">▶</div>
      ${postFooter("INSTAGRAM", "03/04", true)}`,
  },
  "ig-04": {
    width: 1080,
    height: 1350,
    className: "promo-post",
    html: `
      <div class="promo-dots"></div>
      ${brand(true)}
      <div class="promo-copy"><span>PRUEBA PILOTO</span><h1>Una colección<br />es suficiente<br />para empezar.</h1><p>250 etiquetas NFC + QR</p></div>
      ${tagCard()}
      <div class="promo-cta">SOLICITAR DEMOSTRACIÓN <b>→</b></div>
      <div class="academic-strip">SIMULACIÓN ACADÉMICA · PRECIO Y SERVICIO NO REALES</div>
      ${postFooter("INSTAGRAM", "04/04", true)}`,
  },
  "li-01": {
    width: 1080,
    height: 1350,
    className: "linkedin-stat",
    html: `
      ${brand(true)}
      <div class="li-stat-copy"><span>INVESTIGACIÓN INICIAL</span><strong>75<span>%</span></strong><h1>ha dudado de la autenticidad de un producto.</h1><p>La confianza también se puede diseñar.</p></div>
      <div class="sample-note">Encuesta académica propia · n = 20 · muestreo no probabilístico · resultado orientativo</div>
      ${postFooter("LINKEDIN", "01/04", true)}`,
  },
  "li-02-1": {
    width: 1080,
    height: 1350,
    className: "li-carousel li-cover",
    html: `
      ${brand()}
      <div class="loop-graphic"><i></i><i></i><i></i></div>
      <div class="li-doc-copy"><span>DOCUMENTO · 4 PÁGINAS</span><h1>De etiqueta<br />a canal<br /><em>posventa.</em></h1><p>Un recorrido que continúa después de comprar.</p></div>
      ${postFooter("LINKEDIN · DOCUMENTO", "01/04")}`,
  },
  "li-02-2": {
    width: 1080,
    height: 1350,
    className: "li-carousel li-register",
    html: `
      ${brand(true)}
      <div class="li-step-number">01</div>
      ${tagCard()}
      <div class="li-step-copy"><span>LA MARCA REGISTRA</span><h1>Una unidad.<br />Un identificador.</h1><p>El producto se relaciona con su marca, colección y datos esenciales.</p></div>
      ${postFooter("LINKEDIN · DOCUMENTO", "02/04", true)}`,
  },
  "li-02-3": {
    width: 1080,
    height: 1350,
    className: "li-carousel li-check",
    html: `
      ${brand()}
      <div class="li-step-number">02</div>
      ${phoneCard("REGISTRO COINCIDENTE")}
      <div class="li-step-copy dark"><span>EL CLIENTE COMPRUEBA</span><h1>Una respuesta<br />que se entiende.</h1><p>Verificado, revisar o no reconocido. La interfaz explica la evidencia disponible.</p></div>
      ${postFooter("LINKEDIN · DOCUMENTO", "03/04")}`,
  },
  "li-02-4": {
    width: 1080,
    height: 1350,
    className: "li-carousel li-continue",
    html: `
      ${brand(true)}
      <div class="li-step-number">03</div>
      <div class="service-stack"><div><b>01</b><span>Cuidados</span></div><div><b>02</b><span>Garantía</span></div><div><b>03</b><span>Reventa</span></div></div>
      <div class="li-step-copy"><span>LA RELACIÓN CONTINÚA</span><h1>Más valor<br />después de comprar.</h1><p>La etiqueta se convierte en un punto de contacto durante la vida del producto.</p></div>
      ${postFooter("LINKEDIN · DOCUMENTO", "04/04", true)}`,
  },
  "li-03": {
    width: 1080,
    height: 1350,
    className: "li-video-cover",
    html: `
      <img class="video-photo" src="assets/foto-prenda-nfc-v1.png" alt="" />
      <div class="video-panel">${brand(true)}<span>VÍDEO · 12 S</span><h1>¿Qué ve<br />el cliente?</h1><p>La experiencia Circular ID<br />en cuatro gestos.</p><div class="timeline"><i>0</i><b></b><i>3</i><b></b><i>6</i><b></b><i>12</i></div></div>
      <div class="video-play">▶</div>
      ${postFooter("LINKEDIN", "03/04", true)}`,
  },
  "li-04": {
    width: 1200,
    height: 627,
    className: "li-ad",
    html: `
      <div class="ad-copy">${brand(true)}<span>PRUEBA PILOTO</span><h1>Una colección.<br /><em>250 etiquetas.</em><br />Empieza pequeño.</h1><div class="ad-button">SOLICITAR DEMOSTRACIÓN</div><small>Proyecto académico · Servicio simulado</small></div>
      <div class="ad-visual"><img src="assets/foto-prenda-nfc-v1.png" alt="" /><div class="ad-circle"></div>${tagCard()}</div>`,
  },
};

const definition = definitions[asset];

if (!definition) {
  document.body.classList.add("render-error");
  artboard.innerHTML = `<h1>Creatividad no encontrada</h1><p>${asset}</p>`;
} else {
  document.documentElement.style.setProperty("--asset-width", `${definition.width}px`);
  document.documentElement.style.setProperty("--asset-height", `${definition.height}px`);
  document.body.dataset.asset = asset;
  artboard.className = definition.className;
  artboard.innerHTML = definition.html;
  document.title = `${asset} · Circular ID`;
}
