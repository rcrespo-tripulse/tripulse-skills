# Guia tecnica: Skills para agentes de IA

## 1) Que son las Skills

Las **skills** son capacidades reutilizables para agentes de IA. En la practica, son paquetes de conocimiento procedimental (instrucciones, flujos y convenciones) que un agente puede cargar para ejecutar tareas especializadas con mas consistencia.

Piensalas como:

- extensiones de comportamiento para el agente;
- playbooks operativos versionables en Git;
- bloques reutilizables para estandarizar como trabaja el equipo.

## 2) Como funcionan

Una skill se define normalmente como un directorio con un archivo `SKILL.md` que incluye frontmatter YAML.

Ejemplo minimo:

```markdown
---
name: mi-skill
description: Cuando usarla y que resuelve
---

# Mi Skill

Instrucciones operativas para el agente.
```

Campos clave:

- `name` (requerido): identificador unico (minusculas, guiones).
- `description` (requerido): para que sirve y en que contexto se activa.
- `metadata.internal` (opcional): oculta la skill del descubrimiento normal.

Flujo operativo simplificado:

1. Instalamos skills en rutas compatibles con cada agente.
2. El agente descubre skills por ruta/indice.
3. El agente decide usarla (o se le fuerza por prompt/herramienta).
4. Carga instrucciones de `SKILL.md` y ejecuta el flujo.

## 3) Casos de uso mas comunes

- **Estandarizacion de entregables**: PRs, changelogs, ADRs, runbooks.
- **Buenas practicas por stack**: React, Next.js, testing, observabilidad.
- **Integraciones**: patrones para APIs externas, CLIs internas o MCP.
- **Operaciones repetitivas**: release notes, auditorias, checklists de calidad.
- **Onboarding**: encapsular convenciones del equipo en una skill.

## 4) Por que utilizar `skills.sh`

`skills.sh` funciona como directorio y ecosistema abierto para descubrir skills y su adopcion.

Ventajas practicas:

- **Descubrimiento rapido** de skills existentes.
- **Instalacion estandar** via CLI (`npx skills ...`).
- **Compatibilidad multi-agente** en un solo flujo.
- **Versionado y distribucion por Git** (facil de auditar).
- **Senales de adopcion** mediante leaderboard basado en telemetria anonima.

## 5) Como crear una skill propia

### Estructura recomendada

```text
mi-repo-skills/
  skills/
    mi-skill/
      SKILL.md
```

### Pasos

1. Inicializar plantilla:

```bash
npx skills init mi-skill
```

2. Completar `SKILL.md` con:

- objetivo y alcance;
- cuando usarla / cuando no usarla;
- pasos secuenciales claros;
- criterios de validacion/salida.

3. Publicar en GitHub/GitLab (o usar repositorio interno).
4. Probar instalacion con `npx skills add <owner/repo> --list`.

Buenas practicas para autoria:

- Mantener instrucciones accionables (verbos concretos).
- Evitar ambiguedad y sobrecarga de contexto.
- Incluir guardrails (seguridad, no destructivo, validaciones).
- Versionar cambios importantes y documentar compatibilidad.

## 6) Como instalar una skill

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

Instalacion global:

```bash
npx skills add vercel-labs/agent-skills -g
```

Comandos utiles de operacion:

```bash
npx skills list
npx skills find typescript
npx skills check
npx skills update
npx skills remove <skill>
```

## 7) Como los agentes ven, descubren y utilizan skills

### Descubrimiento

El ecosistema `skills` busca skills en rutas estandar como:

- raiz del repo (si contiene `SKILL.md`),
- `skills/`,
- `.agents/skills/`, `.agent/skills/`,
- rutas especificas de cada agente (`.claude/skills/`, `.kiro/skills/`, etc.).

Si no encuentra rutas estandar, hace busqueda recursiva.

### Resolucion por agente

Cada agente tiene una ruta de skills de proyecto y una global. Ejemplo:

- Codex proyecto: `.agents/skills/`
- Codex global: `~/.codex/skills/`
- OpenCode proyecto: `.agents/skills/`
- OpenCode global: `~/.config/opencode/skills/`

### Uso en runtime

Un agente puede:

- seleccionar skills por descripcion y contexto de la tarea,
- cargar instrucciones como contexto operativo,
- ejecutar pasos/herramientas segun la skill.

Nota: algunos agentes requieren configuracion adicional para exponer recursos de skills (por ejemplo, Kiro CLI en recursos del agente).

## 8) Que agents, providers e IDEs soportan skills

### Agents (ejemplos confirmados en el ecosistema)

Claude Code, Codex, OpenCode, Cursor, Cline, Roo, Windsurf, GitHub Copilot, Gemini CLI, Kiro CLI, Amp, entre muchos otros.

### IDEs / entornos

- VS Code (integraciones de agentes que soportan skills)
- Cursor
- Windsurf
- Trae

### Providers

No se modela como "soporte por provider LLM" de forma directa, sino por **agente/cliente**. En la practica, hay agentes sobre Anthropic, OpenAI, Google y GitHub que ya soportan skills.

## 9) Otros puntos clave para el equipo

### Seguridad y gobernanza

- Revisar `SKILL.md` antes de instalar skills de terceros.
- Preferir repositorios confiables/verificados.
- Definir una allowlist de skills aprobadas internamente.
- Tratar skills como codigo: PR, code review y versionado.

### Scope de instalacion

- **Project scope**: ideal para compartir skill con el equipo via repo.
- **Global scope**: util para preferencias personales en multiples proyectos.

### Telemetria

- La CLI reporta telemetria anonima de instalacion para ranking.
- Se puede desactivar con `DISABLE_TELEMETRY=1` o `DO_NOT_TRACK=1`.

### Convencion interna sugerida

- Crear repositorio `company-agent-skills`.
- Tener carpetas por dominio (`backend/`, `frontend/`, `ops/`).
- Definir plantilla comun de `SKILL.md` y checklist de calidad.

## 10) Playbook corto de adopcion (recomendado)

1. Pilotear 2-3 skills en un squad (1-2 semanas).
2. Medir impacto: tiempo de entrega, retrabajo, calidad.
3. Publicar v1 de skills internas en repo central.
4. Instalar por proyecto en repos clave.
5. Establecer ciclo de mantenimiento mensual (`skills check/update`).

## Referencias

- `https://skills.sh/`
- `https://skills.sh/docs`
- `https://skills.sh/docs/cli`
- `https://skills.sh/docs/faq`
- `https://github.com/vercel-labs/skills`

> Nota: la URL `https://github.com/vercel-labs/skill` no existe actualmente; el repositorio oficial de la CLI es `vercel-labs/skills`.
