---
name: zippy_students
description: "Two-mode student skill. (1) `mode=invite` — one-shot bulk import, builds an invites array from prompt/uploads and POSTs to /admin/students/invite. (2) `mode=match` — load activity's draft submissions + class roster, fuzzy-match detected names to existing student_ids, PATCH each matched submission. Used standalone for roster import or dispatched by `zippy_grade` after submission detection completes."
tags:
  - zippy
  - students
  - import
  - match
---

# Zippy Students

Two modes — branch on the `mode:` field in your prompt header.

## Required inputs

```
mode: invite | match    # required

# invite mode
class_id: <uuid>        # required for invite
imports:                # optional — text/image rows to parse names+emails out of
- <import_id_or_path>

# match mode
class_id:    <uuid>     # required for match
activity_id: <uuid>     # required for match
```

Branch on `mode`. If `mode` is missing or unknown:

```
final({ result: "need: mode=invite or mode=match in the prompt header" })
```

═══════════════════════════════════════════════════════════════════
## Mode A — `invite`: bulk roster import
═══════════════════════════════════════════════════════════════════

ONE call to `/admin/students/invite`. Creates new student rows + class
membership in one transaction.

### Step 1 — extract the roster

Pull `(name, email)` pairs from:
- The teacher's prompt (paste-list of names/emails).
- Any `imports` rows — text rows have `content`; image rows OCR via
  `db_get` (browser) or `Read` (cli/cloud).

Allow rows with just a name (email becomes empty / null). Deduplicate
by lowercased email when present, otherwise by trimmed lowercased name.

### Step 2 — invite

```
zippy_request({
  method: "POST", path: "/admin/students/invite",
  body: {
    invites: [
      { name: "<name>", email: "<email or null>" },
      …
    ],
    class_ids: ["<class_id>"]
  }
})
```

### Step 4 — final

```
final({ result: "invite: <C> created, <E> already existed, <X> errors" })
```

═══════════════════════════════════════════════════════════════════
## Mode B — `match`: roster-match draft submissions
═══════════════════════════════════════════════════════════════════

Match the detected names on `is_draft=true, student_id=null`
submissions against the class roster, and PATCH each match to set
the right `student_id`. Unmatched rows stay null — the teacher
assigns or invites them in the UI.

### Step 1 — fetch the roster + draft submissions

```
zippy_request({ method: "GET", path: "/admin/classes/<class_id>/members" })
// → list of { id, student_id, name, email, role: "student" | "teacher" }

zippy_request({ method: "GET", path: "/admin/activities/<activity_id>/submissions" })
// → page of { items: [...] } (auto-unwrapped by some clients; otherwise read .data.items)
// Filter to is_draft=true AND student_id=null.
```

### Step 2 — classify each unmatched row

For each unmatched submission, classify against the roster:

- **confident** — case-insensitive equality after trim+collapse OR
  exact first+last in any order. Single roster member match.
- **fuzzy** — single unambiguous first-name match across the roster,
  OR Levenshtein ≤ 2 against a roster name of comparable length.
- **unmatched** — anything else (no candidate, multiple candidates,
  generic placeholders like "Unnamed Student").

### Step 3 — PATCH the confident matches

For each `confident` row:

```
zippy_request({
  method: "PATCH",
  path: "/admin/activities/<activity_id>/submissions/<submission_id>",
  body: { student_id: "<roster_member.student_id>" }
})
```

**Don't auto-PATCH fuzzy matches** — surface them in the final result
so the teacher decides.

### Step 4 — final

```
final({
  result: "match: <C> confident matches applied, <F> fuzzy matches need review (<list of name -> roster_name>), <U> still unmatched. Review the activity submissions page."
})
```

═══════════════════════════════════════════════════════════════════

## Hard rules

- **One mode per invocation.** Don't try to invite and match in the
  same run; the orchestrator (`zippy_grade`) calls match-mode after
  attachment, and the composer's `intent: students` flow uses
  invite-mode standalone.
- **Match-mode never creates students.** It only links existing roster
  members to existing draft submissions. If a detected name doesn't
  match any roster member, leave it unmatched. The teacher can invite
  + re-match from the review page.
- **PATCH only confident matches.** Fuzzy matches surface in the final
  result for the teacher to confirm; never auto-link.
- **No publish, no release.** Match-mode never flips `is_draft`. That's
  the teacher's "Auto-grade" click in the UI.
