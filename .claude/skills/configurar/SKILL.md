---
name: configurar
description: Asistente guiado de primera configuración del kit de comunicados de vuelo (datos del operador/piloto, drones, certificado FNMT, AutoFirma, Chrome y prueba de login). Usar cuando el usuario diga "configúrame", "configurar", "empezar", "primera vez", o cuando no exista perfil.yaml.
---

# Configuración guiada (primera vez)

Objetivo: dejar `perfil.yaml` completo y el ordenador listo para presentar comunicaciones a Interior.
Ve fase por fase. Al empezar cada fase di en una línea qué vas a hacer; al acabarla, confírmalo con ✅ y pasa a la siguiente.
Habla claro y sin tecnicismos: el usuario puede no ser técnico. Si `perfil.yaml` ya existe, enséñale un resumen y
pregunta qué quiere cambiar en lugar de empezar de cero.

Reglas:
- Nunca escribas contraseñas ni PIN del usuario, ni elijas certificados por él. Esos pasos los hace él.
- Los dos números de AESA son distintos y no se pueden confundir:
  **operador** (`ESP` + 12 caracteres, p.ej. ESPabc123def456) y **piloto** (`ESP-RP-` + números).
- Copia `perfil.ejemplo.yaml` → `perfil.yaml` al empezar y ve guardando al final de cada fase (si se corta, no se pierde).

## Fase 0 — Sistema
Detecta si es Mac o Windows (p.ej. `uname -s`: Darwin = mac; si falla o sale MINGW/MSYS/CYGWIN = windows) y guárdalo en
`perfil.yaml > sistema` (`mac` | `windows`). En las fases 4–8 sigue SOLO el apartado de su sistema.
En Windows ejecuta PowerShell así (evita problemas de comillas): escribe el comando en un .ps1 o usa los scripts de
`.claude/skills/configurar/scripts/windows/` con `powershell -NoProfile -ExecutionPolicy Bypass -File <script>`.
Windows está menos probado que Mac: si algo no sale como se describe, explícale al usuario lo que ves y busca otra forma
sencilla antes de rendirte.

## Fase 0b — Claude in Chrome (imprescindible)
Sin la extensión Claude in Chrome conectada no se pueden hacer comunicados (es la que rellena la web de Interior).
0. Usa SOLO Claude in Chrome (`mcp__claude-in-chrome__*`), nunca el navegador integrado de la app (panel "Browser"):
   el certificado, la política de Chrome y AutoFirma viven en Chrome.
1. **Que sea el Chrome de ESTE ordenador.** Claude in Chrome se conecta por cuenta, no por ordenador: si el usuario tiene
   Claude en varios ordenadores, puedes acabar manejando el Chrome de otro (pasó: la sesión de un PC Windows manejaba el
   Chrome de un Mac y el usuario no veía nada). Antes de nada, lista los navegadores conectados (`list_connected_browsers`)
   y compara su sistema con `perfil.yaml > sistema`:
   - si hay uno de este sistema/ordenador → selecciónalo (`select_browser`);
   - si solo hay de otro ordenador → NO lo uses; pide conectar el Chrome de este ordenador (petición de conexión → en este
     Chrome sale un aviso → **Connect**/Conectar en menos de 2 minutos);
   - si dudas, abre google.com y pregúntale si lo ve aparecer en ESTE ordenador.
   Repite esta comprobación al empezar cada conversación que use el navegador.
2. Comprueba si tienes las herramientas del navegador: intenta `tabs_context_mcp` (si son herramientas diferidas, cárgalas
   antes con ToolSearch). Si responde con pestañas → ✅, dile que verá a Claude trabajar en un **grupo de pestañas** de
   color en Chrome (a veces en otra ventana) y pasa a la fase 1.
3. Si no existen las herramientas o da error de "no conectado", guíale paso a paso:
   1. Abrir **Google Chrome** (no otro navegador).
   2. Instalar la extensión: Chrome Web Store → buscar **"Claude"** (editor: Anthropic) → **Añadir a Chrome**.
   3. Fijarla: icono del puzle 🧩 arriba a la derecha → chincheta junto a Claude.
   4. Pulsar el icono de Claude → **iniciar sesión con la misma cuenta** que usa en la app de Claude.
   5. En la app de Claude: Ajustes → Conectores (o la sección "Claude in Chrome") → comprobar que está **activado**.
   6. Cerrar esta conversación, abrir una **nueva** en la misma carpeta y decir "configúrame" otra vez (las herramientas
      del navegador se cargan al empezar la conversación; lo ya guardado en perfil.yaml no se pierde).
