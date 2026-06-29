# StarChild Homebrew Tap

Homebrew formulae for StarChild. The source tarball / binaries are fetched from
the StarChild build server; this tap can
live on any git host (including a private/self-hosted one).

## Install

```sh
brew tap starchild/tap https://github.com/Starchild-ai-agent/homebrew-tap
brew trust starchild/tap      
brew install starchild        
brew install starchild-app    
```

> **`brew trust` is required.** Recent Homebrew refuses to load formulae from an
> untrusted third-party tap (`Error: Refusing to load formula … from untrusted
> tap`); run it once before installing. If Homebrew's auto-update hangs on a slow
> network, prefix commands with `HOMEBREW_NO_AUTO_UPDATE=1`.

## Formulae

| Formula         | What                   | How it installs                                                                                                                                                                                                                                          |
| --------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `starchild`     | CLI (single Go binary) | Downloads the prebuilt per-platform binary; self-updates afterward                                                                                                                                                                                       |
| `starchild-app` | Desktop app (Tauri)    | **Builds from source** (rust + node) — locally compiled, so macOS Gatekeeper doesn't block it; no signing/notarization needed. Auto-symlinks into `/Applications`, and checks for newer versions in-app (offers `brew upgrade` from a Homebrew install). |

## Maintenance (per release)

**CLI** (`Formula/starchild.rb`): the binary URLs are version-less (always the
server's current build), so refresh `version` + each platform `sha256` whenever
sc-chatroom ships a new CLI. Get the shas from `tools/starchild/dist/`:

```sh
for f in tools/starchild/dist/starchild-*; do shasum -a 256 "$f"; done
```

**App** (`Formula/starchild-app.rb`): use `starchild-app/scripts/release.sh app
<version>` — it bumps `package.json` + `tauri.conf.json` + `src-tauri/Cargo.toml`
(all three must match, or the in-app update check misreports), rebuilds the
source tarball into `sc-chatroom/tools/starchild-app/`, and refreshes this
formula's `url`/`version`/`sha256`. Then deploy sc-chatroom and push this tap.
See `starchild-app/packaging/homebrew/RELEASE.md` for the full runbook.

> Tip: run the app's `cargo build` once **before** packaging so the tarball's
> `Cargo.lock` reflects the new version (otherwise a fresh `brew install`
> regenerates it on first compile).
