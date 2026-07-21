---
name: zippy_match_students
description: "One-step skill: match every `is_draft=true, student_id=null` submission on an activity against the class roster. Auto-PATCHes confident matches and returns the fuzzy + unmatched lists for the teacher to confirm in the review UI. Replaces the post-attach matching that `zippy_grade` used to do inline."
tags:
  - zippy
  - grade
---

# Zippy Match Students — link drafts to the roster

You match draft submissions (the kind `zippy_grade` attaches as
`"Unnamed Student"` or with a free-form detected name) to the
actual roster of the activity's class. Confident matches get
PATCHed straight to `student_id` on the submission; fuzzy /
unmatched rows come back as lists for the teacher to review in
the activity submissions page.

This is a **single tool call**. You do NOT loop, do NOT ask the
teacher follow-up questions, do NOT mutate anything else. One
call, one summary, done.

## Required inputs (from the prompt header)

```
class_id:    <uuid>     # REQUIRED — roster source
activity_id: <uuid>     # REQUIRED — the activity whose drafts get matched
```

If either is missing, stop immediately:

```
final({ result: "need: both class_id and activity_id are required to match students" })
```

## Step 1 — one call

```
match_students_to_drafts({
  activity_id: "<from header>",
  class_id:    "<from header>"
})
```

The tool:

1. Loads the class roster + every `is_draft=true, student_id=null`
   submission on the activity.
2. Classifies each detected name against the roster (`confident` /
   `fuzzy` / `unmatched`).
3. PATCHes confident matches (`editSubmission(activity_id, sub_id,
   { student_id })`) automatically.
4. Returns `{ total, confident, fuzzy, unmatched, results[] }`.

Fuzzy + unmatched are surfaced to the teacher — she fixes them in
the activity submissions page (inline name edit). You do NOT call
`edit_submission` here yourself.

## Step 2 — final

```
final({
  result: "ok: matched <confident> of <total> draft(s). <fuzzy> need teacher confirmation; <unmatched> have no roster candidate. Review and fix names in the activity submissions page."
})
```

If `total === 0`, say so explicitly:

```
final({ result: "no drafts to match — every submission already has a student_id" })
```

## Hard rules

- **One tool call.** Never iterate per-row in your own loop —
  `match_students_to_drafts` already does the batch internally.
- **No `attach_submission`.** That's `zippy_grade`'s job. This skill
  only fixes student linkage on existing drafts.
- **No follow-up questions.** The teacher already chose to run this
  skill; don't second-guess with `ask_follow_up`.
- **Don't `confirm` drafts.** Confirming a draft (`is_draft=true →
  false`) is a separate teacher click in the UI; this skill only
  populates `student_id`.
