---
name: zippy
description: >-
  Use when authoring or publishing Zippy learning content (courses, lessons,
  rubrics, skill maps, evaluations, and assets) with the zippy CLI, and when
  logging in or managing a Zippy workspace. Triggers on "zippy", "zippy login",
  "zippy library push", "zippy courses push", "push the rubric/skill map to my
  workspace", "publish a lesson", "zippy CLI".
---

# Zippy

Zippy is a content + grading platform for schools, tutoring centres, and teachers.
The `zippy` CLI authors and **publishes** that content (courses, lessons, rubrics,
skill maps, evaluations, and media assets) to a Zippy workspace from local files,
so you can keep content in git and ship it without the browser editor.

- Docs: https://heyzippy.io/docs
- Full LLM reference (curl-able): https://heyzippy.io/llms-full.txt
- Skill file (this file): https://heyzippy.io/docs/skills

Deeper references live next to this file in `references/`, read them when a task
needs the detail:

- `references/cli.md`: every command and flag, credential resolution, env vars.
- `references/content.md`: the content directory model and each catalog's format
  (skill maps, skills, rubrics, evaluations, lessons).
- `references/publishing.md`: the publish workflow: dependency closure, the
  `manifest.yaml` lock, `--prune`, `--dry-run`, and courses vs. standalone library.

## Install the CLI

```bash
curl -fsSL https://heyzippy.io/install.sh | sh
zippy --version
```

The installer also offers to install this coding-agent skill. The skill installer detects your
agent(s) (Claude Code, Cursor, Codex, Windsurf) and links the skill into each. Force it with
`--with-skill` (or `ZIPPY_SKILL=1`), skip with `--no-skill`, or target one agent with
`ZIPPY_AGENT=cursor`.

## Authenticate

```bash
zippy login          # email one-time code → writes ~/.zippy/config (0600)
```

`~/.zippy/config` is TOML: `api_key`, `workspace_id`, `base_url`. For CI / headless,
set env vars instead (they override the config file):

```bash
export ZIPPY_API_URL="https://api.heyzippy.io"   # backend base URL
export ZIPPY_API_KEY="bk_live_…"                 # workspace API key (Bearer)
export ZIPPY_WORKSPACE_ID="<your-workspace-id>"         # workspace slug (sent as x-org-id)
```

`zippy login` fills in your workspace id automatically. If you set it by hand, find your
workspace id in Zippy under **Settings → General**
(https://app.heyzippy.io/teach/settings/general) and use it as `--workspace-id` /
`ZIPPY_WORKSPACE_ID`. Pushes always target **your** workspace, never a shared catalog.

`zippy login` mints an API key with `teacher:*` + `student:*` permissions, so the same key
works for both the admin/teacher and student APIs.

Credentials resolve in this order: **explicit CLI flags → env vars → the active profile in
`~/.zippy/config`**. Every publishing command also accepts `--base-url` / `--token` /
`--workspace-id`.

**Profiles**: keep several logins side by side: `zippy login --profile school-a`, switch with
`zippy profile use <name>`, and target one per command with `--profile <name>` / `ZIPPY_PROFILE`.
`zippy profile list/show/remove` manage them.

**Verbose**: add `--verbose` / `-v` (or `ZIPPY_VERBOSE=1`) to any command to see each API call
and its response status; handy when a push or login fails.

## The content model (30-second version)

Content lives under `content/<workspace>/`:

- **Course packs** go in a reserved `courses/` subtree and publish atomically as a unit.
- **Standalone library catalogs** sit at the workspace-folder level as YAML/MDX files:
  `skill_maps.yaml`, `skills.yaml`, `rubrics.yaml`, `evaluations.yaml`, `lesson-*.mdx`.
- A generated `manifest.yaml` records what was last deployed (per `{api_url, workspace_id}`)
  so `--prune` can delete what you removed. Commit it, it is the deploy lock.

See `references/content.md` for each file's shape.

## Publish content

`zippy library push` is the primary standalone publisher (skill maps, skills, rubrics,
evaluations, lessons). It resolves the **dependency closure** by default (a skill map
pulls its skills; an evaluation pulls its rubrics), so you push one file and its
dependencies go too.

```bash
# One catalog (+ its dependencies), dry-run first
zippy library push content/my-workspace/rubrics.yaml --dry-run
zippy library push content/my-workspace/rubrics.yaml

# Everything under a workspace folder (required for --prune), targeting a workspace
zippy library push --all content/my-workspace --workspace-id <your-workspace-id>
zippy library push --all content/my-workspace --prune -y      # delete removed items too

# Push only the literal items, skip dependency resolution
zippy library push skills.yaml --no-deps
```

Course packs publish atomically with `zippy courses push`:

```bash
zippy courses push --content-dir content/my-workspace/courses --dry-run
zippy courses push --content-dir content/my-workspace/courses --course primary-6
zippy courses push --content-dir content/my-workspace/courses --prune -y
```

Lessons and assets have their own push paths:

```bash
zippy lessons push-dir ./lessons -r          # batch-push every .mdx (reads frontmatter)
zippy lessons push --lesson-id <id> --root ./lessons
zippy assets publish ./assets --dry-run      # upload changed media, write manifest
zippy assets publish ./assets --prune -y
```

Always `--dry-run` first on anything with `--prune`. See `references/publishing.md`.

## Author individual content

```bash
zippy lessons init --title "Nouns" --root ./lessons     # scaffold an MDX lesson
zippy lessons validate --content ./lessons/nouns.mdx    # validate MDX before pushing
zippy rubrics create --name "P5 Composition" --definition rubric.json
zippy courses init --content-dir content/my-workspace --course primary-6
```

## Manage & inspect

```bash
zippy courses list
zippy rubrics list
zippy lessons list
zippy workspaces list           # alias: zippy orgs list
zippy workspaces create
zippy evaluations run --content-dir content/my-workspace --course primary-6 \
  --question-id p6-u05-q20 --answer "student answer text"   # alias: zippy eval run
```

## Command cheat sheet

| Task | Command |
|------|---------|
| Install CLI | `curl -fsSL https://heyzippy.io/install.sh \| sh` |
| Authenticate | `zippy login` |
| Publish a catalog (+deps) | `zippy library push <file>` |
| Publish a whole workspace folder | `zippy library push --all <folder> [--prune -y]` |
| Publish a course pack | `zippy courses push --content-dir <dir> [--course ID]` |
| Batch-push lessons | `zippy lessons push-dir <dir> -r` |
| Publish assets | `zippy assets publish <dir> [--prune]` |
| Preview without sending | add `--dry-run` |
| List things | `zippy {courses,rubrics,lessons,workspaces} list` |
| Run an evaluation | `zippy eval run --content-dir <dir> --question-id ID --answer "…"` |

## Rules of thumb

- **Local authoring needs no login; publishing does.** `zippy login` (or `ZIPPY_*` env)
  before any `push`.
- **`--dry-run` before `--prune`.** Prune soft-deletes (archives) removed content; with
  `--all` it diffs against `manifest.yaml`. `-y`/`--yes` skips the confirmation.
- **`--all` is required to push a whole folder** and to use `--prune`.
- **Dependency closure is on by default**: push a skill map and its skills follow. Use
  `--no-deps` to push only the literal items.
- **Commit `manifest.yaml`.** It is the per-workspace deploy lock; without it `--prune`
  can't tell what to remove.
- **Never put API keys in content files.** Use `zippy login` or `ZIPPY_API_KEY`.
- `courses/` under a workspace folder is reserved for course packs: `library push --all`
  skips it; publish courses with `zippy courses push`.
