---
name: zippy
description: Use when the user wants to author or publish Zippy learning content — courses, lessons, rubrics, evaluations, assets — via the zippy CLI. Activate when user mentions zippy, publishing course content, MOE-aligned writing, or content authoring for an educational platform.
---

# Zippy CLI

## Prerequisite — Install the CLI

If `zippy --version` errors, install it:

```bash
curl -fsSL https://heyzippy.io/install.sh | sh
zippy --version
```

## Authenticate

```bash
zippy login
```

Opens a browser window, completes OAuth, and writes credentials to `~/.zippy/config`.

For CI or headless environments, set these env vars instead:

```bash
export ZIPPY_PUBLISH_KEY=<your-publish-key>
export ZIPPY_WORKSPACE_ID=<your-workspace-id>
```

## Subcommand Map

| Command | Purpose |
|---------|---------|
| `zippy login` | Authenticate and store credentials |
| `zippy courses` | Manage course packs (push, list, delete) |
| `zippy workspaces` | Inspect workspace configuration |
| `zippy evaluations` | Run and manage evaluation jobs |
| `zippy skills` | Manage skill maps |
| `zippy lessons` | Manage individual lesson files |
| `zippy rubrics` | Create and update rubrics |
| `zippy assets` | Upload and manage media assets |

## Choose a Sub-Skill

- Working on courses, units, workspace structure → see the `zippy-courses` skill
- Writing or editing lesson MDX content → see the `zippy-lessons` skill
- Authoring rubrics → see the `zippy-rubrics` skill
- Grading submissions or running evaluations → see the `zippy-grading` skill

## Typical Authoring Workflow

1. Initialize a course folder with `zippy courses init` and fill in `course.yaml`, `units.yaml`, and lesson files.
2. Draft lessons in MDX format (see `zippy-lessons` skill) and rubrics in JSON (see `zippy-rubrics` skill).
3. Validate locally: `zippy courses push --dry-run --content-dir <path>` (the push command validates before committing).
4. Push to the backend: `zippy courses push --content-dir <path>`.
5. Share the course link returned by the CLI with the user.
