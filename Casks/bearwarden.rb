cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.7"
  sha256 arm:   "113c6622cab15263e836b60fe37d286b52f47e8dbe88543747b46da53148e169",
         intel: "02a609f89cfbc5dc870ceb830d449174c5c594a596e1af8807f6608e2b6f3567"

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
