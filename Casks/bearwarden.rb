cask "bearwarden" do
  arch arm: "arm64", intel: "x64"

  version "0.1.27"
  sha256 arm:   "a8f3959f0fa87dd2477083ebc919200bb24dce1aa2cc429dc52bdd3cf510e3e7",
         intel: "550c649b6d10427ce9a39c16e1fa8e33cf046dff1875195293f7e9be1c8086c0"

  url "https://github.com/gnehs/BearWarden/releases/download/#{version}/bearwarden-#{version}-#{arch}.dmg"
  name "BearWarden"
  desc "Experimental local-first desktop password manager"
  homepage "https://github.com/gnehs/BearWarden"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on macos: :tahoe

  app "BearWarden.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-dr", "com.apple.quarantine", "{{appdir}}/BearWarden.app"],
        must_succeed: false
  end
end
