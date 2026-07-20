# Zippy CLI reference

Complete command and flag reference for the `zippy` CLI. For a quick start see the
[README](./README.md); for guides and the coding-agent skill see
[heyzippy.io/docs](https://heyzippy.io/docs). Download binaries from
[Releases](https://github.com/heyzippy/zippy/releases).

Run `zippy <command> --help` (or `zippy <command> <subcommand> --help`) for the authoritative
flags on any command at your installed version.

## Contents

- [Global concepts](#global-concepts)
- [`zippy login`](#zippy-login)
- [`zippy library push`](#zippy-library-push)
- [`zippy courses`](#zippy-courses)
- [`zippy lessons`](#zippy-lessons)
- [`zippy rubrics`](#zippy-rubrics)
- [`zippy assets`](#zippy-assets)
- [`zippy workspaces`](#zippy-workspaces)
- [`zippy evaluations`](#zippy-evaluations)
- [`zippy skills`](#zippy-skills)

## Global concepts

**Credentials** resolve in this order on every command that reaches the backend:

1. Explicit flags: `--base-url`, `--token`, `--workspace-id`
2. Environment variables:
   - `ZIPPY_API_URL` backend base URL
   - `ZIPPY_API_KEY` workspace API key, sent as `Authorization: Bearer <key>`
   - `ZIPPY_WORKSPACE_ID` workspace slug, sent as the `x-org-id` header
3. `~/.zippy/config` (TOML, mode `0600`): `api_key`, `workspace_id` (alias `org_id`), `base_url`, written by `zippy login`

A `.env` in the working directory is auto-loaded at startup. Find your workspace id in Zippy
under **Settings → General** ([app.heyzippy.io/teach/settings/general](https://app.heyzippy.io/teach/settings/general)).

**Conventions**: `--dry-run` never mutates the backend. `--prune` deletes content removed since
the last push (soft-delete/archive by default) and requires `--all` for `library push`.
`--format json` prints machine-readable output where supported. Commands exit non-zero on
validation or auth failure with a message naming what to fix.

## `zippy login`

Browser OAuth loopback. Fetches a login URL, opens the browser, runs a local callback server
(ports 7878-7900), and writes `~/.zippy/config`.

- `--base-url <URL>` (env `ZIPPY_API_URL`)

## `zippy library push`

Alias: `zippy lib push`. The standalone publisher for skill maps, skills, rubrics, evaluations,
and lessons. Resolves the dependency closure by default (a skill map pulls its skills; an
evaluation pulls its rubrics), then posts to the backend.

```sh
zippy library push <file>                 # one catalog + its dependencies
zippy library push --all <folder>         # every catalog under a folder
zippy library push --all <folder> --prune -y
```

- `[FILE]` a single catalog: `skill_maps.yaml`, `skills.yaml`, `rubrics.yaml`,
  `evaluations.yaml`, or a standalone `lesson-*.mdx`. Mutually exclusive with `--all`.
- `--all <FOLDER>` push every catalog under a folder (recursive; excludes the reserved
  `courses/` subtree). Required for `--prune`.
- `--content-dir <DIR>` where to resolve related items and where the `manifest.yaml` lock lives
  (defaults to the file's parent, or the `--all` folder).
- `--no-deps` push only the literal items; skip dependency-closure resolution.
- `--prune` delete library content removed since the last push (diffed against `manifest.yaml`).
- `-y`, `--yes` skip the prune confirmation.
- `--dry-run` resolve and print the payload; send nothing.
- `--base-url`, `--token`, `--workspace-id`

## `zippy courses`

Manage course packs. A course pack publishes atomically as a unit.

### `zippy courses push`

- `--content-dir <DIR>` path to the courses directory (default `content/courses`)
- `--course <ID>` filter to a single course
- `--dry-run [FILE]` validate and print; optional FILE also dumps each course's JSON to
  `<FILE>-<course>.json`
- `--prune` soft-delete course content removed since the last publish
- `-y`, `--yes` skip the prune confirmation
- `--force` with `--prune`, hard-delete lessons that have student submissions (otherwise archived)
- `--base-url`, `--token`, `--workspace-id`

### `zippy courses init`

Scaffold a course folder.

- `--content-dir <DIR>`, `--course <NAME>`, `--template <default|json-path|server-id>`,
  `--from-json <FILE>`, `--from-course <ID>`, `--mode <draft|deployed>`, `--version`,
  `--course-name`

### `zippy courses list`

List courses in the workspace. Takes the standard credential flags.

### `zippy courses delete`

- `--id <COURSE_ID>` plus credential flags.

## `zippy lessons`

Author and publish individual lessons (MDX with frontmatter: `id`, `title`, `status`, `tags`).

- `create --title <T> --content <MDX-file> [--format text|json]`
- `update --lesson-id <ID> --content <MDX-file> [--title <T>] [--format]`
- `validate --content <MDX-file> [--remote]`
- `list`
- `init [--lesson-id <ID>] [--title "New Lesson"] [--root ./lessons] [--force]`
- `save [--lesson-id <ID>] [--root ./lessons]` refresh the `updated_at` frontmatter
- `push [--lesson-id <ID>] [--root ./lessons] [--force] [--format]` create-or-update a local file
- `push-dir <DIR> [-r|--recursive] [--format]` batch-push every `.mdx`, reading tags/status from
  each file's frontmatter

## `zippy rubrics`

- `create --name <N> --definition <JSON-file> [--description <D>] [--format]`
- `update --rubric-id <ID> --definition <JSON-file> [--format]`
- `list`

## `zippy assets`

Alias: `zippy files`. Manage workspace media.

- `upload <PATHS…> [--folder images/icons]` files or dirs (walked recursively)
- `list [DIR=.] [--remote]` local-vs-manifest sync status
- `publish [DIR=.] [--prune] [--yes] [--dry-run]` upload changes, write the manifest

## `zippy workspaces`

Alias: `zippy orgs`.

- `create` plus credential flags
- `list` plus credential flags

## `zippy evaluations`

Alias: `zippy eval`.

- `run [--content-dir <DIR>] [--course <ID>] [--question-id <ID>]
  [--answer <TEXT> | --answer-file <FILE>] [--question <TEXT>] [--dry-run] [--all]`

## `zippy skills`

Read-only inspection of skills in local content files.

- `--content-dir <DIR>`
