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
Comprueba (Bash, solo lectura):
`security find-certificate -a -c "<APELLIDO1>" -p ~/Library/Keychains/login.keychain-db | openssl x509 -noout -subject -issuer -enddate`
(si hay varios, sepáralos y revisa cada uno).
- ✅ si hay uno con emisor "AC FNMT Usuarios" y fecha de fin futura.
- Si no hay: explícale que lo pida en https://www.sede.fnmt.gob.es (Persona física → Obtener certificado; la forma más fácil
  suele ser con la app de videoidentificación) y que, cuando le llegue, haga doble clic en el .p12 para instalarlo.
  Puede continuar con el resto y volver aquí después.
- Si hay uno caducado y otro válido: recomiéndale borrar el caducado (Acceso a Llaveros → Mis certificados), si no Chrome
  pregunta cada vez.

## Fase 5 — AutoFirma
Comprueba `ls /Applications | grep -i autofirma`.
- Si no está: https://firmaelectronica.gob.es/Home/Descargas.html → AutoFirma para macOS; instalar con doble clic.
- Pídele que abra AutoFirma → Preferencias → General y marque:
  "Usar también en las llamadas a AutoFirma desde el navegador" y "Usar solo certificados específicos para firma (no repudio)".
  Guardar.

## Fase 6 — Chrome: que elija el certificado solo (recomendado)
Explica qué hace y por qué: sin esto, Chrome enseña una lista de certificados cada vez que entra en Interior o firma;
con esto, Chrome usa solo su certificado FNMT en las webs de Cl@ve e Interior. Ofrece ejecutarlo tú con Bash
(pide permiso) o que lo pegue él en la Terminal:
```
defaults write com.google.Chrome AutoSelectCertificateForUrls -array \
 '<string>{"pattern":"https://[*.]clave.gob.es","filter":{"ISSUER":{"CN":"AC FNMT Usuarios"}}}</string>' \
 '<string>{"pattern":"https://[*.]mir.es","filter":{"ISSUER":{"CN":"AC FNMT Usuarios"}}}</string>'
```
Luego, guíale:
1. Cerrar Chrome del todo (Cmd+Q) y abrirlo.
2. Abrir `chrome://policy` y comprobar que aparece *AutoSelectCertificateForUrls* con estado OK (pídele captura si dudas).
3. Avisarle: la primera vez que entre, el Mac pedirá permiso para la clave del certificado → **Permitir siempre**.
4. Si en la fase 4 había más de un certificado FNMT, que borre el caducado: con dos, Chrome vuelve a preguntar.
Necesita además la extensión **Claude in Chrome** instalada y conectada.

## Fase 7 — Prueba de acceso (sin presentar nada)
Con Claude in Chrome: https://sede.interior.gob.es/portal/sede/tramites?codAgrupacion=Drones → **Acceso** en
"Comunicación de vuelo de aeronave pilotada por control remoto" → Cl@ve → **Access eIdentifier**.
Si sale el selector de certificado, que elija el suyo (nunca Cancelar: si cancela, Chrome lo recuerda → Cmd+Q y repetir).
Si el llavero pide permiso: "Permitir siempre". ✅ cuando la URL sea `https://drones.ses.mir.es/drones-web/acceso`.

## Fase 8 — Dónde guardar (opcional)
No sugieras ningún servicio concreto ni lo pongas como opción por defecto (nada de "Sí, en iCloud").
1. Mira qué tiene instalado (solo lectura): `ls -d ~/Dropbox ~/Library/CloudStorage/* ~/Library/Mobile\ Documents/com~apple~CloudDocs 2>/dev/null`
   (Dropbox, Google Drive, OneDrive, iCloud Drive…).
2. Pregunta abierta: "¿Quieres una copia de los justificantes en alguna carpeta que veas en el móvil? Tienes instalado: <lista>.
   ¿Cuál prefieres, o ninguna?". Ofrece como opciones solo los que tenga instalados + "Ninguna".
3. Guarda la ruta elegida en `perfil.yaml > guardado.carpeta_movil` (p.ej. `~/Dropbox/drones/comunicaciones`) y crea la carpeta.
   Si elige uno que no tiene instalado, explícale que instale su app de escritorio primero.

## Final
Resumen de una pantalla: operador y piloto (los dos números etiquetados), teléfono, drones, certificado (caducidad),
AutoFirma, Chrome. Y explícale, con estas palabras o parecidas:
- **Ya no hay que volver a configurar.** Todo queda guardado en esta carpeta. Solo vuelve a decir "configúrame" (o
  "cambia mi …") si renueva el certificado, cambia de dron, de teléfono o de observador.
- **Las próximas veces:** abre Chrome → app de Claude → Code → carpeta `fpv-kit` (sale en recientes) → pide
  *"comunicado en <sitio> el <día> de 9 a 13"*. Cada conversación nueva empieza de cero, pero lee sus datos de la carpeta.
- Al final solo tendrá que decir **"firma"** y aceptar en AutoFirma.
