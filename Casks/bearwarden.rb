cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.23"
  sha256 arm:   "eee6277db2784feb88af96c1f5693438aff455d9e8a3eebaf061ea791232cf0d",
         intel: "3c68faa031b88f234f8aadac1776e7101b9553ffcaae55dbe070f2961f1fb35b"

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
