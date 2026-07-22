cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.10"
  sha256 arm:   "0e27241ad081cffa5786f21a8a2ceebbf6ad95580fe7ccb5ffa84578a8a7e336",
         intel: "bdcb6bf34f79d70605648ee06fb704e6cf9986e8b27365a7d38a2455a45a17e3"

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
