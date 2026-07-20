# Zippy content model & catalog formats

## Directory layout

```
content/<workspace>/
├── courses/                 # reserved: course packs (published with `zippy courses push`)
│   └── <course>/
│       ├── course.yaml
│       ├── units.yaml
│       └── lessons/*.mdx
├── skill_maps.yaml          # standalone library catalogs (published with `zippy library push`)
├── skills.yaml
├── rubrics.yaml
├── evaluations.yaml
├── lesson-*.mdx
└── manifest.yaml            # generated deploy lock: COMMIT THIS
```

`content-dir` for a `library push` defaults to the file's parent (or the `--all` folder).
`courses/` is reserved and excluded from `library push --all`.

## Catalog file shapes

Each standalone catalog is a YAML doc with a `kind` and a `content` array. Real examples
live under `content/<workspace>/` in the platform repo. Fetch the authoritative JSON
schema for any type from the backend: `GET {base_url}/public/schemas/{content_type}`.

### `skill_maps.yaml`
```yaml
kind: skill_maps
content:
  - id: psle-writing
    name: PSLE Writing
    skills: [ narrative-structure, vocabulary, grammar ]   # skill ids in this map
```

### `skills.yaml`
```yaml
kind: skills
content:
  - id: narrative-structure
    name: Narrative structure
    skill_map_id: psle-writing        # parent map (pulled in by dependency closure)
    description: Orientation → complication → resolution
```

### `rubrics.yaml`
```yaml
kind: rubrics
content:
  - id: p5-composition
    name: P5 Composition
    description: MOE-aligned composition rubric
    rubric_type: analytic
    subject: english
    task_type: composition
    definition:
      scale: { min: 0, max: 40 }
      criteria:
        - { name: Content, weight: 0.4 }
        - { name: Language, weight: 0.4 }
        - { name: Organisation, weight: 0.2 }
```
A rubric may reference skills; `zippy rubrics create --definition <json>` also accepts the
`definition` object as standalone JSON.

### `evaluations.yaml`
```yaml
kind: evaluations
content:
  - id: p6-comprehension
    name: P6 Comprehension
    rubrics: [ p5-composition ]        # rubric ids: pulled in by dependency closure
```

### Lessons (`lesson-*.mdx`)
MDX with frontmatter. `push-dir` reads `tags`/`status` from each file's frontmatter.
```mdx
---
id: nouns-intro
title: Nouns
status: published
tags: [ grammar, primary ]
---

Lesson body using the Zippy MDX component catalog.
```
Validate before pushing: `zippy lessons validate --content ./lessons/nouns.mdx`.

## Dependency closure

By default `library push` resolves and pushes dependencies so a single push is complete:

- skill map → its skills
- skill → its parent skill map
- evaluation → the rubrics in its `rubrics:` array

Use `--no-deps` to push only the literal items in the file you named.
