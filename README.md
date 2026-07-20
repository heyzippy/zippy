<div align="center">

# Zippy CLI

**AI grading and content authoring for schools, tutoring centres, and teachers.**

`zippy` authors and publishes learning content, courses, lessons, rubrics, skill maps,
evaluations, and assets, to a Zippy workspace from local files, so you keep content in
git and ship it without the browser editor.

[Docs](https://heyzippy.io/docs) · [Coding-agent skill](https://heyzippy.io/docs/skills) · [llms-full.txt](https://heyzippy.io/llms-full.txt) · [Releases](https://github.com/heyzippy/zippy/releases)

</div>

---

## Install

```sh
curl -fsSL https://heyzippy.io/install.sh | sh
zippy --version
```

macOS (arm64, amd64) and Linux (amd64, arm64). Pin a version with
`ZIPPY_VERSION=v0.1.2`, or grab a tarball from the [Releases](https://github.com/heyzippy/zippy/releases) page.

The installer also offers to install the **coding-agent skill**. The skill installer detects
your agent(s) (Claude Code, Cursor, Codex, Windsurf) and links the skill into each. Force it
with `--with-skill` (or `ZIPPY_SKILL=1`), skip it with `--no-skill`. Install it separately any
time (add `--agent cursor` or `--agent all` to choose):

```sh
curl -fsSL https://heyzippy.io/skills/install.sh | sh
```

## Authenticate

```sh
zippy login          # email one-time code → writes ~/.zippy/config (0600)
```

For CI / headless, set environment variables instead (they override the config file):

```sh
export ZIPPY_API_URL="https://api.heyzippy.io"   # backend base URL
export ZIPPY_API_KEY="bk_live_…"                 # workspace API key (Bearer)
export ZIPPY_WORKSPACE_ID="<your-workspace-id>"         # workspace slug (x-org-id)
```

Credentials resolve as: **explicit flags → environment variables → `~/.zippy/config`**.
`zippy login` fills in your workspace id automatically; to set it by hand, find it in Zippy
under **Settings → General** ([app.heyzippy.io/teach/settings/general](https://app.heyzippy.io/teach/settings/general)).
Every push targets **your** workspace.

## Publish content

The core loop is **author local files → dry-run → push → (prune)**.

```console
$ zippy library push --all content/my-workspace --dry-run
zippy: resolving content/my-workspace (dependency closure on)
  skill_maps  psle-writing           (+ 6 skills)
  rubrics     p5-composition, psle-narrative
  lessons     lesson-nouns.mdx, lesson-adjectives.mdx
zippy: dry-run, nothing sent. 3 catalogs, 11 items would publish.

$ zippy library push --all content/my-workspace --workspace-id <your-workspace-id>
zippy: published 11 items to workspace 'my-workspace' ✓
zippy: wrote content/my-workspace/manifest.yaml
```

`zippy library push` is the standalone publisher for skill maps, skills, rubrics,
evaluations, and lessons. It resolves the **dependency closure** by default (a skill map
pulls its skills; an evaluation pulls its rubrics), so one push is complete.

Course packs publish atomically:

```sh
zippy courses push --content-dir content/my-workspace/courses --dry-run
zippy courses push --content-dir content/my-workspace/courses --course primary-6
```

Lessons and assets have their own push paths:

```sh
zippy lessons push-dir ./lessons -r          # batch-push every .mdx
zippy assets publish ./assets --dry-run      # upload changed media, write manifest
```

> Always `--dry-run` before anything with `--prune`. Prune soft-deletes (archives)
> content you removed locally, diffed against the committed `manifest.yaml`.

## Command reference

```
login        Log in by email code; saves an API key to a profile
profile      Manage login profiles (list, use, show, remove)
library      Push standalone content (skill maps, skills, rubrics, evaluations, lessons)  [alias: lib]
courses      Manage course packs (push, init, list, delete)
lessons      Manage lessons (create, update, validate, list, init, save, push, push-dir)
rubrics      Manage rubrics (create, update, list)
assets       Manage workspace assets (upload, list, publish)   [alias: files]
workspaces   Manage workspaces (create, list)                  [alias: orgs]
evaluations  Run evaluations                                   [alias: eval]
skills       Inspect skills from local content files
```

| Task | Command |
|------|---------|
| Authenticate | `zippy login` |
| Publish a catalog (+deps) | `zippy library push <file>` |
| Publish a workspace folder | `zippy library push --all <folder> [--prune -y]` |
| Publish a course pack | `zippy courses push --content-dir <dir> [--course ID]` |
| Preview only | add `--dry-run` |
| List things | `zippy {courses,rubrics,lessons,workspaces} list` |

**Full flags and every subcommand: [`cli.md`](./cli.md).** Or run `zippy <command> --help`.
Download binaries from [Releases](https://github.com/heyzippy/zippy/releases); guides and the
coding-agent skill live at [heyzippy.io/docs](https://heyzippy.io/docs).

## The content model

Content lives under `content/<workspace>/`:

```
content/<workspace>/
├── courses/                 # reserved: course packs (zippy courses push)
├── skill_maps.yaml          # standalone catalogs (zippy library push)
├── skills.yaml
├── rubrics.yaml
├── evaluations.yaml
├── lesson-*.mdx
└── manifest.yaml            # generated deploy lock: commit this
```

## Coding agents

Zippy ships a skill in the [Agent Skills](https://agentskills.io) format so coding agents
can drive the CLI correctly. It lives in [`skills/zippy/`](./skills/zippy/) in this repo.
Following the Agent Skills convention, the installer puts the files once in
`~/.agents/skills/zippy/` (the cross-client location) and symlinks each detected agent's own
skills dir at it: `~/.claude/skills/zippy` (Claude Code), plus `~/.cursor`, `~/.codex`,
`~/.windsurf` when present. It installs at **user scope** by default, so the skill is available
in every project.

```sh
curl -fsSL https://heyzippy.io/skills/install.sh | sh                      # detect + link
curl -fsSL https://heyzippy.io/skills/install.sh | sh -s -- --agent claude,cursor
curl -fsSL https://heyzippy.io/skills/install.sh | sh -s -- --project      # this project only
```

For an agent not detected, point your rules/system prompt at
[`skills/zippy/SKILL.md`](./skills/zippy/SKILL.md), or fetch the full plain-text reference:

```sh
curl -fsSL https://heyzippy.io/llms-full.txt
```

## Links

- Docs: [heyzippy.io/docs](https://heyzippy.io/docs)
- Issues: [github.com/heyzippy/zippy/issues](https://github.com/heyzippy/zippy/issues)
- The Zippy backend, frontends, and CLI source live in `heyzippy/platform` (private).

## License

MIT, see [LICENSE](./LICENSE).
