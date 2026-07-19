cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.2"
  sha256 arm:   "81d294958628ac9462ec68ae4699a57970e3a6398b99b5e3c9b5cf81993b1971",
         intel: "8eb5881e97c25fb283dba3791e57b7215ea520c29fda0300661b86edbb93115d"

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
