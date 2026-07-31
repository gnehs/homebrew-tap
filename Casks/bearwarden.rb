cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.19"
  sha256 arm:   "9cb400d261348bd301e8059c4aab28ff939ece590f476734db2546b79e702954",
         intel: "8068f7f7f6376d44c1ea1a4d2696a25c36abf333a714b8856e4c02150d595e36"

  url "https://github.com/gnehs/BearWarden/releases/download/#{version}/bearwarden-#{version}-#{arch}.dmg",
      verified: "github.com/gnehs/BearWarden/"
  name "BearWarden"
  desc "Experimental local-first desktop password manager"
  homepage "https://github.com/gnehs/BearWarden"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on macos: :tahoe

  app "BearWarden.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-dr", "com.apple.quarantine", "#{appdir}/BearWarden.app"],
                   must_succeed: false
  end
end
