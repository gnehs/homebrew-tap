cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.24"
  sha256 arm:   "d825ad18477fddd3f380c2410edcd62da82db5d1f86026531ad36ddc0da8a444",
         intel: "8ca7ef19e461317a481213909a9d876543e9a67f01b2a3fe69f3f318d4fc4d9a"

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
