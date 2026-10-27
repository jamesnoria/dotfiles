---
name: Informes de cambios
description: Genera directamente dos informes PDF finales, una especificación técnica y otra funcional, sobre cambios implementados a partir del contexto del chat y código relacionado. Usa el formato corporativo RIMAC y pregunta solo por Jira/HU, involucrados y otros datos faltantes, sin solicitar revisión ni aprobación de borradores.
---

# Informes de cambios

Genera **dos documentos complementarios en español**: especificación técnica y especificación funcional. No son una propuesta de desarrollo ni un resumen genérico del repositorio: documentan los cambios implementados dentro del alcance acordado.

Lee `references/criterios.md` y las dos plantillas en `templates/`. Todos los recursos y scripts de esta skill se resuelven desde su directorio base, no desde el proyecto documentado.

## Ubicación obligatoria de los archivos generados

- Guarda **todos los archivos generados** (borradores, PDF, fuentes JSON, vistas previas y otros auxiliares) dentro de `.tmp/` en la raíz del **proyecto desde el que se invoca el skill**. Usa `.tmp/informes/<identificador-seguro>/` para los informes.
- Identifica y conserva la ruta absoluta de esa raíz antes de ejecutar scripts. Si no existe `.tmp/`, créala con `mkdir -p <raíz-del-proyecto>/.tmp`. Si la raíz es ambigua, aclárala con el usuario.
- El directorio de instalación del skill solo proporciona scripts, plantillas y recursos: **no es el destino de los informes**, aunque cambies de directorio para ejecutar herramientas. Usa rutas absolutas de entrada y salida cuando no ejecutes desde la raíz del proyecto que lo invocó.
- No guardes estos artefactos en la carpeta global de OpenCode, en el repositorio de dotfiles ni en un directorio temporal del sistema, salvo que ese sea el proyecto que invoca el skill o el usuario solicite explícitamente otra ubicación.

## 1. Delimitar y reunir evidencia

- Usa el contexto disponible del chat actual y los archivos que haya aportado el usuario. No afirmes tener acceso a otros chats o a mensajes ya ausentes del contexto.
- Identifica requerimiento, propósito, cambio anterior/nuevo, repositorios y módulos. Revisa instrucciones del proyecto antes de inspeccionarlo.
- Inspecciona el estado Git sin modificarlo. Usa solo diff, commits, rama, PR y archivos relacionados con el requerimiento. Un diff vacío no significa que no hubo cambios: pueden estar confirmados en commits.
- Si el alcance no es inequívoco, pregunta qué commits, PR, comparación de ramas o archivos documentar. No tomes todo el diff local o toda una rama como parte de la HU sin comprobarlo. No hagas checkout, reset ni alteres código.
- Registra evidencia verificable (ruta y símbolo, commit, prueba o contexto aportado). Diferencia lo observado en código, lo declarado por el usuario y lo pendiente de verificar.
- Jira es un identificador, no evidencia de acceso. Solicita el texto o exportación del ticket si hace falta y no existe integración disponible; no inventes contenido ni configures servicios.

## 2. Preguntar solo lo que falta

Usa `question` para decisiones estructuradas, agrupadas en tandas breves. Para nombres, código Jira y otros datos abiertos permite respuesta libre. No repitas preguntas ya respondidas en el chat.

Datos que debes resolver o señalar expresamente como pendientes:
- Código(s) Jira/HU, título y alcance incluido/excluido.
- Objetivo de negocio, comportamiento previo, nuevo comportamiento y reglas/excepciones que no se puedan deducir con certeza.
- Autor; equipo con rol, nombre y empresa (PO, arquitectura, desarrollo, QA u otros que correspondan). No arrastres personas del ejemplo.
- Área responsable (proponer Fábrica de Siniestros / RIMAC, confirmar), fecha de elaboración y versión. Propón la fecha real del entorno y versión 1.0.0 para un documento nuevo, sin darlos por confirmados. El estado documental de los PDF finales es siempre **«Finalizado»**: no lo preguntes ni uses «Borrador», «Para revisión» o equivalentes. Este estado indica que el documento está terminado, no que el cambio esté aprobado o desplegado.
- Estado de implementación, pruebas, despliegue y aprobación **por separado**. Implementado no implica aprobado ni desplegado.
- Impacto en permisos, datos, integraciones, compatibilidad y operación, cuando la evidencia no lo aclare.

Si el usuario desconoce un dato, ofrece continuar con «Pendiente de confirmar»; nunca lo inventes. No bloquees por campos secundarios si acepta pendientes. Sin Jira confirmado, acuerda un identificador como SIN-JIRA. Guarda los entregables en `.tmp/informes/<identificador-seguro>/` del proyecto que invoca el skill; solo cambia esa ubicación por solicitud explícita del usuario y consulta antes de reemplazar entregables existentes.

## 3. Redactar ambos informes internamente

