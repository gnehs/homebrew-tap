cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.1"
  sha256 arm:   "9aed9fccaa8a1fee32e6a08851e287780aabbc610c3d7725e351144dbba1e68b",
         intel: "b8cb4c83d8f338a68dda0aec0d30af507453de4f8d6bba282ef424f246535e06"

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
