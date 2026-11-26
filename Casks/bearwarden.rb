cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.26"
  sha256 arm:   "ca80b3a4be2c4ed3085f2f577c39de0303865dfcfb4ac8f377f4147c5ec03b16",
         intel: "fca119a540fc7b73ae15c073f1926fd0d064740a5f7d5f03d4a675d422830a21"

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
