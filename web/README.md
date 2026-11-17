# Web de Circular ID

Versión local de la web corporativa y el blog. Es un sitio estático construido con HTML, CSS y JavaScript, sin dependencias ni proceso de compilación.

## Publicación

- Web pública: <https://arecioga.github.io/circular-id/>
- Despliegue automático: GitHub Pages desde la carpeta `web/` mediante GitHub Actions.

## Vista local

Desde la raíz del repositorio:

```bash
python3 -m http.server 4173
```

Después, abrir `http://localhost:4173/web/`.

## Estado

- Página de inicio responsive y siete páginas interiores.
- Demostración interactiva de verificación.
- Datos de la investigación con limitaciones visibles.
- Solución, servicios, empresa, blog, contacto y páginas legales.
- Carrito local para simular la selección de un plan B2B.
- Formulario con primera capa informativa que no envía ni guarda datos.
- Dos artículos completos integrados en el blog.
- Navegación móvil accesible.
- Pendiente: sustituir el correo reservado de demostración e incorporar los enlaces de las redes sociales cuando existan.

## Páginas

- `index.html`: portada y demostración.
- `solucion.html`: funcionamiento de NFC + QR y estados de verificación.
- `servicios.html`: planes orientativos y contratación simulada.
- `empresa.html`: propósito, investigación, principios y equipo.
- `blog.html`: índice de contenidos.
- `contacto.html`: formulario académico y primera capa de privacidad.
- `privacidad.html` y `condiciones.html`: información legal demostrativa.
- `blog/`: dos entradas completas de contenido de valor.

Todos los importes, plazos y datos de contacto se presentan como ficción académica. Antes de una publicación real sería necesaria una revisión jurídica y comercial.

