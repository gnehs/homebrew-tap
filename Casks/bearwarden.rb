cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.8"
  sha256 arm:   "544330cb4ad83fc322bfb4ffeaa164869fd9b9146bb35852ce3e3c7cf4096532",
         intel: "05a13d5cce085f81bb03cd76a772ef5dd942920f093d9ea704aa82f5593c1aaf"

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
