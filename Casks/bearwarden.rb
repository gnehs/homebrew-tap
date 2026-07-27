cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.13"
  sha256 arm:   "7c589eaf0aa050865a17a062ef4e5d29efb9df395709e5d1c18632129a87408c",
         intel: "54643fb90bf9858c52db101e594b365cc9d9fc435d4ce565649d53b11ce93229"

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
