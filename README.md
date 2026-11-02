# Comunicados de vuelo FPV con Claude

Asistente para pilotos de dron en España que **rellena por ti la comunicación previa de vuelo al Ministerio del Interior**
(sede `drones.ses.mir.es`). Le dices una frase y él hace el resto en tu Chrome; tú solo revisas el resumen, dices
**"firma"** y aceptas en AutoFirma.

```
Tú:     comunicado el 20 en Genalguacil
Claude: busca el pueblo en Google Maps → comprueba ENAIRE Drones → crea la zona de vuelo → entra en la sede con tu
        certificado → rellena operador, piloto, drones, fechas y horas → te enseña el resumen con el mapa
Tú:     firma
Claude: presenta, descarga el acuse y el PDF, los revisa y los guarda en comunicados/
```

Funciona con [Claude Code](https://claude.com/claude-code) (la pestaña **Code** de la app de escritorio de Claude) y la
extensión **Claude in Chrome**. No es un programa con pasos fijos: son instrucciones ("skills") que Claude sigue, con
comprobaciones en cada paso.

> ⚠️ Proyecto personal, sin relación con el Ministerio del Interior, AESA ni ENAIRE. Tú eres el responsable de lo que
> presentas y de cumplir la normativa (Reglamento UE 2019/947, RD 517/2024). Revisa siempre el resumen antes de firmar.

## Qué hace
- **Configuración guiada** la primera vez (*"configúrame"*): lee tus PDF de AESA para sacar tus números de operador y
  piloto, te pregunta tus datos y drones, y comprueba certificado FNMT, AutoFirma y Chrome.
- **Comunicados de 1 o varios días** en una sola comunicación (una actividad por día y dron).
- **Zona de vuelo automática**: busca el sitio en Google Maps y genera un círculo (100 m en un lugar concreto, 500 m si
  solo dices el pueblo). Los sitios se guardan y se reutilizan.
- **Comprueba ENAIRE Drones** antes de nada: si el sitio está en zona restringida, se para y te lo explica.
- **Valores por defecto**: si no dices horario, drones u observador, no pregunta; usa tus preferencias y te lo enseña en
  el resumen para que lo corrijas.
- **Verifica** fechas, horas, teléfono y números de AESA en el formulario, contra el servidor antes de firmar, y en el PDF
  final.
- **Guarda** acuse y comunicación en `comunicados/` (y, si quieres, en una carpeta que veas en el móvil).

## Qué NO hace
- No firma por ti ni introduce contraseñas: la firma es siempre tuya, con tu certificado y AutoFirma.
- No tramita permisos de zonas restringidas (CECAF/ZRVF, Defensa, aeropuertos, parques nacionales): solo te avisa.
- No sirve para drones de construcción propia de 250 g o más en zona urbana (solo pueden volar en A3).

## Requisitos
- **Mac o Windows** con **Google Chrome**. (Windows es más nuevo: si algo falla, abre un issue.)
- **App de escritorio de Claude** ([descarga](https://claude.ai/download)) con un plan que incluya Claude Code.
- Extensión **Claude in Chrome** instalada y conectada.
- **Certificado digital FNMT** de persona física instalado en el ordenador, y **AutoFirma**
  (el asistente te explica cómo conseguirlos si no los tienes).
- Tus PDF de AESA: **certificado de registro de operador UAS** y **certificado A1/A3** del piloto
  (se descargan en [sede.seguridadaerea.gob.es](https://sede.seguridadaerea.gob.es)).

## Instalación (una sola vez, ~20 minutos)
1. Descarga el proyecto: botón verde **Code → Download ZIP** y descomprímelo (por ejemplo en Documentos),
   o `git clone` si usas git.
2. Abre la app de Claude → pestaña **Code** → abre la carpeta del proyecto.
3. Escribe **configúrame** y sigue los pasos.

Queda guardado en la carpeta. Solo hay que volver al asistente si cambia algo:

| Si cambia… | Dile |
|---|---|
| Renuevas el certificado FNMT | *"he renovado el certificado"* |
| Dron nuevo | *"añade mi dron nuevo"* |
| Teléfono, dirección u observador | *"cambia mi teléfono a …"* |
| AESA te renueva un certificado | *"aquí tienes mi nuevo certificado"* (y arrastra el PDF) |

## Uso (cada vez que vayas a volar)
1. Abre Chrome.
2. App de Claude → **Code** → la carpeta del proyecto (sale en recientes). Cada conversación empieza de cero, pero lee tus
   datos de la carpeta.
3. Pide el comunicado **al menos 5 días antes** del vuelo:
   - *"comunicado el 20 en Genalguacil"*
   - *"comunicado en la playa del Cristo, Estepona, el sábado de 9 a 13"*
   - *"comunicado en 36.4170, -5.1520 del 7 al 9 de noviembre, vuela el Pavo20"*
4. Revisa el resumen y di **"firma"**; acepta en AutoFirma.

Valores por defecto (`perfil.yaml > preferencias`):

| Si no lo dices | Se usa |
|---|---|
| Horario | todo el día (00:00–23:55) |
| Zona | círculo de 100 m en un lugar concreto; 500 m alrededor del centro si solo dices el pueblo |
| Drones | todos tus drones de menos de 250 g |
| Observador | los marcados como "por defecto" |
| Altura / tipo | 120 m, VLOS |

## Que Chrome elija tu certificado solo (recomendado)
Sin esto, Chrome te enseña la lista de certificados cada vez que entras en Interior o firmas. **El asistente lo hace por
ti durante la configuración** (en Mac y en Windows). Si lo quieres hacer a mano:

**Mac:**
1. Pega en la app **Terminal**:
   ```
   defaults write com.google.Chrome AutoSelectCertificateForUrls -array \
    '<string>{"pattern":"https://[*.]clave.gob.es","filter":{"ISSUER":{"CN":"AC FNMT Usuarios"}}}</string>' \
    '<string>{"pattern":"https://[*.]mir.es","filter":{"ISSUER":{"CN":"AC FNMT Usuarios"}}}</string>'
   ```
2. Cierra Chrome del todo (**Cmd+Q**) y ábrelo. En `chrome://policy` debe salir *AutoSelectCertificateForUrls* con estado OK.
3. La primera vez, el Mac pide permiso para la clave del certificado: **Permitir siempre**.
4. Ten **un solo** certificado FNMT en el llavero (borra los caducados), o Chrome volverá a preguntar.

**Windows:**
1. Abre la carpeta `.claude\skills\configurar\scripts\windows\` del proyecto (si no ves `.claude`: en el Explorador,
   Vista → Elementos ocultos) y haz **doble clic en `chrome-certificado.reg`** → **Sí** (permiso de administrador) → **Sí**.
2. Cierra Chrome del todo (todas las ventanas y, si queda el icono junto al reloj, clic derecho → Salir) y ábrelo.
   En `chrome://policy` debe salir *AutoSelectCertificateForUrls* con estado OK.
3. Ten **un solo** certificado FNMT (tecla Windows → `certmgr.msc` → Personal → Certificados; borra los caducados).

## Si algo falla
- *"No ha seleccionado ningún certificado"* o error 500 de Cl@ve: cierra Chrome del todo (Mac: **Cmd+Q**; Windows: todas
  las ventanas y el icono junto al reloj), ábrelo y repite. Si sale la
  lista, elige tu certificado; no pulses Cancelar (Chrome lo recuerda hasta que lo cierras).
- Cualquier duda: pregúntale *"¿cómo hago…?"*.

## Privacidad
Tus datos (`perfil.yaml`, `docs/`, `comunicados/`) solo están en tu ordenador y están excluidos de git (`.gitignore`).
No los subas ni los compartas.

## Cómo está hecho
```
CLAUDE.md                                         reglas generales para Claude
perfil.ejemplo.yaml                               plantilla del perfil (el asistente crea perfil.yaml)
.claude/skills/configurar/SKILL.md                asistente de configuración
.claude/skills/comunicado-vuelo/SKILL.md          agente de comunicados (incluye recetas del formulario de la sede)
.claude/skills/comunicado-vuelo/scripts/zona.js   genera la zona de vuelo (se ejecuta en el navegador)
.claude/skills/configurar/scripts/windows/        comprobaciones (PowerShell) y política de Chrome (.reg) para Windows
comunicados/registro.md                           tu registro de comunicaciones
```

Mejoras y correcciones bienvenidas mediante issues o pull requests (sin datos personales).

## Licencia
MIT — ver [LICENSE](LICENSE).
