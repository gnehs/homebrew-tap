cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.14"
  sha256 arm:   "d7d8da4b0f91eb89ac2cba8511b19b5518b968ce0616cfab7e57d7388fb0ee40",
         intel: "9df6aad6eb97fb5445b8297b9e6212c1ddc2a5ca868f61696946687e39c50772"

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
