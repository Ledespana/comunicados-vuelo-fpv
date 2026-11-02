---
name: comunicado-vuelo
description: Prepara en Chrome una comunicación de vuelo de dron (UAS) al Ministerio del Interior en drones.ses.mir.es, con la zona de vuelo generada automáticamente, y la deja lista para que el usuario firme. Usar cuando el usuario pida "comunicado", "comunicación de vuelo", "avisar a Interior" para un vuelo.
---

# Comunicación de vuelo UAS – Ministerio del Interior

Datos del operador, piloto, drones y ubicaciones: `perfil.yaml`. Si no existe → usa primero el skill `configurar`.
Usa Claude in Chrome (carga primero el skill `anthropic-skills:chrome-browser` si existe).
Nunca pulses "Firmar y presentar" sin un "firma" explícito del usuario para esa comunicación.

## 1. Datos del vuelo: usa valores por defecto, NO preguntes
El usuario quiere decir una frase ("comunicado el 20 en Genalguacil") y nada más. No hagas preguntas salvo que algo sea
imposible de resolver; todo lo demás se resuelve con estos valores por defecto (de `perfil.yaml > preferencias`, o los de
abajo si no existen) y se enseña en el resumen final, donde el usuario puede corregirlo:
- **Horario:** si no lo dice → todo el día = `preferencias.horario` (por defecto **00:00–23:55**).
- **Fecha:** "el 20" = el próximo día 20. **Plazo ≥ 5 días naturales**: si no se cumple, avísalo (es lo único que para).
- **Drones:** si no lo dice → todos los de `uas` con `mtom_g` < 250 (si solo hay uno, ese). Nunca uno ≥ 250 g en urbano.
- **Observador:** si no lo dice → los de `observadores` con `por_defecto: true`; si no hay o les falta el documento, ninguno
  (no preguntes; menciónalo en el resumen).
- **Altura** 120 m, **VLOS**.
- **Sitio:** ver §2; nunca pidas coordenadas ni un punto exacto.

## 2. Zona de vuelo (sitio nuevo) — automática, sin preguntar
1. Coordenadas: si el usuario da coordenadas o enlace de Maps, úsalas. Si da un nombre, búscalo tú en Google Maps
   (Claude in Chrome) y toma el punto que Maps marca:
   - lugar concreto (playa, plaza, mirador, parque…) → ese punto, **radio 100 m**;
   - solo un pueblo/ciudad → el centro que marca Maps, **radio `preferencias.radio_pueblo_m`** (por defecto **500 m**).
   Si el nombre es ambiguo (varios pueblos iguales), elige el de la provincia del usuario y dilo en el resumen.
2. Comprueba el punto (y el borde del círculo si el radio es grande) en https://drones.enaire.es: en el buscador escribe
   **"lat, lon"** (latitud primero, p.ej. `36.54567, -5.23548`; al revés cae en África), clic en la sugerencia, verifica con
   una captura que el pin está en el sitio correcto, clic en el punto → panel "Information". Si hay zona restringida (ZRVF/CECAF, LER/LED Defensa, parque nacional/natural con restricción,
   CTR de aeropuerto, NOTAM): **para** y explica que hace falta otro trámite; este agente solo cubre zonas sin restricciones.
   Si ENAIRE pide aceptar condiciones, que las acepte el usuario.
3. Genera la zona: `python3 -I .claude/skills/comunicado-vuelo/scripts/zona.py <lat> <lon> <radio_m>` → `mapa_value`,
   `lugar` ("lat,lon,17") y `poligono`.
4. No pidas confirmación aparte: incluye una captura del mapa del formulario en el resumen final (§5). Si el usuario quiere
   otra zona, la ajustas (otro punto/radio) o la dibuja él con la herramienta polígono y la lees de `zona_act1:mapa_value`.
5. Guarda el sitio en `perfil.yaml > ubicaciones.<nombre>` (lugar, radio_m, poligono) para reutilizarlo.

## 3. Login
1. `https://sede.interior.gob.es/portal/sede/tramites?codAgrupacion=Drones` → **Acceso** en
   "Comunicación de vuelo de aeronave pilotada por control remoto".
2. Cl@ve → **Access eIdentifier**. Espera ~8 s.
3. Login correcto = `https://drones.ses.mir.es/drones-web/acceso`. Si la sesión sigue viva, abre esa URL directamente.
Si se queda parado: probablemente hay un selector de certificado o un aviso del llavero abierto → pide al usuario que elija
su certificado / "Permitir siempre" (nunca introduzcas contraseñas). Si Cl@ve da error 500 `003002`: el usuario canceló el
selector → Cmd+Q en Chrome y repetir.

## 4. Rellenar
La navegación directa por URL a veces redirige a /acceso: usa los enlaces del menú (Comunicaciones → "Comunicaciones de vuelo").

**Sitio ya usado (camino rápido):** si `ubicaciones.<sitio>.comunicacion_origen` existe → Comunicaciones → icono
"Clonar la comunicación" de esa fila. Se abre `/clonarComunicacion` con todo precargado (operador, piloto, UAS,
observadores, zona, lugares, altura) excepto **fecha y horas**. Si el número de actividades (días × drones) es distinto,
añade o quita actividades. Revisa también el teléfono del operador.

**Sitio nuevo:** Alta comunicación → En nombre propio. Rellena la pestaña Operador (verifica lo precargado y pon el
**teléfono** de `perfil.yaml`) y la Actividad 1:
- Tipo "VLOS"; Lugar protección y Lugar recuperación = `lugar`; Altura 120; CC.AA.: clic en la comunidad del sitio.
- Zona: `limpiarMapa(id); document.getElementById(id+':mapa_value').value = <mapa_value>; cargarFigurasMapa(id)` con
  `id='formCampos:pestanas:zona_act1'`. Comprueba que hay 1 sola figura (a veces aparece una 2ª "Generica": deja 1).
  Recargar el mapa BORRA fecha/horas y CC.AA. de esa actividad → pon la zona antes que la fecha.
