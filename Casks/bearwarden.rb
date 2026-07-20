cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.4"
  sha256 arm:   "d90a18e3bf7d0f94ccf1dd5e53a6404b8744cb9b7e54066023bb05c31c89c1a0",
         intel: "845e48ef55e8dad8e3914abed194afc82c000eb87ccf45b56902a8982902dff2"

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
