cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.20"
  sha256 arm:   "6e995a40ad096e9a5653b19d23d3bd491a0995a43fe9bf8313f384bc977ecd5e",
         intel: "5bdb342976450db8863c14d6200ec5a82466b410a06662ff67ae1cfb11b2789b"

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
