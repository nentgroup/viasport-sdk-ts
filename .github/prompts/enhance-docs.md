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

When writing documentation, headings, examples, or code comments, refer to
artifacts by their role or name, such as "SDK", "client", "operation", "model",
or "API response". Do not describe an artifact as generated, auto-generated,
mechanically generated, or generator-produced. Generation details are internal
implementation context, not user-facing documentation.

1. For each operation, add 1-2 sentences on when/why a developer would call it.
2. Document operations that must be called in sequence (e.g. presign then upload).
3. Replace vague parameter descriptions (e.g. example `0`) with factual ones.
4. Improve code examples, including inside the auto-generated block when needed.
   Every example must be executable against the current generated SDK:
   - Inspect `service/{{PKG}}/client.ts`, `service/{{PKG}}/index.ts`,
     `service/{{PKG}}/operations.ts`, and `service/{{PKG}}/models.ts` before
     writing or changing an example.
   - Use the actual exported constructors, method names, argument objects,
     parameter names, and required fields. Do not invent convenience methods,
     response properties, request fields, or operation names.
   - Prefer TypeScript examples that import the real `API`, `Client`, and
     named model exports when those exports exist. Do not assume that a
     `Models` namespace is exported: verify `service/{{PKG}}/index.ts` and use
     the actual export form. Show the inferred or explicit typed result being
     read, for example `const article: Article = (await response).data`, using
     only fields present on the generated type.
   - Use `javascript` as the Markdown fence language for all TypeScript code
     examples because the documentation renderer does not support `ts` or
     `typescript` syntax highlighting.
   - Show realistic values that satisfy the generated request types and the
     current OpenAPI constraints. Keep credentials and tokens as placeholders;
     never include real secrets.
   - For known API failures, use the typed error payloads mapped in
     `operations.ts` and demonstrate fields that exist on those models. Keep
     unknown network, timeout, and unexpected-status failures as regular
     thrown errors; do not claim every error has one typed shape.
   - For pagination or dependent calls, demonstrate the exact value flow from
     one typed result into the next request (for example, extracting a cursor
     from a returned link only when that link exists).
   - Keep examples concise, and explain any type guard or optional-field check
     that is necessary.
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
Before finalizing, cross-check every code example line-by-line against the
current generated TypeScript files. If the generated SDK does not expose a
typed model or operation needed for an example, omit that example rather than
guessing.
