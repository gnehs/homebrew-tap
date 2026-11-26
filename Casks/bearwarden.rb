cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.25"
  sha256 arm:   "7de7b56bbfce72ce83913da495ee4f5668034dd4f666672d04fd92b80c1d17e9",
         intel: "ceaef036e6b1f00bed8ba59d15da68fe893011573f0a8e3949a086926c43b396"

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
