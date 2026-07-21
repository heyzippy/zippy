---
name: zippy_assets
description: Work with workspace assets (images, PDFs, files) organised into folders. Use to find an existing asset URL to embed in a lesson, browse/create folders, upload a new asset (CLI runtime only), list / search / delete assets. Workspace-scoped — every asset belongs to the caller's workspace.
tags:
  - zippy
  - assets
  - content
---

# Zippy Assets

You manage workspace assets through the `/admin/assets` API surface.
An "asset" is a single uploaded blob (image / PDF / file) that lives
in a **folder** and is reachable at a public URL on the workspace's
asset domain.

The runtime model (browser vs CLI/cloud) is already in your context
via the agent prompt — no `load_skill` needed.

## Model: folders & path identity

Every asset has a `key` of the form
`<workspace_id>/assets/<folder>/<filename>` (the `<folder>` part is
empty for a root-level asset). The `folder` field on an asset is just
that path segment.

**The path is the asset's identity.** Re-uploading a file to the same
`<folder>/<filename>` **updates that asset in place** (same id, new
content) — it is not a new asset. Two different files with the same
name in two folders are two separate assets.

The skill never invents URLs. Every public URL you return MUST come
from a real `/admin/assets` response.

## What this skill is for

| Want to … | Recipe |
|---|---|
| Find an image URL to embed in a lesson | **Step A — list / search assets** |
| Browse or create folders | **Step D — folders** |
| Upload a new file (CLI / cloud runtime) | **Step B — upload (CLI)** |
| Upload a new file (browser runtime) | **Tell the teacher to use the Upload button on the Assets page** — the agent has no `uploadAsset` tool in browser. Do NOT construct multipart requests through `zippy_request`. |
| Remove an asset | **Step C — delete** |

## Step A — list / search assets

```
zippy_request({ method: "GET", path: "/admin/assets?page=1&per_page=50" })
```

Filters (combine freely, URL-encode values):
- `&search=<query>` — case-insensitive filename match.
- `&folder=<path>` — assets directly in that folder; `&folder=` (empty)
  lists the root.

Response shape:

```json
{
  "assets": [
    {
      "id": "<asset-id>",
      "hash": "<sha256-hex>",
      "filename": "<sanitized-filename>",
      "url": "<full public URL — paste this into MDX>",
      "key": "<workspace_id>/assets/<folder>/<filename>",
      "folder": "<folder path, '' for root>",
      "size": 123456,
      "content_type": "image/png",
      "created_at": "...",
      "visibility": "workspace",
      "owner_id": "<user-id>"
    }
  ],
  "total": 42,
  "page": 1
}
```

The `url` field is the canonical public link. **Use it verbatim.** If
the response is paginated, page through until you find the asset.

### Embedding an asset in a lesson

```mdx
![<ALT-TEXT>](<URL FROM /admin/assets RESPONSE>)
```

For non-image assets, link them: `[<FILENAME>](<URL>)`.

## Step B — upload (CLI / cloud runtime only)

**Browser runtime: skip this step.** Tell the teacher to upload
through the UI.

Single file (≤ 20 MB) — add an optional `folder` form field to place
it in a folder:

```bash
curl -sS -X POST "$ZIPPY_API_URL/admin/assets" \
  -H "Authorization: Bearer $ZIPPY_API_KEY" \
  -H "x-org-id: $ZIPPY_WORKSPACE_ID" \
  -F "file=@<LOCAL-PATH>" \
  -F "folder=images/icons"
```

Returns the same `AssetInfo` shape as Step A.

Bulk upload (≤ 100 MB total, each ≤ 20 MB) — every file lands in the
one `folder`:

```bash
curl -sS -X POST "$ZIPPY_API_URL/admin/assets/bulk" \
  -H "Authorization: Bearer $ZIPPY_API_KEY" \
  -H "x-org-id: $ZIPPY_WORKSPACE_ID" \
  -F "folder=images" \
  -F "file=@<PATH-1>" -F "file=@<PATH-2>"
```

Response: `{ "assets": [ /* AssetInfo[] */ ], "updated": 0, "errors": [] }`.
`updated` counts files that updated an existing path in place — expected,
not an error.

For many files or whole directories, prefer the CLI:
- `zippy assets upload <paths...> [--folder <f>]` — ad-hoc upload (legacy
  alias: `zippy files upload`).
- `zippy assets list [<dir>] [-a]` — show local-vs-server sync status.
- `zippy assets publish <dir> [--prune]` — publish a directory tree as
  folders, tracked by a committed `manifest.yaml`; `--prune` soft-deletes
  assets removed from the directory since the last publish.

## Step C — delete

```
zippy_request({ method: "DELETE", path: "/admin/assets/<asset-id>" })
```

Returns `{ deleted: "<asset-id>" }`. This is a **soft-delete**: the row
is hidden and the asset stops appearing in listings, but the stored blob
is kept. Re-uploading a file to the same path **revives** the asset.
Never call delete without an explicit teacher instruction.

Bulk soft-delete: `POST /admin/assets/prune` with
`{ "asset_ids": ["<id>", ...] }` → `{ "pruned": <count> }`.

## Step D — folders

List every folder path in the workspace:

```
zippy_request({ method: "GET", path: "/admin/assets/folders" })
```

→ `{ "folders": ["images", "images/icons", "audio"] }`.

Create an empty folder:

```
zippy_request({
  method: "POST", path: "/admin/assets/folders",
  body: { path: "images/icons" }
})
```

→ `{ "folder": "images/icons" }`. Folders are also created implicitly
when an asset is uploaded into one.

## MCP tools

When connected over MCP, the same surface is available as tools:
`zippy_list_assets` (`folder` / `search`), `zippy_list_asset_folders`,
`zippy_get_asset` (`id`), and `zippy_create_asset_folder` (`path`).

## Errors

| Status | Likely cause | Fix |
|---|---|---|
| `400` "File exceeds 20 MB limit" | Single file too large | Split / compress before upload. |
| `400` "Total upload exceeds 100 MB limit" | Bulk payload too large | Send smaller batches. |
| `400` "Invalid folder segment" | `folder` contains `..` or empty segments | Use a clean `a/b/c` path. |
| `400` "missing field: file" | curl didn't include `-F file=@…` | Add the part. |
| `500` "ASSET_DOMAIN not set" | Server env misconfigured | Surface verbatim and stop. |
| `404` on DELETE | Asset id is from a different workspace, or already deleted | Confirm id by listing first. |

## Rules

- **Never invent an asset URL.** Always list first; only return URLs
  you actually got back from `/admin/assets`.
- **One workspace per call.** The bearer token + `x-org-id` header
  scope everything.
- **Browser uploads are user-driven**, not agent-driven.
- **Path is identity.** Re-uploading to the same folder + filename
  updates the asset in place; it does not create a duplicate.
