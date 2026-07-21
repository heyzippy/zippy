---
name: zippy_execution
description: "DEPRECATED — runtime execution context (db_*/init_content/save_content for browser; Bash+curl for cli/cloud) is now inlined directly into the base agent prompt (zippy / zippy_browser) via the `zippy_execution_browser` and `zippy_execution_default` prompt-template partials. Intent skills no longer need to `load_skill` this — calling it is a no-op."
tags:
  - zippy
  - execution
  - deprecated
---

# Zippy Execution (deprecated)

The runtime model — which tools to use, how to read uploads, how
preview-confirm works, lesson / activity / submission lifecycles —
is now part of your base agent prompt (see the `zippy_execution_*`
sections inlined via `{{> zippy_execution_browser}}` /
`{{> zippy_execution_default}}` in `zippy_browser.md` / `zippy.md`).

You do NOT need to `load_skill` this. Skip Step 0 — go directly to
your per-intent recipe.

If you find yourself here, your skill is out of date. Stop and
proceed with the recipe — the runtime model is already loaded.
