# Publishing workflow

Two publish surfaces, one mental model: **author local files → dry-run → push → (prune)**.

| You have… | Command | Endpoint |
|-----------|---------|----------|
| Standalone catalogs (skill maps, skills, rubrics, evaluations, lessons) | `zippy library push` | `/admin/publish/standalone` |
| A full course pack (course + units + lessons) | `zippy courses push` | `/admin/publish` |
| Media (images, audio) | `zippy assets publish` | asset upload + manifest |
| Individual lesson MDX files | `zippy lessons push` / `push-dir` | lesson create/update |

## Standard flow (standalone library)

```bash
# 1. Authenticate once
zippy login                       # or export ZIPPY_API_KEY / ZIPPY_WORKSPACE_ID

# 2. Preview — resolves dependency closure, sends nothing
zippy library push --all content/zippydiscover --dry-run

# 3. Push everything under the workspace folder
zippy library push --all content/zippydiscover --workspace-id zippydiscover

# 4. Prune content you deleted locally (diffs against manifest.yaml). Preview first.
zippy library push --all content/zippydiscover --prune --dry-run
zippy library push --all content/zippydiscover --prune -y
```

Push a single catalog and its dependencies:

```bash
zippy library push content/zippydiscover/rubrics.yaml            # rubrics + referenced skills
zippy library push content/zippydiscover/skill_maps.yaml --no-deps   # just the maps
```

## The manifest lock

An `--all` push writes `<folder>/manifest.yaml` (`kind: library_manifest`) recording the
deployed `files`, `skill_maps`, `skills`, `rubrics`, `evaluations`, keyed per
`{api_url, workspace_id}` deployment.

- **Commit it.** It is how `--prune` knows what existed last time.
- Pushing to a different `workspace_id` or `api_url` tracks its own entry — the same
  content can be deployed to `zippydiscover` and a school workspace independently.

## Course packs

```bash
zippy courses push --content-dir content/zippydiscover/courses --dry-run
zippy courses push --content-dir content/zippydiscover/courses --course primary-6
zippy courses push --content-dir content/zippydiscover/courses --prune -y
# --hard-delete-with-submissions also removes pruned lessons that have student
# submissions (default: archive them).
```

Course packs publish **atomically** — the whole pack validates and commits as a unit.

## Assets

```bash
zippy assets list ./assets --remote      # local-vs-server sync status
zippy assets publish ./assets --dry-run
zippy assets publish ./assets --prune -y
```

## "Push to discover"

The public catalog workspace is `zippydiscover`. To publish official/public content:

```bash
zippy library push --all content/zippydiscover --workspace-id zippydiscover
```

## Safety rules

- `--dry-run` before every `--prune`.
- `--prune` requires `--all`.
- Prune soft-deletes (archives) by default; nothing is hard-deleted unless you pass
  `--hard-delete-with-submissions` (courses) — and even then only lessons with submissions.
- Keep credentials in `zippy login` / `ZIPPY_API_KEY`, never in content files or `manifest.yaml`.
