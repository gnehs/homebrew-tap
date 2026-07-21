cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.5"
  sha256 arm:   "73d03a81e6146d71f41135bd80c26d4bcb3abd01a4c3db235232b6c9ae5bda04",
         intel: "be7baf6f6802a9ce30cbe886429309b41f6726361ce2cfbdc6283ab3105fa59a"

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
