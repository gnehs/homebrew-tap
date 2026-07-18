cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.0"
  sha256 arm:   "8502bfdcc9d42647f52e7a73d554feec97e3d8b8fbfa5492afe1c193bb7c99b5",
         intel: "8f30a31ae6330adff9a8bdbbdd2f2f1444c114e3849b5a08ac45b3998a976b1d"

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