- Piloto: "Mis pilotos" si ya existe; si no, rellena el bloque piloto desde `perfil.yaml` (certificado de competencia =
  `piloto.certificado_competencia`, el ESP-RP).
- UAS desde `perfil.yaml` por JS (value + input/change/blur, **uno a uno con ~600 ms**: cambiar Nº de serie dispara un ajax
  que re-renderiza el panel). MTOM y Autonomía son inputNumber:
  `PrimeFaces.widgets['widget_formCampos_pestanas_mtomRpa_act1'].setValue(117)`. Clase: opción con texto 'Rotor' en
  `codClaseRpa_act1` (selectOneMenu, ver abajo). "Banda" se trunca a 30 caracteres; es normal.
- Observadores: botón "Agregar" → diálogo `formDlgObs` (tipo de documento es selectOneMenu; cambiarlo borra el nº →
  escribe el documento DESPUÉS). Obligatorios además: `desCertCompetPilobs` y `desCertFormacionPilobs` = "N/A".
  Luego `formDlgObs:agregarObs`.

**Recetas PrimeFaces (probadas, imprescindibles):**
- **Selects (horas, minutos, clase):** los clics no abren el desplegable. Usa JS y dispara SIEMPRE el change, si no el
  valor se ve pero no llega al servidor y sale 00:00:
  `w=PrimeFaces.widgets['widget_formCampos_pestanas_horaInicio_act1']; w.show(); await 900ms; w.selectValue('9'); w.hide(); w.callBehavior('change'); await 1500ms`
  (valores sin cero: '7','0','20'). Comprueba `_input.value`; si falla con "reading 'eq'", reintenta.
- **Fecha:** `c=PrimeFaces.widgets['widget_formCampos_pestanas_fecha_act1']; c.setDate(new Date(a,m-1,d)); c.callBehavior('dateSelect'); await 2500ms`.
  Sin `dateSelect` la fecha no llega al servidor ("La fecha de la actividad es obligatoria"). El ajax de la fecha
  REINICIA las horas de esa actividad → orden: fechas de todas → comprobar → horas de todas.
- **Varios drones o días = UNA comunicación**, una actividad por día y dron ("Añadir nueva actividad" → ids `_act2`…,
  piloto `...Pilact2`). Añadir una actividad re-renderiza TODAS y borra fechas, horas, altura, MTOM y autonomía.
  Orden: 1) crear todas las actividades con textos, zona, piloto, UAS y observador; 2) al final fechas (con dateSelect);
  3) horas; 4) altura/MTOM/autonomía; 5) verificar.
- Llamadas JS > 45 s dan timeout: lanza el trabajo en segundo plano (`(async()=>{...})()`), guarda el progreso en
  `window.__prog` y consúltalo cada ~60 s. El servidor es lento: espera 1–1,5 s tras cada ajax.

**Verificación final (obligatoria):** vuelca por JS, de CADA actividad: fecha, horas, altura, nº de figuras de la zona,
CC.AA., dron (modelo, MTOM, autonomía), piloto (DNI y ESP-RP), observador; y el teléfono del operador. Repite hasta que
no falte nada.

## 5. Revisión y firma
- Enseña un resumen (tabla día/horario/drones + sitio y radio, captura del mapa con la zona, altura, piloto, operador,
  teléfono, observador) indicando qué se ha puesto por defecto, y espera "firma" (o correcciones).
- Con "firma": pulsa **"Firmar y presentar"** → diálogo "Firma de la comunicación": antes de **"Firmar y enviar"** vuelve a
  volcar fechas/horas/teléfono (ahora vienen del servidor); si algo cambió → Cancelar y corregir.
- Página FIRe "Seleccione el sistema de firma" → **"Firma con certificado local"** (AutoFirma) → Acceder. Luego lo hace el
  usuario: elegir su certificado y aceptar en AutoFirma (las capturas fallan mientras tanto; espera).
- Éxito = `/drones-web/resultado` con "Comunicación registrada correctamente con identificador C…".

## 6. Guardar (siempre)
1. En /resultado: "Descargar acuse" y "Descargar PDF" → `~/Downloads/<C…>-acuse.pdf` y `<C…>-solicitud.pdf`.
2. Lee el acuse para sacar el nº de registro (REGAGE…) y la fecha. Lee el PDF de la solicitud y comprueba fecha/hora de
   cada actividad y el teléfono en la página 1. Si algo no cuadra, avisa.
3. Copia ambos a `comunicados/AAAA-MM-DD_<Sitio>_<C…>_acuse.pdf` / `_comunicacion.pdf` (fecha = primer día de vuelo) y, si
   existe `guardado.carpeta_movil`, también allí.
4. Añade una fila a `comunicados/registro.md`.
5. Si el sitio era nuevo, guarda `comunicacion_origen: C…` en su ubicación para clonarla la próxima vez.

## Identificadores (obligatorio)
Siempre desde `perfil.yaml`, nunca de memoria: **operador** = `operador.registro_operador` (ESP…, va en "Número de registro
de operador") y **piloto** = `piloto.certificado_competencia` (ESP-RP-…, va en "Certificado de competencia de piloto").
Son distintos: nunca uno en lugar del otro.

## Después de presentar
Recuerda al usuario: la Guardia Civil puede escribir pidiendo documentación (registro de operador, formación A1/A3 y el
acuse): están en `docs/` y `comunicados/`. Si lo pide, prepara la respuesta como borrador de correo; nunca la envíes sin
su "envía".
