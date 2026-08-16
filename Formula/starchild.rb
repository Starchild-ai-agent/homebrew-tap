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
  version "0.5.36"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-darwin-arm64"
      sha256 "20501128125d26a4a52937cd08f7bfba9fb94cfe5ce1861f2ccd3dbaa1ee0ab5"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-darwin-amd64"
      sha256 "2d97d0767290189f126c115490443d5a33b58c695d381b033dab9e8487ab5258"
    end
  end

  on_linux do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-linux-arm64"
      sha256 "b7060877bc79de39ac2f08451518fe41ed9656da00b8972c712036c40cba5477"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-linux-amd64"
      sha256 "649bfb473197c6bac96e9835e39a39bce79f97ec5f00788f41a4779d236f4b0d"
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
