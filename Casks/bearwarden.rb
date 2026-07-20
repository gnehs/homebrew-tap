cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.3"
  sha256 arm:   "4c8b4779fb01e02e433daa637d328c3cdb5e21d7a7eb9e579772e9920183f620",
         intel: "7ff0af9b46f504de2a3276d1bacc129ccccf3de5721f76ab9bf1a0483a34b099"

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
