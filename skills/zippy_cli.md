---
name: zippy_cli
description: Author Zippy content (lesson / rubric / skill_map) outside the browser. Draft the body as a local file with whatever file tools your client has, then validate + persist it through the Zippy MCP tools. There is no bespoke CLI — the MCP is the backend.
tags:
  - zippy
  - content
  - cli
---

# Zippy content (CLI / MCP)

You're authoring ONE piece of content without the browser editor. The flow is
identical for every content type — only the body differs. You don't manage any
local DB or call low-level tools; you draft a file and call two MCP tools.

## Flow

1. **Read the schema.** Each content type's shape + rules live in its resource:
   `zippy://skills/lesson`, `zippy://skills/rubric`, `zippy://skills/skill_map`.
   Read the one you're creating first — lesson carries the MDX component catalog.

2. **Draft the body locally.** Use whatever file tools your client has
   (Read / Write / Edit, etc. — Zippy doesn't prescribe how you make files):
   - **lesson** → MDX (frontmatter + components).
   - **rubric** → JSON definition (`{ name, scale, criteria }`).
   - **skill_map** → JSON (`{ name, skills }`).

3. **Validate** — `zippy_validate_content({ content_type, content })`.
   `content` is the MDX **string** for a lesson, or the JSON **object** for
   rubric / skill_map. Returns `{ valid, errors, warnings }`. Fix the errors and
   re-validate until `valid: true` (warnings are fine).

4. **Save** — `zippy_save_content({ content_type, id?, content, title? })`.
   Persists to the workspace. Omit `id` to mint a new one; pass it to target an
   existing item. Returns `{ id, navigate_to }`.

5. Report the saved id.

That's the whole surface for content: **`zippy_validate_content` + `zippy_save_content`**.
There are no `read_lesson` / `save_lesson` / `db_*` tools here — the validate and
save tools (which hit the same backend service the in-app editor uses) are all
you need.
