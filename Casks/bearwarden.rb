cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.17"
  sha256 arm:   "f8798278b883f040b3dada7ac018fce9e36719b6613773d741c1767df61d663a",
         intel: "14517ec667d123da61fb9033d8164d2985a8e0121adce7855a8e99fbf267db84"

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
