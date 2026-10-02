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
  version "0.5.57"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-darwin-arm64"
      sha256 "c0718b2a5456edbaad586afd4c28740ad99df21c2095fc9611599bb0b9c0650d"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-darwin-amd64"
      sha256 "a03c509141af8e7bb33076dda9ef1eba24f2f0eeaed0136c55686109d749eb81"
    end
  end

  on_linux do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-linux-arm64"
      sha256 "d8db35e3160ca9a120edd27ab023fb8ceb6b4f3d33d6ec2e25f9e9694d3489d7"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-linux-amd64"
      sha256 "fa6667013e1af729cd71f1269cee47623e4399d4b21c8f2a387cb1efd402c2c2"
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
