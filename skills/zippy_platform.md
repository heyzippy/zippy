---
name: zippy_platform
description: Zippy Platform API Reference
tags:
  - zippy
  - api
  - platform
---

# Zippy Platform API Reference

**For the full machine-readable API spec, fetch:**
```
GET {base_url}/api/docs/openapi.json
```
This returns the complete OpenAPI 3.1 spec with all request/response schemas.

**Auth:** All `/admin/*` endpoints require:
- `Authorization: Bearer <api_key>`
- `x-org-id: <workspace_id>`

## Content Library

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/content` | List all content (lessons, rubrics, skill maps, evaluations) in the workspace |
| POST | `/admin/content` | Register a resource in the content library |
| PUT | `/admin/content/visibility` | Change visibility (personal / workspace / public) |
| GET | `/admin/content/discover` | Discover public content across all workspaces |
| POST | `/admin/content/clone` | Clone a content item into your workspace |
| DELETE | `/admin/content/bulk` | Bulk-delete multiple content items |
| GET | `/admin/content/tags` | List tags for a content item |
| POST | `/admin/content/tags` | Add a tag (subject, category, grade_level, standard) |
| DELETE | `/admin/content/tags/{tag_id}` | Delete a tag |

## Lessons

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/lessons` | Create a lesson |
| GET | `/admin/lessons/{lesson_id}` | Get lesson by ID |
| PUT | `/admin/lessons/{lesson_id}` | Update a lesson |
| DELETE | `/admin/lessons/{lesson_id}` | Delete a lesson (soft) |
| POST | `/admin/lessons/{lesson_id}/clone` | Clone a lesson |
| GET | `/admin/units` | List all units |
| POST | `/admin/units` | Create a unit |
| PUT | `/admin/units/{unit_id}` | Update a unit |
| DELETE | `/admin/units/{unit_id}` | Delete a unit (soft, cascades to lessons) |
| POST | `/admin/units/{unit_id}/clone` | Clone a unit with its lessons |

## Rubrics

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/rubrics` | List rubrics |
| POST | `/admin/rubrics` | Create a rubric |
| POST | `/admin/rubrics/from-skills` | Create a rubric from skill IDs |
| POST | `/admin/rubrics/resolve-skills` | Preview skill resolution without saving |
| GET | `/admin/rubrics/{rubric_id}` | Get rubric with skills resolved |
| PUT | `/admin/rubrics/{rubric_id}` | Update a rubric |
| DELETE | `/admin/rubrics/{rubric_id}` | Delete a rubric |

## Courses

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/courses` | Create a course |
| POST | `/admin/courses/init` | Create an empty course and return IDs |
| GET | `/admin/courses/{course_id}` | Get course details |
| PUT | `/admin/courses/{course_id}` | Update a course |
| DELETE | `/admin/courses/{course_id}` | Delete a course |

## Questions

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/questions` | List questions (filter by `skillId`, `limit`) |
| GET | `/admin/questions/{question_id}` | Get question with evaluation |
| PUT | `/admin/questions/{question_id}/evaluation` | Update evaluation config |
| GET | `/student/questions` | Student: list questions |
| GET | `/student/questions/{question_id}` | Student: get question with evaluation |

**Note:** The `evaluation` field is included in every question response — no separate fetch needed.

## Content Generation

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/content/validate` | Dry-run validation (no side effects) |
| POST | `/admin/content/generate` | Validate + create + register in one step |
| POST | `/admin/content/publish` | Publish a full course pack atomically |
| POST | `/admin/content/publish/validate` | Dry-run publish validation |
| POST | `/admin/content/publish/standalone` | Publish standalone content |

## Evaluations

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/evaluations` | Create evaluation config |
| GET | `/admin/evaluations` | List evaluation configs |
| GET | `/admin/evaluations/{id}` | Get evaluation config |
| PUT | `/admin/evaluations/{id}` | Update evaluation config |
| POST | `/admin/evaluations/{id}/run` | Run an evaluation (test) |
| GET | `/admin/evaluations/{id}/answers` | List answers for an evaluation |
| POST | `/admin/evaluations/run` | Run evaluation on submitted answers |

## Activities & Grading

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/activities` | List activities |
| POST | `/admin/activities` | Create an activity |
| GET | `/admin/activities/{id}` | Get activity details |
| PUT | `/admin/activities/{id}` | Update an activity |
| DELETE | `/admin/activities/{id}` | Delete an activity |
| POST | `/admin/activities/{id}/clone` | Clone an activity |
| GET | `/admin/activities/{id}/submissions` | List submissions |
| POST | `/admin/activities/{id}/bulk-submissions` | Bulk-create submissions |
| POST | `/admin/activities/{id}/grade-submissions` | Grade submissions |
| GET | `/admin/activities/{id}/gradebook` | Get gradebook |
| GET | `/admin/activities/{id}/grading-readiness` | Check if ready for grading |
| GET | `/admin/grading/overview` | Grading overview |
| GET | `/admin/grading/presets` | List grading presets |
| GET | `/admin/import/detect` | Detect content from uploaded document |

## Dashboard

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/dashboard/stats` | Global workspace stats (courses, users, enrollments, etc.) |
| GET | `/admin/dashboard/teacher-overview` | Teacher-specific overview |
| GET | `/admin/dashboard/courses` | All courses with per-course stats |
| GET | `/admin/dashboard/events` | Account activity events |
| GET | `/admin/dashboard/feed` | Org-wide activity feed |

## Classes & Students

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/classes` | List classes |
| POST | `/admin/classes` | Create a class |
| GET | `/admin/classes/{id}` | Get class details |
| PUT | `/admin/classes/{id}/archive` | Archive a class |
| GET | `/admin/classes/{id}/members` | List class members |
| POST | `/admin/classes/{id}/members` | Add member |
| DELETE | `/admin/classes/{id}/members/{member_id}` | Remove member |
| POST | `/admin/classes/{id}/invite` | Invite to class |
| POST | `/admin/classes/{id}/join-link` | Generate join link |
| GET | `/admin/students` | List students |
| POST | `/admin/students/invite` | Invite students |
| POST | `/admin/students/import` | Import students from CSV |

## Skill Maps

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/skill-maps` | Create a skill map |
| PUT | `/admin/skill-maps/{id}` | Update a skill map |
| DELETE | `/admin/skill-maps/{id}` | Delete a skill map |

## Catalog (Public)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/courses` | List published courses |
| GET | `/courses/{course_id}/curriculum` | Get course curriculum tree |
| GET | `/courses/{course_id}/units` | List course units |
| GET | `/courses/{course_id}/lessons` | List course lessons |
| GET | `/courses/{course_id}/lessons/{lesson_id}` | Get a lesson |
| GET | `/skills` | List skills |
| GET | `/skill-maps` | List skill maps |
| GET | `/rubrics` | List rubrics |
| GET | `/public/schemas/{content_type}` | Get JSON schema for a content type |
| GET | `/public/standards` | Search curriculum standards |

## Workspaces

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/workspaces` | List workspaces |
| POST | `/admin/workspaces` | Create workspace |
| GET | `/admin/courses` | List courses (admin) |

## Google Drive

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/google-drive/files/{file_id}/content` | Fetch Google Drive file content |

## Common Patterns

**CLI (distri run):** Use `Bash` with curl + env vars (`$ZIPPY_API_URL`, `$ZIPPY_API_KEY`, `$ZIPPY_WORKSPACE_ID`).

**Browser (editor UI):** Use `zippy_request` tool (auto-authenticated) or content tools (`init_content`, `validate_content`, `save_content`).
