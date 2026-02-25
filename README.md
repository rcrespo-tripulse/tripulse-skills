# Guia tecnica: Skills para agentes de IA

## Indice

- [1) Que son las Skills](#1-que-son-las-skills)
- [2) Como funcionan](#2-como-funcionan)
- [3) Estructura de este repositorio](#3-estructura-de-este-repositorio)
- [4) Compatibilidad multi-agente](#4-compatibilidad-multi-agente)
- [5) Casos de uso mas comunes](#5-casos-de-uso-mas-comunes)
- [6) Por que utilizar `skills.sh`](#6-por-que-utilizar-skillssh)
- [7) Como crear una skill propia (con skill-creator)](#7-como-crear-una-skill-propia-con-skill-creator)
- [8) Como instalar una skill](#8-como-instalar-una-skill)
- [9) Como los agentes descubren y utilizan skills](#9-como-los-agentes-descubren-y-utilizan-skills)
- [10) Seguridad y gobernanza](#10-seguridad-y-gobernanza)
- [11) Convencion interna sugerida](#11-convencion-interna-sugerida)
- [12) Playbook corto de adopcion](#12-playbook-corto-de-adopcion)
- [Referencias](#referencias)

## 1) Que son las Skills

Las **skills** son capacidades reutilizables para agentes de IA. En la practica, son paquetes de conocimiento procedimental (instrucciones, flujos y convenciones) que un agente puede cargar para ejecutar tareas especializadas con mas consistencia.

Piensalas como:

- extensiones de comportamiento para el agente;
- playbooks operativos versionables en Git;
- bloques reutilizables para estandarizar como trabaja el equipo.

## 2) Como funcionan

Una skill se define como un directorio con un archivo `SKILL.md` que incluye frontmatter YAML.

Ejemplo minimo:

```markdown
---
name: mi-skill
description: Cuando usarla y que resuelve
---

# Mi Skill

Instrucciones operativas para el agente.
```

Campos clave del frontmatter:

- `name` (requerido): identificador unico (minusculas, guiones).
- `description` (requerido): para que sirve y en que contexto se activa. Es el mecanismo principal de trigger — el agente decide si cargar la skill en base a este campo.
- `metadata.internal` (opcional): oculta la skill del descubrimiento normal.

Flujo operativo simplificado:

1. Instalamos skills en rutas compatibles con cada agente.
2. El agente descubre skills por ruta/indice.
3. El agente decide usarla (o se le fuerza por prompt/herramienta).
4. Carga instrucciones de `SKILL.md` y ejecuta el flujo.

## 3) Estructura de este repositorio

Este repositorio contiene tres directorios relacionados con skills. La CLI `skills.sh` usa **symlinks** para mantener una unica copia canonica de cada skill y enlazarla a las rutas que necesita cada agente.

```text
tripulse-skills/
├── .agents/skills/          # Copia canonica de skills instaladas
│   ├── prompt-engineering-patterns/
│   └── skill-creator/
├── .agent/skills/           # Symlinks → .agents/skills/*
│   ├── prompt-engineering-patterns -> ../../.agents/skills/prompt-engineering-patterns
│   └── skill-creator -> ../../.agents/skills/skill-creator
├── skills/                  # Skills propias o adicionales del repo
│   ├── living-docs/
│   └── skill-creator/
├── skills-lock.json         # Lock file con hashes de skills instaladas
└── README.md
```

### Por que existen `.agents/` y `.agent/`

Diferentes agentes buscan skills en diferentes rutas de proyecto. Por ejemplo:

| Directorio          | Agentes que lo usan                                                   |
| ------------------- | --------------------------------------------------------------------- |
| `.agents/skills/` | Codex, OpenCode, Cursor, Gemini CLI, GitHub Copilot, Amp, entre otros |
| `.agent/skills/`  | Antigravity                                                           |
| `.claude/skills/` | Claude Code                                                           |
| `.cline/skills/`  | Cline                                                                 |

La CLI `npx skills add` almacena una **unica copia** en `.agents/skills/` (u otra ruta canonica) y crea **symlinks** en las demas rutas que necesitan otros agentes. Asi se evita duplicar archivos y se mantiene una sola fuente de verdad.

> La tabla completa de agentes y rutas esta en la [documentacion oficial de skills.sh](https://github.com/vercel-labs/skills#supported-agents).

### El directorio `skills/`

El directorio `skills/` en la raiz es UNA de las rutas estandar donde la CLI busca skills dentro de un repositorio. Aqui se pueden colocar skills propias del proyecto que se quieran compartir o distribuir.

## 4) Compatibilidad multi-agente

`skills.sh` soporta mas de **40 agentes** de IA. Algunos de los mas relevantes:

| Agente         | Flag `--agent`   | Ruta de proyecto      | Ruta global                     |
| -------------- | ------------------ | --------------------- | ------------------------------- |
| Claude Code    | `claude-code`    | `.claude/skills/`   | `~/.claude/skills/`           |
| Codex          | `codex`          | `.agents/skills/`   | `~/.codex/skills/`            |
| OpenCode       | `opencode`       | `.agents/skills/`   | `~/.config/opencode/skills/`  |
| Cursor         | `cursor`         | `.agents/skills/`   | `~/.cursor/skills/`           |
| GitHub Copilot | `github-copilot` | `.agents/skills/`   | `~/.copilot/skills/`          |
| Gemini CLI     | `gemini-cli`     | `.agents/skills/`   | `~/.gemini/skills/`           |
| Cline          | `cline`          | `.cline/skills/`    | `~/.cline/skills/`            |
| Roo Code       | `roo`            | `.roo/skills/`      | `~/.roo/skills/`              |
| Windsurf       | `windsurf`       | `.windsurf/skills/` | `~/.codeium/windsurf/skills/` |
| Amp            | `amp`            | `.agents/skills/`   | `~/.config/agents/skills/`    |

La lista completa (40+) esta disponible en: https://github.com/vercel-labs/skills#supported-agents

Al instalar, se puede apuntar a agentes especificos:

```bash
# Instalar para agentes concretos
npx skills add vercel-labs/agent-skills -a claude-code -a codex -a opencode

# Instalar para todos los agentes detectados
npx skills add vercel-labs/agent-skills --all
```

## 5) Casos de uso mas comunes

- **Estandarizacion de entregables**: PRs, changelogs, ADRs, runbooks.
- **Buenas practicas por stack**: React, Next.js, testing, observabilidad.
- **Integraciones**: patrones para APIs externas, CLIs internas o MCP.
- **Operaciones repetitivas**: release notes, auditorias, checklists de calidad.
- **Onboarding**: encapsular convenciones del equipo en una skill.

## 6) Por que utilizar `skills.sh`

`skills.sh` funciona como directorio y ecosistema abierto para descubrir skills y facilitar su adopcion.

Ventajas practicas:

- **Descubrimiento rapido** de skills existentes via [skills.sh](https://skills.sh).
- **Instalacion estandar** via CLI (`npx skills ...`).
- **Compatibilidad multi-agente** (40+ agentes) en un solo flujo.
- **Symlinks por defecto**: una sola copia canonica, multiples agentes enlazados.
- **Versionado y distribucion por Git** (facil de auditar).
- **Senales de adopcion** mediante leaderboard basado en telemetria anonima.

## 7) Como crear una skill propia (con skill-creator)

La skill mas importante del ecosistema es **skill-creator**: una meta-skill que guia paso a paso la creacion de nuevas skills efectivas.

### Prerequisito: instalar skill-creator

Si `skill-creator` no esta disponible en el agente, instalarla:

```bash
npx skills add https://github.com/anthropics/skills --skill skill-creator
```

### Estructura de una skill

```text
mi-skill/
├── SKILL.md              # (requerido) Frontmatter YAML + instrucciones
├── scripts/              # (opcional) Codigo ejecutable (Python, Bash, etc.)
├── references/           # (opcional) Documentacion para cargar en contexto bajo demanda
└── assets/               # (opcional) Archivos para usar en la salida (templates, imagenes, etc.)
```

### Paso a paso

#### Paso 1: Entender la skill con ejemplos concretos

Antes de escribir codigo, definir claramente los escenarios de uso:

- Que funcionalidad debe soportar la skill?
- Como la invocaria un usuario? Que diria para activarla?
- Que resultado espera?

Ejemplo: si se va a crear una skill `pdf-editor`, los escenarios podrian ser: "rotar este PDF", "extraer texto de este PDF", "combinar estos PDFs".

#### Paso 2: Planificar los recursos reutilizables

Analizar cada escenario e identificar que contenido conviene empaquetar:

| Tipo            | Cuando usarlo                                    | Ejemplo                   |
| --------------- | ------------------------------------------------ | ------------------------- |
| `scripts/`    | Codigo que se reescribiria cada vez              | `scripts/rotate_pdf.py` |
| `references/` | Documentacion/schemas para consultar en contexto | `references/schema.md`  |
| `assets/`     | Archivos de salida (templates, imagenes)         | `assets/boilerplate/`   |

#### Paso 3: Inicializar la skill

Usar el script de inicializacion que viene con skill-creator:

```bash
python .agents/skills/skill-creator/scripts/init_skill.py mi-skill --path ./skills
```

Esto genera la estructura de directorios con un `SKILL.md` template y directorios de ejemplo (`scripts/`, `references/`, `assets/`).

Alternativa con la CLI:

```bash
npx skills init mi-skill
```

#### Paso 4: Editar la skill

Completar `SKILL.md` con:

1. **Frontmatter**: `name` y `description` claros. La description es el mecanismo de trigger — incluir todos los contextos en los que debe activarse.
2. **Body**: instrucciones operativas en Markdown. Usar verbos imperativos, ser conciso, evitar duplicar lo que el modelo ya sabe.

Principios clave:

- **Conciso**: el contexto es un recurso compartido. Solo incluir lo que el modelo no sabe.
- **Grados de libertad**: instrucciones rigidas para operaciones fragiles, flexibilidad para tareas con multiples enfoques validos.
- **Progressive disclosure**: mantener `SKILL.md` < 500 lineas. Mover contenido detallado a `references/`.

Implementar los recursos (`scripts/`, `references/`, `assets/`) identificados en el paso 2. Eliminar los archivos de ejemplo que no se necesiten.

#### Paso 5: Empaquetar y validar

```bash
python .agents/skills/skill-creator/scripts/package_skill.py ./skills/mi-skill
```

El script valida el frontmatter, la estructura y la calidad de la description. Si pasa, genera un archivo `.skill` distribuible.

#### Paso 6: Iterar

Usar la skill en tareas reales, identificar fricciones, y refinar. Las mejores skills se pulen con uso real.

## 8) Como instalar una skill

Instalacion basica:

```bash
npx skills add vercel-labs/agent-skills
```

Instalar skills especificas:

```bash
npx skills add vercel-labs/agent-skills --skill frontend-design --skill skill-creator
```

Instalar para agentes concretos:

```bash
npx skills add vercel-labs/agent-skills -a claude-code -a codex -a opencode
```

Instalacion global (disponible en todos los proyectos):

```bash
npx skills add vercel-labs/agent-skills -g
```

### Formatos de fuente soportados

```bash
# GitHub shorthand (owner/repo)
npx skills add vercel-labs/agent-skills

# URL completa de GitHub
npx skills add https://github.com/vercel-labs/agent-skills

# Path directo a una skill en un repo
npx skills add https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines

# Path local
npx skills add ./my-local-skills
```

### Metodos de instalacion

| Metodo                          | Descripcion                                                                          |
| ------------------------------- | ------------------------------------------------------------------------------------ |
| **Symlink** (por defecto) | Crea symlinks desde cada agente hacia una copia canonica. Una sola fuente de verdad. |
| **Copy** (`--copy`)     | Crea copias independientes. Usar cuando symlinks no estan soportados.                |

### Comandos utiles de operacion

```bash
npx skills list              # Listar skills instaladas
npx skills find [query]      # Buscar skills por keyword
npx skills check             # Verificar actualizaciones disponibles
npx skills update            # Actualizar skills a ultima version
npx skills remove [skills]   # Eliminar skills instaladas
npx skills init [name]       # Crear template de SKILL.md
```

## 9) Como los agentes descubren y utilizan skills

### Descubrimiento

La CLI busca skills en rutas estandar dentro del repositorio:

- Raiz del repo (si contiene `SKILL.md`)
- `skills/`
- `.agents/skills/`, `.agent/skills/`
- Rutas especificas de cada agente (`.claude/skills/`, `.cline/skills/`, etc.)

Si no encuentra rutas estandar, hace busqueda recursiva.

### Uso en runtime

Un agente puede:

- Seleccionar skills por `description` y contexto de la tarea actual.
- Cargar instrucciones de `SKILL.md` como contexto operativo.
- Ejecutar pasos/herramientas segun la skill define.
- Cargar `references/` bajo demanda para no saturar el contexto.

## 10) Seguridad y gobernanza

- Revisar `SKILL.md` antes de instalar skills de terceros.
- Preferir repositorios confiables/verificados.
- Definir una allowlist de skills aprobadas internamente.
- Tratar skills como codigo: PR, code review y versionado.

### Scope de instalacion

| Scope             | Flag      | Ubicacion             | Caso de uso                                    |
| ----------------- | --------- | --------------------- | ---------------------------------------------- |
| **Project** | (default) | `./<agent>/skills/` | Compartir con el equipo via repo               |
| **Global**  | `-g`    | `~/<agent>/skills/` | Preferencias personales en multiples proyectos |

### Telemetria

- La CLI reporta telemetria anonima de instalacion para ranking.
- Se puede desactivar con `DISABLE_TELEMETRY=1` o `DO_NOT_TRACK=1`.

## 11) Convencion interna sugerida

- Crear repositorio `company-agent-skills`.
- Tener carpetas por dominio (`backend/`, `frontend/`, `ops/`).
- Definir plantilla comun de `SKILL.md` y checklist de calidad.

## 12) Playbook corto de adopcion

1. Pilotear 2-3 skills en un squad (1-2 semanas).
2. Medir impacto: tiempo de entrega, retrabajo, calidad.
3. Publicar v1 de skills internas en repo central.
4. Instalar por proyecto en repos clave.
5. Establecer ciclo de mantenimiento mensual (`skills check/update`).

## Referencias

- [skills.sh](https://skills.sh/) — Directorio y ecosistema de skills
- [skills.sh docs](https://skills.sh/docs) — Documentacion oficial
- [skills.sh CLI docs](https://skills.sh/docs/cli) — Referencia de la CLI
- [vercel-labs/skills](https://github.com/vercel-labs/skills) — Repositorio de la CLI (incluye tabla completa de agentes)
- [Agent Skills Specification](https://agentskills.io) — Especificacion compartida entre agentes
