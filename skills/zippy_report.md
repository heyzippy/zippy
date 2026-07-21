---
name: zippy_report
description: "Build a saveable analytics REPORT (not a one-off chat card). Confirm the plan with the teacher, then open a full-page report seeded with live summary widgets. Use when the teacher says 'build/make/create a report', 'put this in a report', 'weekly report for class X', or wants something they can save and export — as opposed to a quick 'how is X doing?' which is zippy_analyze."
tags:
  - zippy
  - report
  - analytics
---

# Zippy Report Builder

The teacher wants a **report** — a saveable, exportable, full-page analytics
document — not a throwaway chat card. Reports are built in the product (the
report builder surface), never pasted into the chat. Your job is to agree the
plan, then hand off to the builder with `create_report`.

A report is a single JSON: a `title` and an ordered list of **widgets**
(rendered by the reporting framework). Data widgets are **bound** — they carry
a reporting-engine query (`measures` / `dimensions` / `filters`) that resolves
to live data and re-runs on refresh. You can also add static `note` (markdown),
`metric`, `table`, or `chart` widgets.

## Recipe

1. **NEVER ask about scope.** Do NOT call `ask_follow_up`, `get_page_context`,
   or a form to ask "which class". A report always has a **Class filter** (see
   "Filters"); the teacher narrows there and the builder auto-picks the first
   class. Build every report **workspace-scoped** — the filter spec, not the
   widget queries, carries scope.

2. **Confirm the plan with `confirm_report`.** This renders center-stage (NOT
   in chat) and ENDS your turn. Pass `title`, a one-line `summary`, the
   `widgets` you intend (each `{ widget, why }`, e.g. "to-grade metric",
   "submissions-by-activity chart"), and a `scope` line. The teacher approves /
   tweaks / "decide for me"; proceed only AFTER approval.

