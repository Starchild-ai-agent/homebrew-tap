# frozen_string_literal: true

# Homebrew formula — builds StarChild from source on the user's machine.
# Source-build (not a cask) intentionally: a locally compiled .app has no
# com.apple.quarantine attribute, so Gatekeeper does NOT block it — no Apple
# Developer ID signing or notarization required.
#
# Install:  brew install --build-from-source ./starchild-app.rb
#       or: brew tap starchild/tap <your-tap-repo-url> && brew install starchild-app
class StarchildApp < Formula
  desc "StarChild desktop client — graphical front-end for the StarChild CLI"
  homepage "https://iamstarchild.com"
  # Source tarball is published alongside the CLI by sc-chatroom
  # (route /starchild-app/<file>, served from tools/starchild-app/).
  url "https://workroom.iamstarchild.com/starchild-app/starchild-app-0.4.13.tar.gz"
  version "0.4.13"
  sha256 "a6e509b8affd2f1a17433b53d30698f77d18861a2e451b184d0273c33b19afbd"
  # Formula-only revision: post_install now does rm + cp -R instead of
  # symlink (the symlink branch silently no-op'd on directory copies left
  # over from prior in-app upgrades). Source tarball unchanged; users on
  # 0.4.10 pick up 0.4.10_1 on their next `brew upgrade`.
  revision 1
  license :cannot_represent

  depends_on "node" => :build
  depends_on "rust" => :build
  depends_on :macos

  def install
    # Frontend deps + Tauri release build, bundling only the macOS .app
    # (dmg needs extra tooling; linux targets are irrelevant here).
    system "npm", "install"
    system "npm", "run", "tauri", "build", "--", "--bundles", "app"

    app = "src-tauri/target/release/bundle/macos/StarChild.app"
    prefix.install app
    # Manual fallback script for refreshing /Applications/StarChild.app after
    # a brew upgrade. Symlink-managed /Applications is the original design
    # but brew's symlink silently no-ops when /Applications/StarChild.app
    # is already a directory (left over from prior in-app upgrades or
    # from the existing refresh-applications.sh), so /Applications ends
    # up stale. The script verifies the Cellar bundle before touching
    # /Applications (see the script header).
    prefix.install "scripts"
    # `starchild-app` — launcher wrapper. Refreshes /Applications/StarChild.app
    # if it's stale (version mismatch with the freshly built Cellar leaf),
    # then execs the binary. The refresh runs OUTSIDE brew's post_install
    # Seatbelt sandbox (which blocks writes to /Applications), so it works
    # from this user-invoked wrapper even though brew's own post_install
    # cannot. This is what makes `brew upgrade starchild-app` + any
    # `starchild-app` invocation (terminal, alias, dock-click on a fresh
    # binary, …) refresh /Applications automatically.
    (bin/"starchild-app").write <<~SH
      #!/bin/bash
      set -e
      APPS="/Applications/StarChild.app"
      PREFIX_APP="#{prefix}/StarChild.app"

      need=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PREFIX_APP/Contents/Info.plist" 2>/dev/null)
      have=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APPS/Contents/Info.plist" 2>/dev/null)
      if [ -n "$need" ] && [ "$need" != "$have" ]; then
        printf '\\033[0;36m▸ refreshing /Applications/StarChild.app: v%s → v%s\\033[0m\\n' "${have:-missing}" "$need" >&2
        /bin/rm -rf "$APPS"
        /usr/bin/ditto "$PREFIX_APP" "$APPS"
      fi

      exec "$PREFIX_APP/Contents/MacOS/starchild-app" "$@"
    SH
    chmod 0755, bin/"starchild-app"
    # `starchild-app-refresh-applications` — explicit refresh wrapper for the
    # scripts/refresh-applications.sh flow (full brew upgrade + verify +
    # refresh). Most users only need the launcher above; this is the
    # recovery path if the launcher's no-op refresh was bypassed somehow.
    (bin/"starchild-app-refresh-applications").write <<~SH
      #!/bin/bash
      exec "#{prefix}/scripts/refresh-applications.sh" "$@"
    SH
    chmod 0755, bin/"starchild-app-refresh-applications"
  end

  # post_install is a no-op for /Applications: brew's post_install Seatbelt
  # sandbox denies writes to /Applications (the sandbox only allows Cellar +
  # HOMEBREW_PREFIX + temp/cache/log + xcode), so any rm/cp/ditto to
  # /Applications returns EPERM. The launcher wrapper above handles the
  # refresh when the user actually invokes the binary (no sandbox there),
  # which is the path that fires in practice after `brew upgrade`.
  def post_install
    oh1 "StarChild.app built at #{opt_prefix}/StarChild.app"
    oh1 "Run `starchild-app` once to refresh /Applications/StarChild.app and launch."
  end

  def caveats
    <<~EOS
      StarChild.app was built from source into the Cellar. Launch it with
      `starchild-app` (the launcher wrapper); on first invocation it will
      refresh /Applications/StarChild.app to the freshly built bundle and
      exec the binary. Subsequent invocations are a no-op when /Applications
      is already current.

      For users who upgrade via Homebrew:
        brew upgrade starchild-app    # Cellar gets the new bundle
        starchild-app                 # one invocation refreshes /Applications
        # … from here on, the dock icon and Launchpad both launch the
        # fresh bundle, and the in-app v0.4.10+ launch self-heal keeps
        # /Applications in sync on future launches.

      On `brew uninstall`, remove the leftover alias with:
        rm -rf /Applications/StarChild.app
    EOS
  end

  test do
    assert_path_exists bin/"starchild-app"
  end
end