- Usa las nueve secciones de cada plantilla, conservando numeración y orden. Puedes añadir subsecciones para el detalle necesario; no limites la extensión al número de páginas del ejemplo.
- Técnico: arquitectura e impacto, archivos/símbolos, stack verificado, lógica, contratos y ejemplos anonimizados, validaciones, errores, permisos, datos, compatibilidad, pruebas y operación cuando apliquen.
- Funcional: objetivo, actores, capacidades, condiciones, reglas, recorrido normal, alternativas, excepciones, resultado observable e impacto sobre el usuario. Evita código, IAM, nombres internos de funciones, SQL y payloads. Las integraciones se explican por su propósito de negocio.
- Incluye escenarios de aceptación y pruebas en subsecciones 5 o 6, diferenciando resultados ejecutados de escenarios propuestos o pendientes.
- Incluye trazabilidad del alcance y evidencia en subsecciones del técnico. Mantén ambos informes alineados: mismos identificadores, personas, versión, fecha y alcance.
- Cuando una sección no aplique, consérvala y explica por qué. «Sin cambios verificados» requiere evidencia; «No se identificaron cambios en el alcance revisado» no afirma ausencia global. Ausencia de información = «Pendiente de confirmar».
- No añadas diagramas por defecto. Si se necesitan, carga `excalidraw-diagrams`, sigue su flujo y guarda todos sus artefactos en `.tmp/` del proyecto.

En cuanto tengas toda la información necesaria, redacta, genera y verifica los dos PDF **sin presentar borradores ni pedir al usuario que los revise, valide o apruebe**. Las preguntas son únicamente para resolver información faltante o ambigüedades reales; no añadas una confirmación final para proceder. Realiza la revisión de contenido y presentación por tu cuenta. Si el usuario solicita ajustes posteriores, aplícalos sin abrir una etapa de aprobación de borradores; conserva la protección contra sobrescritura de archivos.

## 4. Generar los PDF finales

El generador trabaja localmente y no envía datos a servicios externos. Requiere Python 3 y ReportLab. Si faltan dependencias, usa un entorno virtual en `.tmp/` del proyecto e instala `requirements.txt` allí; no uses pip global. La inspección visual opcional requiere PyMuPDF (`requirements-preview.txt`). Respeta permisos y restricciones de red; informa si no es posible instalar.

1. Crea `<raíz-del-proyecto-que-invoca>/.tmp/informes/<identificador-seguro>/`. Guarda allí `tecnico.json` y `funcional.json`, copiando la estructura de las plantillas y reemplazando **todo** su contenido con el informe completo basado en la información recopilada. Establece `metadata.status` en `Finalizado` en ambas fuentes. Conserva estos JSON como fuentes editables.
2. Usa el logo incluido en `assets/rimac.png`, extraído de la referencia del usuario. No copies el PDF original ni su contenido de negocio. Si el recurso falta, informa y solicita el logo; no lo sustituyas silenciosamente.
3. Ejecuta desde el proyecto actual, con rutas absolutas para la skill:

```sh
<python-del-venv> <skill>/scripts/generate.py .tmp/informes/<id>/tecnico.json --output-dir .tmp/informes/<id>
<python-del-venv> <skill>/scripts/generate.py .tmp/informes/<id>/funcional.json --output-dir .tmp/informes/<id>
```

4. El script genera PDF A4 con encabezado RIMAC en cada página, título/ficha en la primera, índice real en la segunda, secciones posteriores, tablas y numeración. Los JSON son texto plano estructurado, **no Markdown ni HTML**. Consulta `references/criterios.md` para sus bloques admitidos.
5. Si un PDF ya existe, el script se detiene. Solo usa `--overwrite` tras autorización explícita para reemplazar ese archivo.

## 5. Verificar y entregar

- Abre ambos PDF con `read`. Si la herramienta no permite revisarlos visualmente, renderiza páginas a PNG con `scripts/preview.py` y léelas, especialmente páginas con tablas y bloques largos. Las imágenes quedan en el mismo directorio de salida.
- Comprueba: títulos e índice con páginas correctas; encabezado/logo y pie; acentos; tablas sin desbordes; código legible; sin texto recortado, páginas vacías accidentales ni placeholders de plantilla.
- Contrasta los PDF con la información recopilada y entre sí. Comprueba que la ficha de ambos diga **Estado: Finalizado**. Revisa que no haya secretos, datos personales de casos reales ni afirmaciones sin sustento.
- Corrige por tu cuenta problemas de contenido o maquetación y vuelve a generar y verificar, sin pedir revisión al usuario. No declares revisión visual si no pudiste hacerla: comunica la limitación.
- Entrega directamente enlaces a **los dos PDF finales**. Conserva las fuentes JSON y auxiliares en `.tmp/`, pero no los incluyas en la entrega salvo que el usuario los pida. Señala brevemente pendientes aceptados o limitaciones si existen. No publiques ni subas a Jira automáticamente.

## Pruebas del generador

Instala dependencias de desarrollo solo cuando se vaya a modificar/validar el generador. En el directorio de esta skill: `npm install` y `rtk jest --runInBand`. Configura `REPORT_PYTHON` con el Python del entorno virtual que tenga las dependencias. Ante fallos usa `npx jest --runInBand <archivo>` para el detalle. Nunca ejecutes tests sin `--runInBand`.
