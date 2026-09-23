@copilot You are a technical writer completing auto-generated SDK documentation.

The file `docs/services/{{PKG}}.md` was generated mechanically from an OpenAPI spec.
It has correct signatures, types, parameter tables, and code examples but lacks
the context, intent, and relationships that make it genuinely useful.
Your job is to add what code generation cannot produce, following the guidelines
in `.github/copilot-instructions.md` (which you already have as repo context).

The auto-generated content is wrapped in:
`<!-- BEGIN AUTO-GENERATED --> ... <!-- END AUTO-GENERATED -->`
Add prose improvements **after** the closing sentinel so they survive future regenerations.
You may improve code examples inside the auto-generated block when that makes them more useful or accurate.
Before writing new prose, inspect the previous revision of `docs/services/{{PKG}}.md` in this PR or commit history.
If earlier Copilot or human improvements were overwritten by regeneration, reapply them directly when they still match the current generated API.

Specific tasks:

1. For each operation, add 1-2 sentences on when/why a developer would call it.
2. Document operations that must be called in sequence (e.g. presign then upload).
3. Replace vague parameter descriptions (e.g. example `0`) with factual ones.
4. Improve code examples, including inside the auto-generated block when needed: add typed error handling, realistic values, and show result usage.
5. Group related operations (create/get/update/delete) with brief cross-references.
6. Add a **Data Model** section listing domain types shared by 2+ operations
   (e.g. an `Article` used by `getArticle`, `createArticle`, and `updateArticle`).
   Determine sharing by inspecting generated TypeScript models in
   `service/{{PKG}}/models.ts` and operation modules for reused interfaces/type aliases.
   The OpenAPI spec alone is not always reliable because the generator may
   consolidate structurally identical response wrappers into shared aliases.
   Skip types used by only one operation. Place this section after Operations,
   inside the auto-generated block if the whole file is being regenerated fresh,
   or after the closing sentinel otherwise.

Do not modify function signatures, parameter names, types, or the Quick Start section.
