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
  version "0.5.67"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-darwin-arm64"
      sha256 "84d75f01cadb8f4e55bccbc6d6c74b7fd7775acf95727efeff1d8cd124ac7810"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-darwin-amd64"
      sha256 "d7b60944e916edb0527910793347207789a6d5042680ceaa483d96ae85e02969"
    end
  end

  on_linux do
    on_arm do
      url "https://workroom.iamstarchild.com/starchild-linux-arm64"
      sha256 "851bc2a16505b973fb3eb2cae88654b14bd403767755b628c91c079767692e1f"
    end
    on_intel do
      url "https://workroom.iamstarchild.com/starchild-linux-amd64"
      sha256 "95b6c099392506a9e44e2db613075263347f286658f1051dae701f342afc7fa2"
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
