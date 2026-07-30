cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.18"
  sha256 arm:   "1cdf6655b1b0ece87e1a5020c1aa1b59175d9bdddc2e9faa9833a36419a160ff",
         intel: "7ecb6b1e152a37cc131e97a076d8e689c9cf5d830a25ecac9056b2f824524d4b"

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
