# Zippy CLI: full command reference

Binary: `zippy`. Run `zippy <command> --help` for exact flags on any command.

## Credentials

Every command that hits the backend resolves credentials in this order:

1. **Explicit flags**: `--base-url`, `--token`, `--workspace-id`
2. **Environment variables**:
   - `ZIPPY_API_URL`: backend base URL (default `http://localhost:8086` in dev)
   - `ZIPPY_API_KEY`: workspace API key, sent as `Authorization: Bearer <key>`
   - `ZIPPY_WORKSPACE_ID`: workspace slug, sent as the `x-org-id` header
3. **`~/.zippy/config`** (TOML, mode `0600`): the **active profile**'s `api_key`,
   `workspace_id`, `base_url`. Written by `zippy login`. Pick a different saved login with
   `--profile <name>` / `ZIPPY_PROFILE`.

A `.env` in the working directory is auto-loaded at startup.

## `zippy login`

Authenticate by email one-time code. Prompts for your email, the backend emails a 6-digit
code, and on success it mints an API key with permissions `teacher:*` + `student:*` (works
for both the admin/teacher and student APIs), selects your workspace, and saves everything to
a profile in `~/.zippy/config`.

- `--email <EMAIL>` (prompted if omitted)
- `--workspace-id <SLUG>` (prompted/selected if you belong to more than one)
- `--base-url <URL>` (env `ZIPPY_API_URL`, default `https://api.heyzippy.io`)
- `--profile <NAME>`: save into this profile and make it active (default: the active profile)

## `zippy profile …`: named logins

Keep several logins side by side and switch between them.

- `list`: show profiles (the active one is marked `*`)
- `use <NAME>`: set the active (default) profile
- `show [NAME]`: print a profile (redacted key); defaults to the active/`--profile` one
- `remove <NAME>`: delete a profile

Select a profile per command with the global `--profile <NAME>` flag or `ZIPPY_PROFILE`.

## `zippy library push` (alias `zippy lib push`): standalone publisher

Publishes standalone catalogs (skill maps, skills, rubrics, evaluations, lessons) to
`POST /admin/publish/standalone`.

- `[FILE]`: a single catalog: `skill_maps.yaml`, `skills.yaml`, `rubrics.yaml`,
  `evaluations.yaml`, or a `lesson-*.mdx`. Mutually exclusive with `--all`.
- `--all <FOLDER>`: push every catalog under a folder (recursive; excludes reserved
  `courses/`). Required for `--prune`.
- `--content-dir <DIR>`: where to resolve related items and where `manifest.yaml` lives
  (defaults to FILE's parent, or the `--all` folder).
- `--no-deps`: push only literal items; skip dependency-closure resolution.
- `--prune`: delete library content removed since last push (requires `--all`).
- `-y` / `--yes`: skip the prune confirmation.
- `--dry-run`: resolve and print the payload; send nothing.
- `--base-url` / `--token` / `--workspace-id`.

## `zippy courses …`

- `push`: publish a course pack atomically to `/admin/publish`:
  - `--content-dir <DIR>` (default `content/courses`)
  - `--course <ID>`: filter to one course
  - `--dry-run [FILE]`: validate/print; optional FILE dumps per-course JSON
  - `--prune` / `-y` / `--hard-delete-with-submissions`
  - `--base-url` / `--token` / `--workspace-id`
- `init`: scaffold a course folder: `--content-dir`, `--course <name>`,
  `--template <default|json-path|server-id>`, `--from-json <file>`, `--from-course <id>`,
  `--mode <draft|deployed>`, `--version`, `--course-name`.
- `list`: list courses in the workspace.
- `delete --id <COURSE_ID>`.

## `zippy lessons …`

- `create --title <T> --content <MDX-file> [--format text|json]`
- `update --lesson-id <ID> --content <MDX-file> [--title <T>]`
- `validate --content <MDX-file> [--remote]`
- `list`
- `init [--lesson-id <ID>] [--title "New Lesson"] [--root ./lessons] [--force]`
- `save [--lesson-id <ID>] [--root ./lessons]`: refresh `updated_at` frontmatter
- `push [--lesson-id <ID>] [--root ./lessons] [--force] [--format]`: create-or-update
- `push-dir <DIR> [-r|--recursive] [--format]`: batch-push every `.mdx`, reading
  tags/status from each file's frontmatter

## `zippy rubrics …`

- `create --name <N> --definition <JSON-file> [--description <D>] [--format]`
- `update --rubric-id <ID> --definition <JSON-file> [--format]`
- `list`

## `zippy assets …` (alias `zippy files …`)

- `upload <PATHS…> [--folder images/icons]`: files or dirs (walked recursively)
- `list [DIR=.] [--remote]`: local-vs-manifest sync status
- `publish [DIR=.] [--prune] [--yes] [--dry-run]`: upload changes, write manifest

## `zippy workspaces …` (alias `zippy orgs …`)

- `create` · `list`

## `zippy evaluations run` (alias `zippy eval run`)

- `--content-dir <DIR>`, `--course <ID>`, `--question-id <ID>`,
  `--answer <TEXT>` / `--answer-file <FILE>`, `--question <TEXT>`, `--dry-run`, `--all`

## `zippy skills`

- `--content-dir <DIR>`: read-only local inspection of skills in content files.

## Global conventions

- `--dry-run` never mutates the backend: use it to preview any push.
- `--format json` (where available) prints machine-readable output.
- `--profile <name>` / `ZIPPY_PROFILE` selects which saved login to use.
- `--verbose` / `-v` (or `ZIPPY_VERBOSE`) prints each API call and its response status.
- Exit non-zero on validation or auth failure; the message names what to fix.
