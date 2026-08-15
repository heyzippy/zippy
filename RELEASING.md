# Releasing the Zippy CLI

Releases live on this repo (`heyzippy/zippy`) as GitHub Release assets that
`https://heyzippy.io/install.sh` downloads. The CLI **source** lives in the private
`heyzippy/platform` repo (`zippy-cli/`).

## Asset contract (do not change casually)

`https://heyzippy.io/install.sh` expects, on the `--latest` release, tag `v<x.y.z>`:

```
zippy-darwin-arm64.tar.gz
zippy-darwin-amd64.tar.gz
zippy-linux-amd64.tar.gz
zippy-linux-arm64.tar.gz
```

Each tarball contains the `zippy` binary at its root.

## Build all four targets locally

macOS builds natively; Linux is cross-compiled from macOS with
[`cargo-zigbuild`](https://github.com/rust-cross/cargo-zigbuild) (needs `zig`). From the
platform checkout:

```sh
# one-time toolchain
brew install zig
cargo install cargo-zigbuild
rustup target add x86_64-apple-darwin aarch64-unknown-linux-gnu x86_64-unknown-linux-gnu

# bump the version in zippy-cli/Cargo.toml, then:
cargo zigbuild --release --target x86_64-unknown-linux-gnu.2.31  -p zippy-cli --bin zippy
cargo zigbuild --release --target aarch64-unknown-linux-gnu.2.31 -p zippy-cli --bin zippy
cargo build    --release --target aarch64-apple-darwin           -p zippy-cli --bin zippy
cargo build    --release --target x86_64-apple-darwin            -p zippy-cli --bin zippy
```

Package each binary as `zippy-<slug>.tar.gz` (slug = `darwin-arm64`, `darwin-amd64`,
`linux-amd64`, `linux-arm64`), binary at the archive root.

## Publish

```sh
VER=0.1.3
gh release create "v$VER" --repo heyzippy/zippy --latest \
  --title "v$VER" --notes "…" \
  releases/$VER/zippy-*.tar.gz
```

Verify:

```sh
curl -sfL -o /dev/null -w "%{http_code}\n" \
  https://github.com/heyzippy/zippy/releases/latest/download/zippy-darwin-arm64.tar.gz
curl -fsSL https://heyzippy.io/install.sh | ZIPPY_INSTALL_DIR=/tmp/zt sh && /tmp/zt/zippy --version
```

## Skill sync

The coding-agent skill under `skills/zippy/` is the single source of truth the installers
download from (`raw.githubusercontent.com/heyzippy/zippy/main/skills/...`). Keep it in step
with the CLI when commands change, and keep `skills/manifest.txt` listing every skill file.

**This skill is hand-maintained here. Do not "sync" it from the platform repo.** The platform's
`agents/distri-skills/*.md` are the *in-product* runtime skills for the browser editor and
`distri run` — they describe MCP tools (`zippy_validate_content`, `load_skill`) that a user's
Claude Code or Cursor install cannot call, and one of them states outright that "there is no
bespoke CLI". Copying them into `skills/` is what broke every install for 3.5 weeks after
v0.1.5: it deleted `manifest.txt` and `skills/zippy/`, so `install.sh` aborted on its first
fetch. The two trees serve different runtimes and are not interchangeable.

Before pushing anything that touches `skills/`, run the contract check — the same loop
`install.sh` performs, against the working tree:

```sh
./scripts/check-skills.sh
```

CI runs it on every PR touching `skills/` (`.github/workflows/skills.yml`) and exercises the
real published installer on `main` and weekly.

> A VM/SSH-based provisioner exists in the private `infra` repo, but the local build above is
> the simplest reliable path and is what current releases use.
