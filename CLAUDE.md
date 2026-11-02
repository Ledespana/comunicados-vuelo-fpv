# Kit de comunicados de vuelo FPV (Ministerio del Interior)

Guía de uso: @README.md

- Si no existe `perfil.yaml` → antes de nada, skill `configurar` (asistente guiado).
- Comunicados a Interior → skill `comunicado-vuelo`. Solo zonas SIN restricciones; si ENAIRE muestra una zona restringida,
  explica que hace falta otro trámite y no sigas.
- No hagas preguntas innecesarias: si el usuario no dice horario, drones u observador, usa `perfil.yaml > preferencias`
  y los valores por defecto del skill, y enséñalos en el resumen. Construcción propia ≥ 250 g → solo A3, nunca urbano.
- Identificadores siempre desde `perfil.yaml`, los dos etiquetados: operador (ESP…) y piloto (ESP-RP-…).
- Teléfono del operador SIEMPRE en "Datos del Operador".
- Nunca firmes ni envíes nada sin un "firma"/"envía" explícito del usuario para ese trámite.
- Nunca escribas contraseñas ni elijas certificados por el usuario.
- Habla claro y sin tecnicismos.

## Navegador: SIEMPRE Claude in Chrome, y el de ESTE ordenador
Si hay varios navegadores conectados a la cuenta (p.ej. Mac y PC), usa el de este ordenador (`list_connected_browsers`,
`select_browser`); nunca el de otro, aunque sea el único conectado: pide conectar este.
Usa solo las herramientas de **Claude in Chrome** (el Chrome del usuario, `mcp__claude-in-chrome__*`), nunca el navegador
integrado de la app de Claude (panel "Browser", Ctrl+Shift+B), aunque el usuario diga "quiero verlo en el navegador":
el certificado FNMT, la autoselección (`chrome://policy`) y AutoFirma están configurados en Chrome.
Para que lo vea EN DIRECTO (Chrome solo muestra la pestaña seleccionada; Claude trabaja en la suya aunque esté detrás):
al abrir tu pestaña dile, en una frase: "En Chrome, haz clic en el grupo de pestañas **<nombre del grupo>** (si está
plegado, se despliega) y selecciona la pestaña de dentro; déjala delante y verás cómo relleno cada campo".
El nombre del grupo suele ser el de la conversación (sácalo de tabs_context_mcp). Trabaja siempre en esa misma pestaña
(no abras pestañas nuevas sin necesidad) para que no tenga que ir buscándote.
