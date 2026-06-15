# StarChild Homebrew Tap

Homebrew formulae for StarChild. The source tarball / binaries are hosted by
sc-chatroom (`workroom.iamstarchild.com`) — **no GitHub or public repo required**;
this tap can live on any git host (including a private/self-hosted one).

## Install

```sh
brew tap starchild/tap <this-repo-git-url>
brew trust starchild/tap      # required: brew refuses untrusted third-party taps
brew install starchild        # CLI (prebuilt binary, self-updates after install)
brew install starchild-app    # desktop app (built from source on your machine)
```

`<this-repo-git-url>` is wherever you push this repo (self-hosted git, private
GitLab/Gitea, GitHub, …). The repo name must keep the `homebrew-` prefix.

> **`brew trust` is required.** Recent Homebrew refuses to load formulae from an
> untrusted third-party tap (`Error: Refusing to load formula … from untrusted
> tap`); run it once before installing. If Homebrew's auto-update hangs on a slow
> network, prefix commands with `HOMEBREW_NO_AUTO_UPDATE=1`.

## Formulae

| Formula | What | How it installs |
|---------|------|-----------------|
| `starchild` | CLI (single Go binary) | Downloads the prebuilt per-platform binary; self-updates afterward |
| `starchild-app` | Desktop app (Tauri) | **Builds from source** (rust + node) — locally compiled, so macOS Gatekeeper doesn't block it; no signing/notarization needed |

## Maintenance (per release)

**CLI** (`Formula/starchild.rb`): the binary URLs are version-less (always the
server's current build), so refresh `version` + each platform `sha256` whenever
sc-chatroom ships a new CLI. Get the shas from `tools/starchild/dist/`:

```sh
for f in tools/starchild/dist/starchild-*; do shasum -a 256 "$f"; done
```

**App** (`Formula/starchild-app.rb`): bump `version`, rebuild the source tarball
into `sc-chatroom/tools/starchild-app/`, deploy, then update `url` + `sha256`.
See `starchild-app/packaging/homebrew/RELEASE.md` for the full runbook.
