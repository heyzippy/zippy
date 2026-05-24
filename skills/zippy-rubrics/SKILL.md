---
name: zippy-rubrics
description: Use when the user wants to author a Zippy rubric — descriptor/range/score ratings, MOE SEAB-aligned scoring, criteria with levels. Activate when user mentions zippy rubric, scoring rubric, MOE composition scoring, descriptor rubric, or assessment criteria.
---

# Zippy Rubric Format

Prerequisite: if `zippy` is not installed or you need to authenticate, see the `zippy` skill first.

## Workflow

1. Plan with `write_todos` — decide on criteria, levels, and rating type.
2. Write the rubric JSON to a local file using the Write tool.
3. Create or update via CLI:
   ```bash
   zippy rubrics create --file <path>
   zippy rubrics update <id> --file <path>
   ```
4. Verify: `zippy rubrics list`.

## JSON Structure

**Every rubric MUST have** `content_type`, `name`, `scale.levels` (array of objects), `criteria` (array).
Each criterion MUST have `id`, `label`, `ratings` (array with SAME length as `scale.levels`).

**CRITICAL — scale.levels format:**
```json
correct:  "levels": [{"label": "Beginning"}, {"label": "Developing"}]
wrong:    "levels": ["Beginning", "Developing"]  <- WILL FAIL — must be objects with "label" key
```

## Rating Types

Choose ONE type per criterion:

| Type | Fields | Best for |
|------|--------|----------|
| `descriptor` | `type`, `description` | Formative feedback, skills assessment |
| `range` | `type`, `description`, `points_range: [min, max]` | MOE composition scoring, summative |
| `score` | `type`, `description`, `points: N` | Maths/science, discrete marking |

## Example 1: Descriptor Rubric (Narrative Writing)

```json
{
  "content_type": "rubric",
  "name": "P5-P6 Narrative Writing",
  "description": "MOE-aligned rubric for narrative composition",
  "subject": "english",
  "task_type": "narrative_writing",
  "scale": {
    "levels": [
      { "label": "Beginning" },
      { "label": "Developing" },
      { "label": "Proficient" },
      { "label": "Excellent" }
    ]
  },
  "criteria": [
    {
      "id": "content",
      "label": "Content & Ideas",
      "description": "Quality and development of ideas",
      "ratings": [
        { "type": "descriptor", "description": "Ideas are unclear or undeveloped. Story lacks focus." },
        { "type": "descriptor", "description": "Some relevant ideas with limited development. Basic plot present." },
        { "type": "descriptor", "description": "Clear, well-developed ideas. Engaging plot with relevant details." },
        { "type": "descriptor", "description": "Rich, compelling ideas with strong development. Vivid, original storytelling." }
      ]
    },
    {
      "id": "organisation",
      "label": "Organisation",
      "description": "Structure, sequencing, and coherence",
      "ratings": [
        { "type": "descriptor", "description": "No clear structure. Events are disorganised." },
        { "type": "descriptor", "description": "Basic structure. Some lapses in sequencing." },
        { "type": "descriptor", "description": "Clear structure with effective transitions." },
        { "type": "descriptor", "description": "Sophisticated structure that enhances meaning." }
      ]
    },
    {
      "id": "language",
      "label": "Language Use",
      "description": "Vocabulary, grammar, and expression",
      "ratings": [
        { "type": "descriptor", "description": "Limited vocabulary. Frequent errors." },
        { "type": "descriptor", "description": "Simple vocabulary. Some errors but meaning is clear." },
        { "type": "descriptor", "description": "Varied vocabulary. Mostly accurate grammar." },
        { "type": "descriptor", "description": "Precise, expressive vocabulary. Fluent and accurate." }
      ]
    }
  ]
}
```

## Example 2: Range Rubric (MOE Composition Scoring)