4. Prueba: abre una pestaña nueva con https://www.google.com y explícale cómo verte en directo: en Chrome, clic en el
   **grupo de pestañas <nombre>** (etiqueta de color a la izquierda de las pestañas; si está plegado, se despliega) →
   seleccionar la pestaña de dentro. Chrome solo muestra en vivo la pestaña seleccionada. Pídele que confirme que la ve.
   Recomiéndale **pantalla partida**: la app de Claude en una mitad y Chrome en la otra (Mac: mantener pulsado el botón
   verde de la ventana → Mosaico; Windows: Windows + ← / →). Es la forma de revisar en directo lo que se va rellenando.
   Si no encuentra el grupo, puede estar en otra ventana de Chrome.

## Fase 1 — Documentos de AESA (lo más fiable)
1. Pide al usuario que arrastre a la conversación (o deje en `docs/`) estos PDF de AESA:
   - **Certificado de registro de operador UAS** (el que tiene logo EASA + AESA y "Fecha de caducidad"; NO el justificante
     de alta ni el certificado "NO EASA").
   - **Certificado / prueba de formación A1/A3** del piloto (lleva el nº ESP-RP-…).
   Si no los tiene: se descargan en https://sede.seguridadaerea.gob.es (con su certificado digital o Cl@ve).
2. Léelos (Read) y saca: nombre, apellidos, nº de operador, fecha de caducidad, nº ESP-RP del piloto.
3. Cópialos a `docs/certificado_registro_operador.pdf` y `docs/certificado_piloto_A1A3.pdf`.
4. Enséñale los dos números etiquetados y pide que confirme.

## Fase 2 — Datos personales
Pregunta en un solo mensaje lo que falte: DNI/NIE, dirección, código postal, localidad, provincia, email y **teléfono móvil**
(obligatorio). Pregunta si el piloto es la misma persona que el operador (lo normal); si no, pide los datos del piloto.
Pregunta si suele volar con observador (nombre, apellido, DNI/NIE) — opcional.

## Fase 3 — Drones
Por cada dron: fabricante, modelo, **peso al despegue con batería (g)**, autonomía (min), color, radio (p.ej. ELRS 2.4 GHz),
si tiene luces. Rellena el resto con los valores por defecto de la plantilla (N/A, "no"...). `codigo_modelo` = 4 primeras letras.
Si un dron de construcción propia pesa ≥ 250 g: avisa de que solo puede volar en categoría A3 (lejos de personas y a
más de 150 m de zonas urbanas/recreativas), así que NO sirve para comunicaciones de vuelo urbano.

## Fase 4 — Certificado digital FNMT
**Mac** (solo lectura):
`security find-certificate -a -c "<APELLIDO1>" -p ~/Library/Keychains/login.keychain-db | openssl x509 -noout -subject -issuer -enddate`
(si hay varios, sepáralos y revisa cada uno).
**Windows** (solo lectura): `powershell -NoProfile -ExecutionPolicy Bypass -File .claude/skills/configurar/scripts/windows/comprobar.ps1`
(sección "Certificados FNMT": sujeto, caducidad, VALIDO/CADUCADO y si tiene clave privada).
- ✅ si hay uno con emisor "AC FNMT Usuarios", fecha de fin futura (y en Windows, clave privada True).
- Si no hay: que lo pida en https://www.sede.fnmt.gob.es (Persona física → Obtener certificado; lo más fácil suele ser la
  app de videoidentificación). Cuando le llegue el archivo (.p12/.pfx), doble clic para instalarlo:
  - Mac: se instala en el llavero.
  - Windows: asistente de importación → "Usuario actual" → contraseña del archivo → dejar que elija el almacén
    automáticamente. **No** marcar "Habilitar protección segura de claves privadas", o pedirá contraseña en cada firma.
  Puede seguir con el resto y volver aquí después.
- Si hay uno caducado y otro válido: que borre el caducado (si no, Chrome pregunta cada vez):
  - Mac: Acceso a Llaveros → Mis certificados → el caducado → Eliminar.
  - Windows: tecla Windows → escribir "certmgr.msc" → Personal → Certificados → el caducado → Eliminar.

## Fase 5 — AutoFirma
Comprueba si está: Mac `ls /Applications | grep -i autofirma`; Windows sección "AutoFirma" de `comprobar.ps1`.
- Si no está: https://firmaelectronica.gob.es/Home/Descargas.html → AutoFirma para su sistema (macOS o Windows 64 bits);
  instalar con doble clic y aceptar.
- Pídele que abra AutoFirma → Preferencias (en Windows: menú Herramientas → Preferencias) → pestaña **Almacenes de claves**
  (NO la pestaña General) y:
  - Almacén de claves por defecto: el del sistema (Mac: Llavero de macOS; Windows: Windows / Sistema operativo).
  - Marcar "Usar también en las llamadas a AutoFirma desde el navegador".
  - Marcar la opción de mostrar solo certificados de firma / no repudio (el texto exacto varía según la versión).
  - Aceptar. Si alguna opción no aparece, pídele una captura de esa pestaña; no es bloqueante (sirve para que AutoFirma no
    ofrezca certificados que no son el FNMT).

