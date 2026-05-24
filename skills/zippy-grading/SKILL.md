---
name: zippy-grading
description: Use when the user wants to grade or import student work in Zippy — detected_import.json, batch grading, evaluation runs. Activate when user mentions zippy grade, grading submissions, evaluation run, import student work, or running zippy eval.
---

# Zippy Grading & Evaluations

Prerequisite: if `zippy` is not installed or you need to authenticate, see the `zippy` skill first.

## detected_import.json Schema

When importing student submissions, produce a `detected_import.json` file with this structure:

```json
{
  "title": "Essay Assessment",
  "class_id": "cls-xxx",
  "rubric_id": "rubric-yyy",
  "questions": [
    { "position": 0, "text": "Write about...", "question_type": "essay" }
  ],
  "submissions": [
    {
      "student_name": "Alice Tan",
      "answers": [
        { "question_position": 0, "text": "Full essay text...", "word_count": 342 }
      ]
    }
  ]
}
```

## CLI Workflow

Run a single evaluation:

```bash
zippy evaluations run --content-dir <path> --course <id> --question-id <id> --answer "<text>"
```

For a list of all evaluation subcommands:

```bash
zippy evaluations --help
```

Batch grading via the CLI is not yet supported. For bulk submissions, run individual evaluations via `zippy evaluations run` or contact the Zippy team for API access.

## Rules

- **Preserve full text** — never truncate student essays
- **Capture all students** — count names found vs submissions added; fix gaps before pushing
- **Single activity** — multiple files from the same class → one merged set of submissions
