---
name: zippy_course
description: Zippy Course Pack Format
tags:
  - zippy
  - content
  - generation
---

# Zippy Course Pack Format

Course-pack publishing is **CLI-only** (the layout is a directory tree of
YAML + MDX files). The browser branch of `zippy_execution` does NOT apply
here — if you're invoked in the browser runtime, `final({ result: "course
packs are CLI-only; run the distri CLI from your terminal" })` and stop.

A course pack is a directory of YAML and Markdown files pushed via the CLI.

## Workspace Structure

```
content/<workspace>/
  workspace.yaml          # Lists which subdirs are courses
  <course-id>/            # One dir per course
    course.yaml           # Course metadata (required)
    units.yaml            # Unit catalog (required)
    skills.yaml           # Skill hierarchy (optional)
    rubrics.yaml          # Rubric definitions (optional)
    evaluations.yaml      # Evaluation configs (optional)
    taxonomy.yaml         # Topic taxonomy (optional)
    units/
      <unit-id>/
        lesson-<id>.md    # Lesson files (must start with lesson-)
```

## workspace.yaml

```yaml
kind: workspace
content:
  name: "My Workspace"
  courses:
    - course-id-one
    - course-id-two
```

If absent, the CLI scans for subdirs that contain `course.yaml`.

## course.yaml

```yaml
kind: course
content:
  id: my-course-id
  name: "Course Display Name"
  description: "What this course covers."
  total_weeks: 12
```

`total_weeks` is required (use 0 if not applicable).

## units.yaml

```yaml
kind: units
content:
  - id: unit-01
    name: "Unit 1 - Introduction"
    order: 1
  - id: unit-02
    name: "Unit 2 - Core Concepts"
    order: 2
```

## skills.yaml

```yaml
kind: skills
content:
  - id: root-writing
    type: root
    name: Writing Skills
    level_labels:
      '1': Beginning
      '2': Developing
      '3': Proficient
      '4': Advanced
      '5': Excellent

  - id: trait-ideas
    type: trait
    parent_id: root-writing
    name: Ideas & Content

  - id: SK-CONTENT
    type: skill
    parent_id: trait-ideas
    name: "Content Quality"
    is_active: true
    bands:
      '1': Off-topic or minimal response.
      '2': Partially addresses the prompt. Limited detail.
      '3': Addresses the prompt with adequate coverage.
      '4': Well-developed with specific evidence and insight.
      '5': Exceptional depth, originality, and precision.
```

Types: `root` (one per course) → `trait` (grouping) → `skill` (assessable unit).

## rubrics.yaml

```yaml
kind: rubrics
content:
  - id: rubric-my-rubric-v1
    name: "My Rubric"
    criteria:
      - id: content
        label: "Content"
        weight: 1
        ratings:
          - band: 1
            description: "Minimal or irrelevant response."
          - band: 2
            description: "Partial coverage. Key aspects missing."
          - band: 3
            description: "Adequate coverage of the topic."
          - band: 4
            description: "Strong coverage with specific detail."
          - band: 5
            description: "Exceptional depth and insight."
```

## evaluations.yaml

```yaml
kind: evaluations
content:
  - id: eval-my-eval
    name: "Standard Evaluation"
    description: "Rubric-based evaluation with skill feedback"
    rubrics:
      - rubric-my-rubric-v1
      - name: "Writing Skills"
        from: [SK-CONTENT]
        group_by_trait: true
    corrections: false
    execution: together
    prompt: |
      You are evaluating a student response.
      Assess the answer against the rubric criteria.
      Provide specific, actionable feedback.
```

## Lesson Files

Lesson files **must** be named `lesson-*.md` or `lesson-*.mdx`. Other `.md` files are ignored.

### Front Matter

```yaml
---
id: lesson-unit-01
title: "Unit 1 - Introduction"
unit_id: unit-01
order: 1
duration_minutes: 60
lesson_type: learning      # "learning" or "exam"
status: published          # "published" or "hidden"
skills:
  - SK-CONTENT
---
```

### Components

```mdx
<Callout style="primary">Instructions or key points</Callout>
<Callout style="secondary">Tips and guidance</Callout>
<Callout style="tertiary">Success or transition messages</Callout>

<Sticky>
### Reference Material
Content that floats when scrolled past.
</Sticky>

<PageBreak />
```

### Questions

```mdx
<Question
  id="unit01-q01"
  kind="essay"
  stem="Write a response to the following prompt..."
  rows={10}
  required={true}
  skill_ids={["SK-CONTENT"]}
  evaluation=\{{
    "id": "eval-my-eval"
  }}
/>
```

`kind`: `mcq`, `free_text`, `essay`

For MCQ include `options={[{"id":"a","text":"Option A","correct":true},{"id":"b","text":"Option B"}]}`.

For save-only (no AI feedback): `evaluation=\{{}}` or `evaluation=\{{"evaluation_group":"group-id"}}`.

Grading strategy follows the `kind` automatically (mcq → answer-key, essay/free_text → AI). Do NOT add `evaluation.type` unless overriding; never use `"type": "engine"` on a text/essay question. Inputs are text-only by default — add `allowedInputs={["text","image"]}` (or `"voice"`) only to let a text answer also accept an image / voice.

For exams: `lesson_type: exam`, `required: true`, `feedback_trigger: "manual"`.

## Publish Command

```bash
source content/.env.<workspace>
cargo run --bin zippy -- courses push --content-dir content/<workspace> [--course <course-id>]
```

Or with the installed CLI:
```bash
source content/.env.<workspace>
zippy courses push --content-dir content/<workspace>
```

`--course <id>` filters to a single course (useful during development).

## Dry-Run Validate

Before pushing, validate the compiled course payload against the server:

```
POST /admin/publish/validate
Authorization: Bearer <api_key>
x-org-id: <workspace_id>
Content-Type: application/json

<CoursePublishPayload JSON>
```

Returns:
```json
{
  "valid": true,
  "errors": [],
  "warnings": ["No skill maps supplied; skill grouping may be incomplete"],
  "stats": { "course": 1, "units": 25, "lessons": 25, "questions": 500 }
}
```

The `zippy courses push` CLI runs this automatically before committing to the database.
