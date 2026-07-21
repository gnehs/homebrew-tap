cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.6"
  sha256 arm:   "04767576a8b17534cc990074bbb326af37a6508548b0d46278baee72e333b154",
         intel: "b13b2ac806e7aadf34167b447737327d73bb640241a40f2b396d3a50e6a027a9"

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
