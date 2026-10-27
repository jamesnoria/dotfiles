# Contrato de documentos y criterios editoriales

## Plantilla visual

Referencia proporcionada: `~/Especificación Técnica - IFSAT3-684.pdf`.
Reutilizar únicamente el diseño y las categorías: logo RIMAC, cabecera en tabla,
área responsable, título del requerimiento, mes y fecha; tablas con cabecera rosa,
tipografía legible negra, índice y número de página. La maquetación es una
recreación adaptable, no una copia exacta de las seis páginas originales.

## JSON de entrada

Consulta `templates/tecnico.json` y `templates/funcional.json`.
Campos obligatorios: `kind` (`tecnico` o `funcional`), `metadata`, `sections`.
Metadatos obligatorios de texto: `jira`, `title`, `date` (ISO YYYY-MM-DD),
`author`, `area`, `version`. Establece `status` en `Finalizado` en las fuentes.
El generador normaliza el estado a `Finalizado`, incluso si una fuente antigua
lo omite o contiene «Borrador para revisión». El estado es documental: indica
que el informe está terminado, no que el cambio esté aprobado o desplegado.
Describe pruebas, implementación, despliegue y aprobación en el contenido sin
confundirlos. Una vez recopilados los datos necesarios, genera y entrega ambos
PDF directamente, sin solicitar revisión ni aprobación de borradores.
`sections` contiene exactamente ocho entradas (secciones 2–9). La ficha (1)
y el índice se generan automáticamente. Cada entrada tiene `title` y `blocks`.
El generador numera los títulos automáticamente: no añadas el número al título.

Bloques admitidos:

```json
{"type":"paragraph","text":"Texto plano con acentos y saltos de línea."}
{"type":"heading","text":"5.1. Alcance y componentes"}
{"type":"list","items":["Condición inicial","Resultado observable"]}
{"type":"table","headers":["Rol","Nombre","Empresa"],"rows":[["QA","Pendiente de confirmar","Pendiente de confirmar"]]}
{"type":"code","text":"{\n  \"ejemplo\": true\n}"}
```

No se interpreta Markdown/HTML: evita asteriscos para énfasis. Las tablas deben
tener filas con el mismo número de columnas que la cabecera. Divide tablas muy
anchas y evita más de cuatro columnas para conservar legibilidad. No pongas una
función completa en una celda. Los bloques de código son solo para el técnico;
usa ejemplos breves y anonimizados y líneas cortas. Los textos son escapados
antes de renderizarse. No hay interpolación ni ejecución de contenido del JSON.

## Criterios de evidencia

- Un test existente no demuestra que fue ejecutado ni que pasó.
- Un porcentaje de cobertura requiere reporte real, comando y alcance.
- Una configuración encontrada no demuestra su despliegue en producción.
- Un commit no equivale a aprobación de negocio.
- Un endpoint consumido puede no haberse modificado: distinguir integración
  existente, contrato modificado y endpoint nuevo.
- No deducir roles IAM efectivos solo del nombre de un rol.
- No incluir credenciales, tokens, URLs firmadas ni identificadores reales de
  pacientes, pólizas, facturas o siniestros. Usar ejemplos sintéticos.
- No copiar autor, fechas, stack, responsables ni estado del PDF de referencia.

## Correspondencia funcional

Mantener detalle suficiente para entender y validar el cambio sin leer código.
Cada capacidad relevante debe explicar actor, condición de inicio, regla,
acción/decisión, resultado y excepciones conocidas. Si el cambio es puramente
interno, describir su efecto operativo y aclarar si no cambia la experiencia
del usuario (solo cuando esté verificado). No inventar pantallas ni acciones.