3. **Build with `create_report`.** Author `widgets` with **workspace-scoped**
   bound queries — just `measures` / `dimensions`, NO class/status filter (the
   report's Class facet scopes them live, see "Filters" below):
   ```json
   {
     "title": "P5 English — Weekly Review",
     "widgets": [
       { "type": "bound", "as": "metric", "label": "To grade",
         "query": { "measures": ["Submissions.to_grade"] } },
       { "type": "bound", "as": "chart", "title": "Submissions by activity", "mark": "bar",
         "query": { "measures": ["Submissions.submitted"], "dimensions": ["Submissions.activity_title"] } }
     ]
   }
   ```
   Keep the default `facets`; pass your own only for a different scope (see
   "Filters"). This opens the full-page report builder (a draft). The teacher
   reviews and saves — don't tell them it's already saved.

4. **Acknowledge with `final`.** One short line, e.g. "Opened your P5 English
   report — tweak it and Save."

## Filters — the report's filter spec (READ THIS before building)

Every report carries a **filter spec**: a `facets` array declaring WHICH filters
the report offers and which are mandatory. It is separate from the data — the
filter bar reads it, and the teacher picks values there. The default spec (used
when you omit `facets`) is:

- **Class** — `required`, `single`, `source: "classes"`. Mandatory; the builder
  auto-picks the first class. This is why you NEVER ask which class.
- **Status** — chips (graded / submitted / in_progress).
- **Draft** — optional.

Consequences for how you build:

- **Build widgets workspace-scoped.** Do NOT bake a `class_id` / `status`
  filter into a widget's `query.filters` — the report's facets apply those live.
  A widget query is just its `measures` / `dimensions` (+ any filter the facets
  DON'T cover). Baking a class filter double-scopes it and breaks the Class
  filter.
- **Keep the default `facets`** unless the report's scope is genuinely different.
  Override only then — e.g. a per-student report:
  `"facets": [{ "key":"student_id", "label":"Student", "required":true, "single":true, "source":"students" }, …]`.
- The header `class_id` / `student_id` does NOT go into widget queries — the
  matching facet handles scope. Just build the widgets.

## Adding to an already-open report

When the teacher asks to add ONE widget to a report that's already open (the
message reads like "Add to my open report …", usually from the builder's
"+ Add widget → Ask Zippy" action), do NOT rebuild the whole report and do NOT
run `confirm_report`. Just call **`add_report_widget`** with a single `widget`
(prefer a `bound` widget carrying the right query) and an optional `index`. This
appends in place, keeping the teacher's existing widgets and layout. Acknowledge
with a one-line `final`.

```json
{ "widget": { "type": "bound", "as": "chart", "title": "Skill mastery", "mark": "bar",
  "query": { "measures": ["Scores.avg_score"], "dimensions": ["Scores.skill"] } } }
```

## Adding a single widget (`intent: build_widget`)

When the message header is `intent: build_widget`, the teacher asked (from the
report's "Add widget" dialog) for ONE widget in natural language, to be added to
the report they're already viewing. This is a DIFFERENT flow from building a
whole report:

- Build exactly ONE widget and call **`add_report_widget`** with it — it appends
  to the open report and renders there.
- **Never ask for scope, and build workspace-scoped.** Just `measures` /
  `dimensions` — do NOT add a `class_id` / `status` filter to the query. The
  report's Class facet already scopes the whole report (and this new widget)
  live. The header `class_id` does NOT go into the query. Just build it.
- Do NOT run `confirm_report`, `create_report`, or `write_todos`. Do NOT plan.
- Do NOT print the widget JSON in the chat — the ONLY way it appears is via the
  `add_report_widget` tool call.
- Use the widget vocabulary below (a `bound` widget with `query.measures` /
  `query.dimensions`). Never invent fields like `metrics` / `group_by` /
  `aggregation`.
- Finish with a one-line `final`, e.g. "Added an average-score table."

```json
{ "widget": { "type": "bound", "as": "chart", "title": "Avg score by student",
  "mark": "bar",
  "query": { "measures": ["Scores.avg_score"], "dimensions": ["Scores.student_id"] } } }
```

## Editing one widget (`intent: edit_widget`)

When the message header is `intent: edit_widget` it also carries a
`widget_index:` and the `current widget:` JSON, plus a `change:` line (from the
report's per-widget Edit dialog). Apply the change and call
**`edit_report_widget`** with that same `index` and the FULL updated widget —
it swaps in place; the rest of the report is untouched.

- Start from the `current widget`, apply the `change` (e.g. "make it a bar
  chart" → `as:"chart"` + `mark:"bar"`; "group by week" → a `timeDimensions`
  granularity; "top 10" → `order` + `limit`).
- Do NOT `add_report_widget` (that would duplicate), rebuild, or plan.
- Do NOT print JSON in chat. Finish with a one-line `final`.

```json
{ "index": 2, "widget": { "type": "bound", "as": "chart", "title": "Submissions by activity",
  "mark": "line", "query": { "measures": ["Submissions.submitted"],
  "timeDimensions": [{ "dimension": "Submissions.created_at", "granularity": "week" }] } } }
```

## Widget vocabulary

- `bound` — a data widget backed by a query: `{ type:"bound", as:"metric"|"table"|"chart", query, title?, w?, label?, format?, mark?, x?, y? }`. **Prefer this for data.**
- `metric` / `table` / `chart` — static (data inline). `note` — markdown.
- Cubes/measures come from the model (e.g. `Submissions.to_grade`,
  `Submissions.submitted`, `Submissions.count`; dimensions `Submissions.status`,
  `Submissions.activity_title`, `Submissions.class_id`). Use the
  `schema_to_cubes` flow to discover/extend them.
- **Time scoping.** To limit a widget to a period, add a time dimension to its
  query: `"timeDimensions": [{ "dimension": "Submissions.created_at",
  "dateRange": "this week" }]`. `dateRange` MUST be either a relative phrase the
  app resolves (`"this week"`, `"this month"`, `"last 30 days"`, `"today"`) or
  an explicit ISO array `["2026-07-13", "2026-07-20"]` — **never** a free-form
  string like `"the last few days"`. Omit it entirely for all-time.

## Rules

- **Never ask which class.** Build every widget workspace-scoped; the report's
  Class facet scopes it. Never bake a `class_id` / `status` filter into a query.
- Keep the default `facets`; override them only for a genuinely different scope.
- Don't render report data as text in the chat. The builder shows it. Your
  `final` is one line.
- `confirm_report` first, `create_report` second. Never call `create_report`
  without an approved plan.
- For a quick "how is X doing?" that doesn't need saving, this is the wrong
  skill — use `zippy_analyze` (the inline card).
