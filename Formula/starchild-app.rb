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
  url "https://workroom.iamstarchild.com/starchild-app/starchild-app-0.4.6.tar.gz"
  version "0.4.6"
  sha256 "88112fcaafaf39512bcbe70b0cdfcabbde5c4024110c679240c40c2abc9580ba"
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

  # Link the app into /Applications so it shows up in Launchpad/Finder. Points at
  # opt_prefix (stable across versions) so an upgrade keeps the link valid. Only
  # replaces a prior symlink — never clobbers a real app a user placed there —
  # and never fails the install if /Applications isn't writable.
  def post_install
    target = "/Applications/StarChild.app"
    source = "#{opt_prefix}/StarChild.app"
    File.delete(target) if File.symlink?(target)
    File.symlink(source, target) unless File.exist?(target)
  rescue StandardError => e
    opoo "Couldn't link StarChild.app into /Applications: #{e.message}"
  end

  def caveats
    <<~EOS
      StarChild.app was built from source and linked into /Applications.
      Launch it from Launchpad/Finder, or run `starchild-app` from the terminal.
      Compiled locally, so macOS Gatekeeper will not block it.

      If /Applications/StarChild.app is stale after a terminal-driven
      `brew upgrade`, run `starchild-app-refresh-applications` to refresh it.

      On `brew uninstall`, remove the leftover alias with:
        rm -f /Applications/StarChild.app
    EOS
  end

  test do
    assert_path_exists bin/"starchild-app"
  end
end
