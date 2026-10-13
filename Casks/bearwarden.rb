cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.21"
  sha256 arm:   "6a9f1c913a8faeacc2a1a266d6e13b038ed0016813d505c7c777bbf2578f35b7",
         intel: "f8e5223d2dd19e0e06950606e12fb78cfba3156843f4c715581207863ad0c519"

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
