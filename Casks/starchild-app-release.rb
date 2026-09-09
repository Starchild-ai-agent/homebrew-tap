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
  # Unsigned on purpose (no Apple Developer cert). Homebrew 6 quarantines
  # cask downloads (cask/download.rb → quarantine()), so Gatekeeper would
  # assess the ad-hoc-signed app on first launch — the assessment fails and
  # macOS shows the hard "'Starchild' is damaged and can't be opened" block
  # with no "Open Anyway" path. The postflight below strips the quarantine
  # attribute after install, matching what the source formula channel has
  # always effectively done (a locally built app is never quarantined). The
  # user still explicitly chose to install via brew.
  version "0.5.43"

  on_arm do
    url "https://workroom.iamstarchild.com/starchild-app-release/starchild-app-#{version}-macos-arm64.zip"
    sha256 "5a9911635cc222aa3c29dabd3a18f5e8c79c2ae9a95c9e6f080fee5876828eb7"
  end
  on_intel do
    url "https://workroom.iamstarchild.com/starchild-app-release/starchild-app-#{version}-macos-intel.zip"
    sha256 "43866b21c2bb8cbfe3ef0ddc1fab54eeb3cd3df5cbdc04d4aa1858c29ff1efaa"
  end
  app "StarChild.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/StarChild.app"]
  end

  # The CLI companion is a separate formula (prebuilt binaries). Installing
  # the cask does not force it; the app's first-run flow handles it.
  depends_on formula: "starchild"

  zap trash: [
    "~/Library/Application Support/com.iamstarchild.app",
    "~/Library/Caches/com.iamstarchild.app",
    "~/Library/Preferences/com.iamstarchild.app.plist",
  ]
end
