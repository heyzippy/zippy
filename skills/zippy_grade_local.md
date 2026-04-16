---
name = "zippy_grade_local"
description = "Inline Coder — Local (CLI / distri run)"
tags = ["zippy", "content", "generation"]
---

# Inline Coder — Local (CLI / distri run)

Import student submissions from Google Drive documents into a grading activity.

## ALLOWED ENDPOINTS

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/admin/google-drive/files/{file_id}/content` | Fetch document text |
| GET | `/admin/rubrics` | List available rubrics |
| POST | `/admin/content/generate` | Generate lesson with Question components |
| POST | `/admin/activities` | Create activity |
| POST | `/admin/activities/{activity_id}/bulk-submissions` | Add student submissions |

**These are the ONLY valid paths. Any other path returns 404.**

## Auth pattern

```bash
curl -sS [-X POST] "$ZIPPY_API_URL/<path>" \
  -H "Authorization: Bearer $ZIPPY_AUTH_TOKEN" \
  -H "x-org-id: $ZIPPY_ORG_ID" \
  -H "Content-Type: application/json" \
  -d @/tmp/payload.json
```

---

## Step 1 — Fetch document

```bash
curl -sS "$ZIPPY_API_URL/admin/google-drive/files/FILE_ID/content" \
  -H "Authorization: Bearer $ZIPPY_AUTH_TOKEN" -H "x-org-id: $ZIPPY_ORG_ID" \
  | tee /tmp/gdoc_response.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['data']['content'][:200])"
```

---

## Step 2 — Extract submissions from the fetched content

**CRITICAL: Use ONLY text from the Step 1 API response. Do NOT invent names or essay text.**

Read the `content` field. Identify:
1. The essay prompt/question (infer from the shared theme if not explicit)
2. Student names and their FULL essay text — copy verbatim, do NOT truncate

Write to `/tmp/detected_import.json`:
```json
{
  "title": "DESCRIPTIVE_TITLE",
  "question": "EXACT_OR_INFERRED_QUESTION",
  "submissions": [
    {"student_name": "EXACT_NAME", "text": "EXACT_FULL_ESSAY"}
  ]
}
```

Then verify names match the document:
```bash
python3 -c "
import json
with open('/tmp/gdoc_response.json') as f: doc = json.load(f)['data']['content']
with open('/tmp/detected_import.json') as f: det = json.load(f)
for s in det['submissions']:
    name = s['student_name']
    assert name in doc, f'HALLUCINATION: {name} not in document!'
    print(f'  OK: {name} ({len(s[\"text\"].split())} words)')
print(f'Total: {len(det[\"submissions\"])} submissions')
"
```

**If verification fails, you hallucinated. Re-extract from the actual document.**

---

## Step 3 — Find a rubric

List available rubrics:
```bash
curl -sS "$ZIPPY_API_URL/admin/rubrics" \
  -H "Authorization: Bearer $ZIPPY_AUTH_TOKEN" -H "x-org-id: $ZIPPY_ORG_ID" \
  | python3 -c "
import json, sys
for r in json.load(sys.stdin).get('data', []):
    print(f'{r[\"id\"]} — {r[\"name\"]} ({r.get(\"criteria_count\",\"?\")} criteria)')
"
```

Pick the most appropriate rubric for the essay type. Save RUBRIC_ID.

---

## Step 4 — Run the import script

This script generates the lesson (with proper `<Question id="q0" kind="essay" stem="..." />` component), creates the activity, and bulk-submits all essays.

```bash
python3 testing/import-from-detected.py CLASS_ID RUBRIC_ID
```

Replace CLASS_ID and RUBRIC_ID with the actual values.

The script reads `/tmp/detected_import.json` and creates everything via the API.

---

## Step 5 — Report

Print the output from Step 4: Activity ID, Lesson ID, Rubric, submission count.
