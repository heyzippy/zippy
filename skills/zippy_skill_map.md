---
name: zippy_skill_map
description: Generate a Zippy skill map from a teacher brief. Drafts live in IDB only — `init_content` allocates a local id, then a single `save_content` validates against the skill-map schema, writes the working copy, and creates the BE row on first save. The skill-map editor renders the IDB draft live; teachers edit on top and Save commits.
tags:
  - zippy
  - content
  - skill_map
---

# Zippy Skill Map

## Workflow

Skill map uses the SAME unified content tools as every other content
type — there is no skill-map-specific tool.

1. `write_todos` with the phases: initialise, draft skills, save.
2. **Get the id.** If your prompt header contains a `skill_map_id:` line
   (set by the FE when the teacher clicked New Skill Map or opened
   `/new` → Skill Map), use that EXACT id. Otherwise mint one with
   `init_content({ content_type: "skill_map", title: "<skill map name>" })`
   and use the returned `skillMapId`.
3. Build the skill-map JSON in-context and save it in ONE call:
   ```
   save_content({ content_type: "skill_map", id: "<skillMapId>", content: <skill-map JSON>, title: "<name>" })
   ```
   `save_content` validates against the skill-map schema, writes the
   `content_items[<skillMapId>]` working copy (the editor at
   `/skill-maps/<skillMapId>` renders live — drafts ARE the preview),
   creates the BE row on first save (create-if-missing) and
   library-registers it. Do NOT `db_put` the draft separately.
4. If `valid: false`, fix the JSON and call `save_content` again
   (use `validate_content({ content_type: "skill_map", id })` for a
   read-only dry run if needed).
5. `final({ result: { skill_map_id, name } })`.

## Content shape

Pass the skill-map definition as the `content` argument to `save_content`
— either a JSON object or a stringified JSON body matching the structure
below. `save_content` writes it into the `content_items` working copy for
you; you never hand-wrap a `db_put` payload.

## JSON Structure

```json
{
  "name": "Primary 6 English — Reading & Writing skills",
  "description": "Skills mapped to Singapore MOE P6 English syllabus",
  "color_code": "#6366f1",
  "level_labels": ["Beginning", "Emerging", "Developing", "Proficient", "Advanced"],
  "skills": [
    {
      "id": "reading_comp",
      "name": "Reading Comprehension",
      "description": "Understanding of texts at the literal and inferential level",
      "skill_type": "skill",
      "bands": {
        "1": "Identifies isolated facts only.",
        "2": "Identifies main idea with prompting.",
        "3": "Identifies main idea + supporting details.",
        "4": "Makes inferences supported by evidence.",
        "5": "Analyses author's purpose, tone, and craft."
      }
    },
    {
      "id": "narrative_writing",
      "name": "Narrative Writing",
      "description": "Story craft, sequencing, and language use in narrative composition",
      "skill_type": "skill",
      "parent_skill_id": null,
      "bands": {
        "1": "Single-event recount, fragmented sentences.",
        "2": "Simple beginning-middle-end with basic plot.",
        "3": "Clear plot arc with relevant details.",
        "4": "Well-developed plot with vivid description.",
        "5": "Sophisticated, layered narrative with purpose."
      }
    }
  ]
}
```

### Required fields

- `name` — workspace-visible label.
- `skills` — array of at least 2 skill entries.
- Each skill: `id` (slug, lowercase + underscores), `name`,
  `skill_type` (`"skill"` for assessable skills, `"trait"` for
  composite categories that group other skills), `bands` (object keyed
  by level number `"1"`..`"N"` matching `level_labels.length`).

### Optional fields

- `description`, `color_code`, `parent_skill_id`, per-skill `description`.

### `level_labels`

Default to 5 levels: `["Beginning","Emerging","Developing","Proficient","Advanced"]`. Use 3–5 levels. Number of `bands` entries on every skill MUST equal `level_labels.length`.

## Guidelines

- 3–10 skills per map. Group related skills under a `trait` parent
  when the curriculum is multi-domain (e.g. "Reading", "Writing").
- Band descriptors progress low → high; mirror SEAB / MOE language
  when targeting Singapore curriculum.
- Skill `id`s are stable slugs — they're used in rubric
  `from_skills` references and in question `skill_ids`.
- A skill with `skill_type: "trait"` is a grouping container; only
  skills (not traits) carry bands.

## Hard rules

- **Never call `/admin/skill-maps` directly.** Use `save_content` —
  it handles create-if-missing and library-registration with the
  same id the IDB draft uses.
- **Pass the definition via `save_content`'s `content` argument** (object
  or stringified JSON). `save_content` writes the `content_items` working
  copy for you — never hand-wrap a `db_put` payload.
- **`save_content` validates and returns `valid`.** If `valid: false`,
  fix and re-save; don't call `final` while errors exist.
