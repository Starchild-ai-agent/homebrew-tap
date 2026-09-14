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
  version "0.5.47-3-g359a0c3"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-darwin-arm64"
      sha256 "e563b7a5d67686b3639a257dcacb5381ddfbe9ec0db3a2008734a2fee160ce12"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-darwin-amd64"
      sha256 "17fe02271a4f4511d7726d5e9012e5f27b149574e1eb0d8fc2d780fa8e212e11"
    end
  end

  on_linux do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-linux-arm64"
      sha256 "9043bb5d44a27c64969724df73bba76544eb5f863e1c230e6008cac2333417ba"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-linux-amd64"
      sha256 "c6c617afe9c44274e603a6f29d7a4c94455a9641e4d8eba7cf5cad9d57a6c7f6"
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
