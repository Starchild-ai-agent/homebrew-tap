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
  url "https://workroom.iamstarchild.com/starchild-app/starchild-app-0.1.0.tar.gz"
  version "0.1.0"
  sha256 "075dbc8a85c12e4146260bd957ced2b028464857ac580991c23d5ef818d9b56e"
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
    # Expose a CLI launcher (formulae can't install into /Applications directly).
    (bin/"starchild-app").write <<~SH
      #!/bin/bash
      exec "#{prefix}/StarChild.app/Contents/MacOS/starchild-app" "$@"
    SH
    chmod 0755, bin/"starchild-app"
  end

  def caveats
    <<~EOS
      StarChild.app was built from source and installed to:
        #{prefix}/StarChild.app
      Launch with `starchild-app`, or symlink it into /Applications:
        ln -sf "#{prefix}/StarChild.app" /Applications/
      Compiled locally, so macOS Gatekeeper will not block it.
    EOS
  end

  test do
    assert_path_exists bin/"starchild-app"
  end
end
