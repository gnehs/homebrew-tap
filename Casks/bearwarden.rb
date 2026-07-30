cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.15"
  sha256 arm:   "8d60242ff21262126ff597dbca5380243128fbfdffe9169b004fb57b6c4a7623",
         intel: "f36b920885eb04eef858332ce4236bff22668742a849f4fb7815504fec4e12f9"

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