## Fase 6 — Chrome: que elija el certificado solo (recomendado)
Explica qué hace y por qué: sin esto, Chrome enseña una lista de certificados cada vez que entra en Interior o firma;
con esto, Chrome usa solo su certificado FNMT en las webs de Cl@ve e Interior. Pide permiso y ejecútalo tú:
- **Mac:**
```
defaults write com.google.Chrome AutoSelectCertificateForUrls -array \
 '<string>{"pattern":"https://[*.]clave.gob.es","filter":{"ISSUER":{"CN":"AC FNMT Usuarios"}}}</string>' \
 '<string>{"pattern":"https://[*.]mir.es","filter":{"ISSUER":{"CN":"AC FNMT Usuarios"}}}</string>'
```
- **Windows:** las políticas de Chrome están en una parte protegida del Registro y necesitan **permiso de administrador**
  (desde aquí no se puede escribir directamente; probado). Usa el archivo
  `.claude/skills/configurar/scripts/windows/chrome-certificado.reg` (escribe la política en
  `HKLM\SOFTWARE\Policies\Google\Chrome\AutoSelectCertificateForUrls`):
  1. Intenta lanzarlo tú para que solo tenga que aceptar:
     `powershell -NoProfile -Command "Start-Process regedit.exe -ArgumentList '/s','<ruta absoluta al .reg>' -Verb RunAs"`
     → Windows le mostrará "¿Quieres permitir que esta aplicación haga cambios?" → **Sí**.
  2. Si eso falla: que abra la carpeta `.claude\skills\configurar\scripts\windows\` en el Explorador (si no ve `.claude`:
     Vista → Elementos ocultos), doble clic en **chrome-certificado.reg** → **Sí** → **Sí** → Aceptar.
  Comprueba después con la sección "Chrome" de `comprobar.ps1`.
Luego, guíale:
1. Cerrar Chrome del todo y abrirlo. Mac: Cmd+Q. Windows: cerrar todas las ventanas y, si el icono de Chrome sigue junto
   al reloj, clic derecho → Salir.
2. Abrir `chrome://policy` y comprobar que aparece *AutoSelectCertificateForUrls* con estado OK (pídele captura si dudas).
   En Windows, si no aparece: pulsar "Volver a cargar políticas"; si sigue sin salir, dilo claramente (no es grave: solo
   significa que tendrá que elegir el certificado en una lista).
3. Mac: la primera vez el Mac pedirá permiso para la clave del certificado → **Permitir siempre**.
   Windows: puede salir una ventana "Seguridad de Windows" para elegir certificado o confirmar: aceptar.
4. Si en la fase 4 había más de un certificado FNMT, que borre el caducado.

## Fase 7 — Prueba de acceso (sin presentar nada)
Con Claude in Chrome: https://sede.interior.gob.es/portal/sede/tramites?codAgrupacion=Drones → **Acceso** en
"Comunicación de vuelo de aeronave pilotada por control remoto" → Cl@ve → **Access eIdentifier**.
Si sale el selector de certificado, que elija el suyo (nunca Cancelar: si cancela, Chrome lo recuerda → cerrar Chrome del
todo y repetir). Si el sistema pide permiso para la clave: aceptar / "Permitir siempre".
✅ cuando la URL sea `https://drones.ses.mir.es/drones-web/acceso`.

## Fase 8 — Dónde guardar (opcional)
No sugieras ningún servicio concreto ni lo pongas como opción por defecto.
1. Mira qué tiene instalado (solo lectura):
   - Mac: `ls -d ~/Dropbox ~/Library/CloudStorage/* ~/Library/Mobile\ Documents/com~apple~CloudDocs 2>/dev/null`
   - Windows: sección "Carpetas en la nube" de `comprobar.ps1` (Dropbox, OneDrive, iCloud, Google Drive).
2. Pregunta abierta: "¿Quieres una copia de los justificantes en alguna carpeta que veas en el móvil? Tienes instalado: <lista>.
   ¿Cuál prefieres, o ninguna?". Ofrece como opciones solo los que tenga instalados + "Ninguna".
3. Guarda la ruta elegida en `perfil.yaml > guardado.carpeta_movil` y crea la carpeta.
   Si elige uno que no tiene instalado, explícale que instale su app de escritorio primero.

## Final
Resumen de una pantalla: operador y piloto (los dos números etiquetados), teléfono, drones, certificado (caducidad),
AutoFirma, Chrome. Y explícale, con estas palabras o parecidas:
- **Ya no hay que volver a configurar.** Todo queda guardado en esta carpeta. Solo vuelve a decir "configúrame" (o
  "cambia mi …") si renueva el certificado, cambia de dron, de teléfono o de observador.
- **Las próximas veces:** abre Chrome → app de Claude → Code → la carpeta del kit (sale en recientes) → pide
  *"comunicado en <sitio> el <día> de 9 a 13"*. Cada conversación nueva empieza de cero, pero lee sus datos de la carpeta.
- Al final solo tendrá que decir **"firma"** y aceptar en AutoFirma.
