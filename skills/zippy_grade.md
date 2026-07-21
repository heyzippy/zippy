---
name: zippy_grade
description: "Grading orchestrator. The teacher has already delimited which scans belong to which student in the builder, so the local `submissions` IDB rows carry their own images. Calls the `bulk_upload` tool once: it reads the draft lesson from `content_items` IDB, parses the question ids, and runs one OCR + answer-extraction call per delimited submission, writing results back into the `submissions` rows. `process_submission` re-runs one row on demand. The agent just relays the returned summary. No server calls — the teacher's Save button commits everything via `POST /admin/bulk-submissions` in one round-trip."
tags:
  - zippy
  - grade
---

# Zippy Grade

Runtime-aware recipe — the body branches on `runtime_mode`.

{{#if (eq runtime_mode "browser")}}
{{> zippy_grade_browser}}
{{else}}
{{> zippy_grade_default}}
{{/if}}
