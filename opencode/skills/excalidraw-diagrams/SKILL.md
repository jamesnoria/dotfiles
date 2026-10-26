---
name: Excalidraw Diagrams
description: Generate clean Excalidraw diagrams (architecture, flowcharts, sequence, ER/database) from a compact JSON spec with auto-layout, then render a PNG to visually verify and fix them. Use whenever the user asks for a diagram, flowchart, architecture/system diagram, sequence diagram or ER model as .excalidraw.
---

# Excalidraw Diagrams

NO escribas JSON de Excalidraw a mano. Describe el diagrama en una **spec** compacta; `build.mjs` calcula el layout, las flechas ortogonales y los bindings. Después `render.mjs` produce un PNG que **debes mirar** antes de entregar.

Los scripts viven en `scripts/` (relativo a este archivo). Primer uso: `npm install` en el directorio de la skill si falta `node_modules`.

## Flujo obligatorio

Ubicación de salida: todo (spec, `.excalidraw`, `.png`, `.svg`) va en `.tmp/` en la raíz del proyecto actual. Antes de generar, ejecuta `mkdir -p .tmp`. Usa nombres descriptivos, por ejemplo `.tmp/login-secuencia.json`. Los scripts se invocan con la ruta absoluta a `scripts/` de esta skill.

0. Si el usuario pide diagramar un proyecto/código existente, analízalo primero: `package.json`/workspaces (monorepo), `docker-compose.yml`/k8s (servicios), `*.tf` (infra), rutas/controllers (API), `CREATE TABLE`/modelos/migraciones (ER). Identifica componentes, bases de datos, colas y flujos de datos.
1. Decide el tipo (`graph` o `sequence`) y lista nodos y relaciones. Máximo ~12 nodos por diagrama; si hay más, divide en varios.
2. Escribe la spec en `<salida>.json` (ver formatos abajo).
3. `node scripts/build.mjs spec.json diagrama.excalidraw`
4. `node scripts/render.mjs diagrama.excalidraw diagrama.png`
5. **Lee el PNG** con la herramienta `read` y revisa: etiquetas que tapan flechas o nodos, flechas cruzadas, textos cortados, nodos mal agrupados. Revisa también los AVISOS del lint.
6. Corrige la spec (no el JSON generado) y repite. Máximo 3 iteraciones.
7. Entrega `.excalidraw` + `.png` (en `.tmp/`) y menciona la ruta.

## Spec `graph` (flujo, arquitectura, ER)

```json
{
  "type": "graph",
  "direction": "LR",            // LR | TB (TB para flujos de proceso, LR para arquitectura/ER)
  "title": "Opcional",
  "nodes": [
    {"id": "api", "label": "API Gateway", "color": "hub"},
    {"id": "db", "label": "PostgreSQL", "shape": "ellipse", "color": "data"},
    {"id": "ok", "label": "¿Válido?", "shape": "decision"},
    {"id": "users", "label": "users", "color": "data", "fields": ["id PK", "email", "name"]}
  ],
  "edges": [
    {"from": "api", "to": "db", "label": "SQL", "style": "dashed"}
  ],
  "groups": [{"id": "g1", "label": "Backend", "nodes": ["api", "db"], "color": "backend"}]
}
```

- `shape`: `rect` (defecto), `ellipse` (usuarios, sistemas externos, inicio/fin), `decision` (rectángulo naranja punteado), `diamond` (evitar: las conexiones de rombos fallan en Excalidraw).
- `fields`: convierte el nodo en una tarjeta de tabla (título + separador + columnas). Úsalo para ER, con etiquetas de relación `1:N` en las aristas.
- `groups`: zona punteada alrededor de los nodos listados (VPC, capa, equipo).

### Colores (`color`) con significado

| color | uso |
|-------|-----|
| `frontend`/`service` | frontends, servicios genéricos (azul) |
| `backend` | APIs/servicios de negocio (morado) |
| `data` | bases de datos (verde) |
| `storage` | object storage/archivos (amarillo) |
| `cache` | caché (naranja claro) |
| `queue` | colas/eventos (amarillo claro) |
| `ai` | IA/ML (magenta) |
| `external` | sistemas de terceros (ámbar) |
| `accent` | errores/alertas (rojo claro) |
| `user` | usuarios/actores (azul muy claro) |
| `hub` | orquestador/gateway (coral, borde grueso) |
| `neutral` | resto (gris) |

Más: `network` (VPC/IAM/firewall), `classification` (routers/clasificadores), `monitoring` (Prometheus/Grafana).
Paletas de nube (texto blanco automático en fondos oscuros): `aws-compute|storage|database|network|security|ml`, `azure-compute|storage|network|security`, `gcp-compute|storage|database|network|ml`, `k8s-workload|config|ingress|node`.

Usa 3-4 colores por diagrama; el color debe significar algo. Un color inexistente genera un AVISO en `build.mjs`.

### Aristas

`{"from","to","label","style":"dashed","bidirectional":true}`: `dashed` para asíncrono/opcional, `bidirectional` para flujos de ida y vuelta.

### Layout según tipo de diagrama

| Diagrama | direction | Notas |
|----------|-----------|-------|
| Microservicios / arquitectura | LR | agrupa por capa o dominio con `groups` |
| Pipeline de datos / CI-CD | LR | fuente → transformación → destino |
| Flujo de proceso / decisiones | TB | decisiones con `shape: "decision"` |
| Event-driven | LR | bus/cola (`queue`) en el centro |
| Kubernetes / red | TB | namespaces/VPC como `groups` |
| ER | LR | `fields` + relación `1:N` en la etiqueta |

## Spec `sequence`

```json
{
  "type": "sequence", "title": "Login",
  "participants": [{"id": "u", "label": "Usuario", "color": "external"}, {"id": "a", "label": "API"}],
  "messages": [
    {"from": "u", "to": "a", "label": "POST /login"},
    {"from": "a", "to": "u", "label": "JWT", "style": "dashed"},
    {"from": "a", "to": "a", "label": "verificar hash"}
  ]
}
```

El orden de `messages` es el orden vertical. `dashed` para respuestas.

## Reglas de calidad

- Etiquetas de aristas cortas (1-3 palabras). Información larga va en nodos.
- Un nivel de detalle por diagrama; no mezcles lógico y físico.
- Todas las aristas referencian ids existentes; no dejes nodos huérfanos.
- Si el render muestra cruces excesivos, cambia `direction` o reordena/agrupa nodos antes de añadir más cosas.
- Mantén etiquetas de nodos cortas (~25 caracteres máx.); usa `\n` para dos líneas.

## Ejemplos

`examples/arquitectura.json`, `examples/secuencia.json`, `examples/er.json` (con sus `.excalidraw` y `.png` generados). Cópialos como punto de partida.

## Limitaciones

El estilo es limpio (roughness 0), no de boceto. Para un diseño totalmente libre (mockups, ilustraciones) esta skill no aplica. El lint detecta solapamientos, texto desbordado y bindings rotos, pero no sustituye mirar el PNG.
