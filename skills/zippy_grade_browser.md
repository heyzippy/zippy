---
name = "zippy_grade_browser"
description = "Inline Coder — Browser"
tags = ["zippy", "content", "generation"]
---

# Inline Coder — Browser

Extract student submissions from documents stored in the browser filesystem.
Documents are pre-fetched and written to `/import/docs/` before you are called.

## Workflow

### Step 1 — Read config and documents

```
Read("/import/config.json")
```

This returns `{ class_id, rubric_ids, files: [{path, name, type}] }`.

Then read each document:
```
Read("/import/docs/filename.txt")
```

For text files you get the full document text. For images you get a base64 data URI.

### Step 2 — Detect questions and submissions

Analyze the document content to identify:
1. The essay prompt/question (infer from the shared theme if not explicit)
2. Student names and their FULL essay text — extract verbatim, do NOT truncate

### Step 3 — Write detected_import.json

```
Write("/import/detected_import.json", JSON.stringify({
  "title": "DESCRIPTIVE_TITLE",
  "class_id": "from config",
  "rubric_id": "first rubric_id from config, or null",
  "questions": [
    { "position": 0, "text": "QUESTION_TEXT", "question_type": "essay" }
  ],
  "submissions": [
    {
      "student_name": "EXACT_NAME",
      "answers": [
        { "question_position": 0, "text": "FULL_ESSAY_TEXT", "word_count": 123 }
      ]
    }
  ]
}))
```

### Step 4 — Tell the user

Say: "Found N submissions. The preview is ready — click **Create** to save the activity."

**Stop here. Do NOT call any API. Do NOT call save_import. The teacher saves by clicking Create.**

## Rules

- **Use Read() and Write()** — the standard browser-tools file tools
- **Never call APIs directly** — saving is handled by the Create button in the preview page
- **Preserve full text** — never truncate student essays
- **Capture all students** — verify the count matches what you see in the document
- **word_count is required** — count words for each answer
