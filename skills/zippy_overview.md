---
name: zippy_overview
description: Zippy Content Generation
tags:
  - zippy
  - content
  - generation
---

# Zippy Content Generation

**Full API reference:** `load_skill({"skill_id": "zippy_platform"})` — or fetch `{base_url}/api/docs/openapi.json` for the complete OpenAPI spec.

Create educational content via the Zippy API.

## Execution Environments

Load the execution skill first — it explains which tools to use and how:

| Environment | Skill | API calls | Code execution |
|------------|-------|-----------|----------------|
| CLI (`distri run`) | `load_skill({"skill_id": "zippy_execution_cli"})` | `Bash` with curl + env vars | `Bash` |
| Browser (editor UI) | `load_skill({"skill_id": "zippy_execution_browser"})` | `zippy_request` | `run_js` |

## Content Types

| Type | Skill | Create | Update | Validate |
|------|-------|--------|--------|----------|
| Lesson (all formats) | `load_skill({"skill_id": "zippy_lesson"})` | `POST /admin/lessons` | `PUT /admin/lessons/:id` | `POST /admin/content/validate` |
| Rubric | `load_skill({"skill_id": "zippy_rubric"})` | `POST /admin/rubrics` | `PUT /admin/rubrics/:id` | `POST /admin/content/validate` |
| Skill Map | — | `POST /admin/skill-maps` | `PUT /admin/skill-maps/:id` | — |
| Course / Unit | `load_skill({"skill_id": "zippy_course"})` | `POST /admin/courses` | — | — |
| Grade / Import | `load_skill({"skill_id": "zippy_grade"})` | `POST /admin/activities` | — | — |

**Load the skill for the content type you need** — it contains the full format spec, examples, and workflow.

## Workflow

**For content creation:**
1. Load execution environment skill
2. Load content type skill
3. Create empty record → Write/Edit file → Read → Validate → Save → Share URL

**For grading/import:**
1. Load execution environment skill
2. Load grade skill → follow to `grade_local` or `grade_browser`
