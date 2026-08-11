# frozen_string_literal: true

# StarChild CLI — single static Go binary, distributed prebuilt per platform by
# sc-chatroom at /starchild-<os>-<arch>. After install, the CLI self-updates
# (`starchild update`, and the daemon every 6h), so the pinned version below is
# only the install-time baseline.
#
# NOTE: the download URLs are version-less (always the server's current build),
# so each sha256 below must be refreshed whenever sc-chatroom ships a new CLI.
class Starchild < Formula
  desc "Talk to your StarChild agent / join sc-chatroom rooms (BYOA)"
  homepage "https://iamstarchild.com"
  version "0.5.32"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-darwin-arm64"
      sha256 "0d650c500b79a7bb3006c059c7bbe0883ae4f2e821132fdc1715746b89afc54e"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-darwin-amd64"
      sha256 "d24916cb7c276681082391ab945649a714e5703051de543763f8026be3027745"
    end
  end

  on_linux do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-linux-arm64"
      sha256 "e8f0fcd0761da78f91d12e7250c835030b2b8070d5bfcf8f3532fd733963ddf9"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-linux-amd64"
      sha256 "a6bfe91cade63926964f71c2248f6010cde5d7f54113308734da1382842051f6"
    end
  end

  def install
    # The downloaded file is the bare binary named per platform; install as `starchild`.
    bin.install Dir["*"].first => "starchild"
  end

  test do
    assert_match "starchild", shell_output("#{bin}/starchild --version 2>&1")
  end
end
