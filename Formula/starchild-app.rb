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
  url "https://workroom.iamstarchild.com/starchild-app/starchild-app-0.4.10.tar.gz"
  version "0.4.10"
  sha256 "0dd5e7342d70064e2f11004fcb953ef32108ba68d6fd825a475749009d333b20"
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
    # a terminal-driven `brew upgrade`. The in-app Upgrade button does this
    # via a detached shell; this is the recovery path for users who upgraded
    # outside the app or whose detached shell failed. The script verifies
    # the Cellar bundle before touching /Applications (see the script header).
    prefix.install "scripts"
    # Expose a CLI launcher (formulae can't install into /Applications directly).
    (bin/"starchild-app").write <<~SH
      #!/bin/bash
      exec "#{prefix}/StarChild.app/Contents/MacOS/starchild-app" "$@"
    SH
    chmod 0755, bin/"starchild-app"
    # PATH-accessible wrapper for the manual /Applications refresh script.
    # Users who hit the "read_dir failed" warning during an in-app upgrade
    # can just run `starchild-app-refresh-applications` instead of digging
    # through the Cellar path.
    (bin/"starchild-app-refresh-applications").write <<~SH
      #!/bin/bash
      exec "#{prefix}/scripts/refresh-applications.sh" "$@"
    SH
    chmod 0755, bin/"starchild-app-refresh-applications"
  end

  # Copy the freshly built .app into /Applications so the dock icon /
  # Launchpad entry points at the new build. Always do a directory copy —
  # `File.symlink` into /Applications is unreliable on real user machines
  # (TCC / runtime resolution can drop the symlink, leaving /Applications
  # stuck on a previous install), and the formula's earlier symlink-only
  # variant silently no-op'd when /Applications/StarChild.app was already a
  # directory left over from a prior in-app upgrade (which itself does
  # rm + cp -R). This branch always replaces whatever's at /Applications
  # with the freshly built bundle, gated on a version mismatch so re-runs
  # without a version bump are a no-op.
  #
  # Use `/bin/rm` and `/bin/cp -R` via `system()` instead of `FileUtils`
  # because in the formula context `FileUtils.cp_r` to /Applications has
  # been observed throwing "Operation not permitted @ dir_s_mkdir" with
  # the path duplicated as /Applications/StarChild.app/StarChild.app —
  # a "copy INTO existing dir" pattern that fires when the prior
  # `rm_rf` left the target in place. The shell utilities are predictable
  # and produce a single, atomic refresh.
  def post_install
    target = "/Applications/StarChild.app"
    source = "#{opt_prefix}/StarChild.app"

    installed_version = nil
    if File.exist?("#{target}/Contents/Info.plist")
      installed_version =
        `/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "#{target}/Contents/Info.plist" 2>/dev/null`.strip
    end

    if installed_version == version
      oh1 "/Applications/StarChild.app is already at v#{version} — skipping"
      return
    end

    system "/bin/rm", "-rf", target
    system "/bin/cp", "-R", source, target
    oh1 "Refreshed /Applications/StarChild.app → v#{version} (was #{installed_version || 'missing'})"
  rescue StandardError => e
    opoo "Couldn't refresh /Applications/StarChild.app: #{e.message}"
  end

  def caveats
    <<~EOS
      StarChild.app was built from source and copied into /Applications.
      Launch it from Launchpad/Finder, or run `starchild-app` from the terminal.
      Compiled locally, so macOS Gatekeeper will not block it.

      Each `brew upgrade starchild-app` refreshes /Applications/StarChild.app
      to the freshly built bundle automatically. No manual refresh step is
      needed for users who upgrade via Homebrew.

      If a manual refresh is ever required (e.g. /Applications/StarChild.app
      was deleted or replaced with an unrelated bundle), run
      `starchild-app-refresh-applications`.

      On `brew uninstall`, remove the leftover alias with:
        rm -f /Applications/StarChild.app
    EOS
  end

  test do
    assert_path_exists bin/"starchild-app"
  end
end
