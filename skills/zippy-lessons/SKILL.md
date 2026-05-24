---
name: zippy-lessons
description: Use when the user wants to author a Zippy lesson in MDX — Callout, Sticky, Question (mcq/free_text/essay/DragDrop/FillBlank), evaluation. Activate when user mentions zippy lesson, writing a lesson, MDX components, or interactive questions for an educational platform.
---

# Zippy Lesson Format

Prerequisite: if `zippy` is not installed or you need to authenticate, see the `zippy` skill first.

## Workflow

1. Plan with `write_todos` — outline lesson sections (intro, content blocks, questions, celebration).
2. Scaffold a local file: `zippy lessons init <id>` (see `zippy lessons init --help`), or write the MDX manually with the Write tool using the format below.
3. Edit content with the Edit or Write tool.
4. Validate: `zippy lessons validate <id>` (see `zippy lessons validate --help`). If errors, fix with Edit and re-validate.
5. Push to the backend: `zippy lessons push <id>`.
6. Share the returned link with the user.

## MDX Format

Lessons use MDX (Markdown + JSX) with YAML frontmatter:

```mdx
---
title: "Lesson Title"
presentationType: interactive
lesson_type: learning
duration_minutes: 25
status: draft
skills: []
---

# Lesson Title

Content goes here with components below.
```

## Components

### Callout — instructional blocks
```jsx
<Callout style="instruction">Read the passage carefully.</Callout>
<Callout style="tip">Remember to use descriptive language.</Callout>
<Callout style="warning">You have 10 minutes remaining.</Callout>
<Callout style="completion">Well done! You've completed this section.</Callout>
<Callout style="excerpt">Once upon a time, in a land far away...</Callout>
<Callout style="example">Here is an example of good paragraph structure.</Callout>
```
Styles: `instruction`, `tip`, `warning`, `completion`, `excerpt`, `example`

### Sticky — persistent reference content
```jsx
<Sticky>
### Key Terms
- **Metaphor** — comparing two things without using "like" or "as"
- **Simile** — comparing two things using "like" or "as"
</Sticky>
```
Stays visible as a floating reference when the student scrolls past it.

### PageBreak — page separator
```jsx
<PageBreak />
```
Separates content into pages. In `slides` mode, each page becomes a slide.

### Celebration — end-of-lesson animation
```jsx
<Celebration tier="sparkle" trigger="auto" />
```
Tiers: `sparkle`, `confetti`. Always place at the very end of the lesson.

## Question Types

> **All question types use the `<Question>` tag** — never `<FreeText>`, `<MultipleChoice>`, or `<FillInTheBlank>`. Use `<FillBlank>` (not `<FillInTheBlank>`) for fill-in-the-blank.

### MCQ — Multiple choice
```jsx
<Question id="q-1" kind="mcq" stem="Which sentence uses a simile?" options={[{"id":"a","text":"The sun was a golden coin."},{"id":"b","text":"The wind howled like a wolf.","correct":true},{"id":"c","text":"The river danced over the rocks."}]} />
```
- MUST include `options` array with at least 2 items
- Each option: `{"id": "a", "text": "...", "correct": true/false}`
- Exactly one option should have `"correct": true`

### Free Text — short answer
```jsx
<Question id="q-2" kind="free_text" stem="What is the main idea of paragraph 2?" placeholder="Write 1-2 sentences" />
```

### Essay — long-form writing
```jsx
<Question id="q-3" kind="essay" stem="Write a narrative about a time you faced a difficult decision." placeholder="Write 4-6 paragraphs" rows={15} />
```

### DragDrop — interactive sorting/matching
```jsx
<DragDrop id="dd-1" mode="sort" stem="Arrange these events in chronological order." items={["The letter arrived.","She opened it nervously.","She smiled with relief."]} />
```

### FillBlank — fill-in-the-blank
```jsx
<FillBlank id="fb-1" stem="Complete the sentence." template="The boy {{0}} quickly to school because he was {{1}}." blanks={[{"answer":"ran","options":["ran","walked","skipped"]},{"answer":"late","placeholder":"feeling word"}]} />
```

## Evaluation

### Inline feedback (most common)
```jsx
<Question id="q-1" kind="free_text" stem="Why did the character feel sad?"
  evaluation={{"prompt":"Check if the student identifies the character's emotional state."}} />
```

### Rubric-based
```jsx
<Question id="q-2" kind="essay" stem="Write a narrative composition."
  skill_ids={["ID5","WC3","VO5"]}
  evaluation={{"id":"eval-p56-narrative","evaluation_group":"draft-1"}} />
```

## CRITICAL: JSX Syntax

String values use double quotes: `stem="What?"`, `kind="mcq"`

Arrays and objects use curly braces `={...}`:
```
correct:  options={[{"id":"a","text":"Yes","correct":true}]}
wrong:    options='[{"id":"a","text":"Yes"}]'   <- WILL FAIL VALIDATION
```

## Lesson Structure Guidelines

- Start with a `<Callout style="instruction">` explaining what students will do
- Use `<Sticky>` for reference material (key terms, excerpts, examples)
- Use `<PageBreak />` between sections
- 3-5 questions per lesson, mix of types
- End with `<Callout style="completion">` and `<Celebration />`
- Unique question IDs: `q-{topic}-{n}` pattern
