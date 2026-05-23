# Zippy CLI

Zippy is a content + learning platform. This repo distributes the `zippy` CLI used to author courses, lessons, rubrics, and assets against a Zippy server.

The Zippy backend, frontends, and CLI source live in [heyzippy/platform](https://github.com/heyzippy/platform) (private).

## Install

```sh
curl -fsSL https://heyzippy.io/install.sh | sh
```

Pin a version:

```sh
curl -fsSL https://heyzippy.io/install.sh | ZIPPY_VERSION=v0.1.0 sh
```

Or download a tarball directly from the [Releases](https://github.com/heyzippy/zippy/releases) page. Supported platforms: macOS (arm64, amd64), Linux (amd64, arm64).

## Usage

```sh
zippy login                      # authenticate via browser, saves to ~/.zippy/config
zippy courses push               # publish course pack to the backend
zippy courses init               # scaffold a new course folder
zippy courses list               # list courses in the current workspace
zippy workspaces create          # create a workspace (alias: zippy orgs)
zippy workspaces list
zippy evaluations run            # run an evaluation against course content (alias: zippy eval)
zippy skills                     # inspect skills from local content files
zippy lessons {create,update,validate,list}
zippy rubrics  {create,update,list}
zippy assets   {upload,list,publish}   # alias: zippy files
```

Run `zippy <subcommand> --help` for full flags.

## MCP servers

The Zippy backend exposes [Model Context Protocol](https://modelcontextprotocol.io) tools over Streamable HTTP, so Claude Code, Cursor, and other MCP clients can drive content generation, grading, and assignment directly:

| Endpoint        | Audience           | Auth                                                 |
|-----------------|--------------------|------------------------------------------------------|
| `/mcp`          | Admin / authors    | `Authorization: Bearer bk_live_…` + `x-org-id: <ws>` |
| `/student/mcp`  | Student workspace  | Student API key                                      |

Tools mirror the CLI surface (courses, lessons, rubrics, grading) and stream incremental results.

## Skills

The `skills/` directory contains author-facing skill prompts used by Zippy agents (`zippy_course`, `zippy_grade`, `zippy_lesson`, `zippy_rubric`, …). Drop them into a Claude Code plugin or copy them into your own agent setup.

## Links

- Docs: [heyzippy.io](https://heyzippy.io)
- Issues: [github.com/heyzippy/zippy/issues](https://github.com/heyzippy/zippy/issues)

## License

MIT — see [LICENSE](./LICENSE).
