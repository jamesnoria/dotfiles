Para decisiones del usuario, preferencias, confirmaciones de enfoque o seleccion entre alternativas, usa siempre la herramienta `question` con opciones concretas cuando la decision pueda representarse de forma estructurada.

Solo pregunta en texto plano cuando la respuesta sea necesariamente abierta, no pueda reducirse a opciones claras, o cuando la herramienta `question` no este disponible.

Siempre, sin excepcion, corre los tests usando la opcion `--runInBand` (por ejemplo `jest --runInBand` o `npm test -- --runInBand`). Nunca ejecutes los tests directamente sin `--runInBand`.

Para correr tests usa por defecto `rtk jest --runInBand` (salida minima, ahorra tokens). Solo si hay fallos, baja a `npx jest --runInBand <archivo>` para ver el detalle del error.

En general, ejecuta los comandos de shell con `rtk` (por ejemplo `rtk git status`, `rtk read`, `rtk ls`, `rtk jest`) porque resume la salida y ahorra tokens. Si la salida resumida no tiene el detalle suficiente para continuar con tu validacion o garantizar tu respuesta, vuelve a ejecutar ese comando de forma nativa (sin `rtk`) y usa solo ahi la salida completa. Esto aplica tambien a la regla de tests: mantén siempre `--runInBand`.
