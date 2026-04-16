---
name = "zippy_grade"
description = "Zippy Grade / Import Skill"
tags = ["zippy", "content", "generation"]
---

# Zippy Grade / Import Skill

Detect student submissions from documents and create a grading activity.

This is the **parent skill** — it delegates document parsing to the appropriate inline coder based on environment:

- **Browser** (Read/Write tools available): Load `grade_browser`
- **Filesystem** (CLI / distri run): Load `grade_local`

## Shared detected_import.json Schema

Both coders produce a `detected_import.json` file with this structure:

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

## Environment Detection

**If you have browser-tools** (`Read`, `Write`, `Edit`, `Glob` that work on IndexedDB files, and `/import/config.json` exists):
- You are in the **browser** — load: `load_skill({"skill_id": "zippy_grade_browser"})`
- Follow `grade_browser` workflow exactly

**If you have `Bash` and file tools** (CLI / distri run):
- You are in **CLI** — load: `load_skill({"skill_id": "zippy_grade_local"})`
- Follow `grade_local` workflow exactly

## Rules

- **Preserve full text** — never truncate student essays
- **Capture all students** — count names found vs submissions added; fix gaps
- **Single activity** — multiple files → one merged set of submissions
