cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.12"
  sha256 arm:   "ca3839284ca9b8244b2ba0c0386525aea7c90b861073dab1fdc7045c82cdcabc",
         intel: "454d2613c45aebe0b299d72273bc02b5fc93905005f5c7d2f1a4910a9518b2af"

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
