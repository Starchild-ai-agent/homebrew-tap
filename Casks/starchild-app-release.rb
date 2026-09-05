cask "starchild-app-release" do
  desc "Desktop client for the StarChild AI agent chat"
  homepage "https://iamstarchild.com"

  # PREBUILT channel: CI cross-compiles StarChild.app per architecture and
  # publishes the zips alongside the CLI. This is the fast install path —
  # `brew install --cask starchild-app-release` downloads a finished app
  # instead of compiling the whole Rust + Node project locally (the source
  # formula, `brew install starchild-app`, can take hours on Intel Macs where
  # Homebrew provides no bottles).
  #
  # Unsigned on purpose (no Apple Developer cert): brew downloads via curl,
  # which never sets the quarantine xattr, so Gatekeeper does not assess the
  # app — the same mechanism the source formula has always relied on.
  version "0.5.41-9-gef01fd0"

  on_arm do
    url "https://workroom.iamstarchild.com/starchild-app-release/starchild-app-#{version}-macos-arm64.zip"
    sha256 "3272c984a352eb7951b67162a814ceff531d49b6a556141614f95eba82630a0d"
  end
  on_intel do
    url "https://workroom.iamstarchild.com/starchild-app-release/starchild-app-#{version}-macos-intel.zip"
    sha256 "ab15b10dde31725e1323e2e9456c991448d6cdbab662fa3f5fb6c957498ae55b"
  end
  app "StarChild.app"

  # The CLI companion is a separate formula (prebuilt binaries). Installing
  # the cask does not force it; the app's first-run flow handles it.
  depends_on formula: "starchild"

  zap trash: [
    "~/Library/Application Support/com.iamstarchild.app",
    "~/Library/Caches/com.iamstarchild.app",
    "~/Library/Preferences/com.iamstarchild.app.plist",
  ]
end
