cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.9"
  sha256 arm:   "0ace18ee2a93f18be9f1b4c84b54fc5a41592a89bc88d899cd14f19d153d91eb",
         intel: "62db199c0000f209d1270a71c924ad7efb446ad2c76d092ac6166763c53ad9fd"

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
