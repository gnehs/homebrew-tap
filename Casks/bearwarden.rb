cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.22"
  sha256 arm:   "3ef4e694556bf8cb8592356d9038b96c2b3652f032e93c3f5618fc9ad03160ed",
         intel: "5a0ebb5c5d3529787c44946341c17ad96152f59135eb4a384c6c8df5caf6e0fc"

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
