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

> A VM/SSH-based provisioner exists in the private `infra` repo, but the local build above is
> the simplest reliable path and is what current releases use.