```json
{
  "content_type": "rubric",
  "name": "P5-P6 Continuous Writing (SEAB)",
  "description": "MOE SEAB-aligned scoring for P5-P6 continuous writing",
  "subject": "english",
  "task_type": "composition",
  "scale": {
    "levels": [
      { "label": "No Credit" },
      { "label": "Limited" },
      { "label": "Basic" },
      { "label": "Competent" },
      { "label": "Strong" },
      { "label": "Excellent" }
    ]
  },
  "criteria": [
    {
      "id": "content",
      "label": "Content",
      "description": "Relevance, interest, and development of ideas",
      "ratings": [
        { "type": "range", "description": "No meaningful response.", "points_range": [0, 0] },
        { "type": "range", "description": "A slight attempt to address the topic.", "points_range": [1, 4] },
        { "type": "range", "description": "Addresses the topic with some development.", "points_range": [5, 8] },
        { "type": "range", "description": "Well-developed with relevant details.", "points_range": [9, 12] },
        { "type": "range", "description": "Compelling and engaging throughout.", "points_range": [13, 16] },
        { "type": "range", "description": "Outstanding — vivid, original, deeply engaging.", "points_range": [17, 20] }
      ]
    },
    {
      "id": "language",
      "label": "Language & Organisation",
      "description": "Grammar, vocabulary, sequencing, paragraphing",
      "ratings": [
        { "type": "range", "description": "No meaningful language use.", "points_range": [0, 0] },
        { "type": "range", "description": "Severe errors impede communication.", "points_range": [1, 4] },
        { "type": "range", "description": "Frequent errors but meaning generally clear.", "points_range": [5, 8] },
        { "type": "range", "description": "Mostly accurate with some variety.", "points_range": [9, 12] },
        { "type": "range", "description": "Varied and effective language use.", "points_range": [13, 16] },
        { "type": "range", "description": "Sophisticated, fluent, and precise throughout.", "points_range": [17, 20] }
      ]
    }
  ]
}
```

## Example 3: Score Rubric (Maths Problem Solving)

```json
{
  "content_type": "rubric",
  "name": "P5 Maths Problem Solving",
  "description": "Fixed-point scoring for maths problem solving",
  "subject": "math",
  "task_type": "problem_solving",
  "scale": {
    "levels": [
      { "label": "No attempt" },
      { "label": "Partial" },
      { "label": "Mostly correct" },
      { "label": "Fully correct" }
    ]
  },
  "criteria": [
    {
      "id": "understanding",
      "label": "Understanding",
      "description": "Interprets the problem correctly",
      "ratings": [
        { "type": "score", "description": "No evidence of understanding.", "points": 0 },
        { "type": "score", "description": "Partial understanding, some relevant information identified.", "points": 1 },
        { "type": "score", "description": "Good understanding, minor gaps.", "points": 2 },
        { "type": "score", "description": "Complete and accurate understanding.", "points": 3 }
      ]
    },
    {
      "id": "method",
      "label": "Method & Working",
      "description": "Correctness and clarity of mathematical method",
      "ratings": [
        { "type": "score", "description": "No valid method shown.", "points": 0 },
        { "type": "score", "description": "Some relevant working, but incomplete or incorrect.", "points": 1 },
        { "type": "score", "description": "Mostly correct method with minor errors.", "points": 2 },
        { "type": "score", "description": "Correct and clearly presented method.", "points": 3 }
      ]
    },
    {
      "id": "communication",
      "label": "Communication",
      "description": "Clarity of working and explanation",
      "ratings": [
        { "type": "score", "description": "No working shown.", "points": 0 },
        { "type": "score", "description": "Some working shown but unclear.", "points": 1 },
        { "type": "score", "description": "Clear working with minor omissions.", "points": 2 },
        { "type": "score", "description": "Complete, clear, and well-organised working.", "points": 3 }
      ]
    }
  ]
}
```

## Guidelines

- 3-6 criteria per rubric
- 3-6 levels is typical (4 for descriptor, 5-6 for range)
- Ratings MUST progress from low to high
- Number of ratings per criterion MUST equal number of scale levels
- For Singapore MOE content, align to SEAB marking standards
- Include `subject` and `task_type` for curriculum alignment
- Use `range` for summative scoring, `descriptor` for formative feedback, `score` for discrete marking
- Optional fields: `description`, `subject`, `task_type`, `notes`
