---
name: dev-specs
description: Provide reusable Markdown specification templates for software delivery, starting with a functional specification document. Use when asked to create, draft, fill, adapt, or standardize development specs, functional specs, technical specs, acceptance criteria, scope documents, or requirements documents for a feature, module, API, workflow, or project.
---

# Dev Specs

Provide developers and analysts with reusable specification templates. Start from the closest template in `assets/templates/`, copy it into the working location, then tailor sections to the user's domain and remove irrelevant placeholders.

## Workflow

1. Identify the requested deliverable type.
2. Select the closest template from `assets/templates/`.
3. Copy the template content into the target file or response.
4. Replace bracketed placeholders with project-specific information when the user provides it.
5. Remove sections that do not apply instead of leaving noisy empty headings.
6. Keep requirements measurable, testable, and implementation-neutral unless the user explicitly wants solution detail.

## Available Templates

### Functional specification document

- Path: `assets/templates/functional-specification-document.md`
- Use for feature scope, actors, functional requirements, interfaces, validations, workflows, outputs, dependencies, non-functional requirements, and acceptance criteria.

## Adaptation Rules

- Preserve the template structure unless the user asks for a lighter or stricter format.
- Keep section numbering stable when editing an existing spec.
- Convert vague requests into concrete statements only when the intent is clear.
- Mark unknown information with bracketed placeholders instead of inventing facts.
- Prefer concise bullet points over long prose inside requirement sections.
- Write acceptance criteria as observable outcomes.

## Template Handling

- If the user asks for a new spec, start from the template and fill what is known.
- If the user shares an incomplete draft, merge its content into the closest template.
- If the user wants a company-specific variant, duplicate the base template into `assets/templates/` and adapt only the needed sections.

## Assets

- `assets/templates/functional-specification-document.md`: base template for functional specifications.
